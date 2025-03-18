import Foundation
import Combine
import SwiftUI

@MainActor
class SessionViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var sessions: [Session] = []
    @Published private(set) var session: Session? = nil
    
    private let sessionService: SessionServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(sessionService: SessionServiceProtocol = SessionService()) {
        self.sessionService = sessionService
    }
    
    func loadSessions(onSuccess: (() -> Void)? = nil,
                      onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sessionService.getSessions(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { sessions in
                self.sessions = sessions
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func updateSession(id: Int,
                       data: SessionForm,
                       onSuccess: (() -> Void)? = nil,
                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sessionService.updateSessionById(id: id, data: data),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadSessions(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func deleteSession(id: Int,
                       onSuccess: (() -> Void)? = nil,
                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sessionService.removeSessionById(id: id),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadSessions(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func createSession(data: SessionForm,
                       onSuccess: (() -> Void)? = nil,
                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sessionService.createSession(data: data),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadSessions(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
}
