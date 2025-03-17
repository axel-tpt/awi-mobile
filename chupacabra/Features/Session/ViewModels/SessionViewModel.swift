import Foundation
import Combine
import SwiftUI

enum SessionState: Equatable {
    case idle
    case loading
    case loaded([Session])
    case loadingCurrent
    case currentLoaded(Session)
    case creating
    case updating
    case deleting
    case error(String)
    
    static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsSessions), .loaded(let rhsSessions)):
            return lhsSessions.map { $0.id } == rhsSessions.map { $0.id }
        case (.loadingCurrent, .loadingCurrent):
            return true
        case (.currentLoaded(let lhsSession), .currentLoaded(let rhsSession)):
            return lhsSession.id == rhsSession.id
        case (.creating, .creating):
            return true
        case (.updating, .updating):
            return true
        case (.deleting, .deleting):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

@MainActor
class SessionViewModel: ObservableObject {
    @Published private(set) var state: SessionState = .idle
    @Published private(set) var sessions: [Session] = []
    @Published private(set) var currentSession: Session?
    
    private let sessionService: SessionServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionService: SessionServiceProtocol = SessionService()) {
        self.sessionService = sessionService
    }
    
    func loadSessions() {
        state = .loading
        
        sessionService.loadSessions()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion: Subscribers.Completion<SessionError>) in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] (sessions: [Session]) in
                guard let self = self else { return }
                self.sessions = sessions
                self.state = .loaded(sessions)
            }
            .store(in: &cancellables)
    }
    
    func loadCurrentSession() {
        state = .loadingCurrent
        
        sessionService.getCurrentSession()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion: Subscribers.Completion<SessionError>) in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] (session: Session) in
                guard let self = self else { return }
                self.currentSession = session
                self.state = .currentLoaded(session)
            }
            .store(in: &cancellables)
    }
    
    func getSessionById(id: Int) {
        state = .loading
        
        sessionService.getSessionById(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion: Subscribers.Completion<SessionError>) in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] (session: Session) in
                guard let self = self else { return }
                if let index = self.sessions.firstIndex(where: { $0.id == session.id }) {
                    self.sessions[index] = session
                }
                self.state = .currentLoaded(session)
            }
            .store(in: &cancellables)
    }
    
    func updateSession(id: Int, data: SessionForm) {
        state = .updating
        
        sessionService.updateSessionById(id: id, data: data)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion: Subscribers.Completion<SessionError>) in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                } else {
                    // Recharger la session mise à jour pour obtenir les nouvelles données
                    self.getSessionById(id: id)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func deleteSession(id: Int) {
        state = .deleting
        
        sessionService.removeSessionById(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion: Subscribers.Completion<SessionError>) in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                } else {
                    // Supprimer la session de la liste des sessions
                    self.sessions.removeAll { $0.id == id }
                    self.state = .loaded(self.sessions)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func createSession(data: SessionForm) {
        state = .creating
        
        sessionService.createSession(data: data)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion: Subscribers.Completion<SessionError>) in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                } else {
                    // Recharger toutes les sessions pour inclure la nouvelle
                    self.loadSessions()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
