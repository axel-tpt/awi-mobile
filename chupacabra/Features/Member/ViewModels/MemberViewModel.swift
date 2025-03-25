import Foundation
import Combine
import SwiftUI

@MainActor
class MemberViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var members: [Member] = []
    @Published private(set) var member: Member? = nil
    
    private let memberService: MemberServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(memberService: MemberServiceProtocol = MemberService()) {
        self.memberService = memberService
    }
    
    func loadMembers(onSuccess: (() -> Void)? = nil,
                     onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            memberService.getMembers(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { members in
                self.members = members
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func updateMember(id: Int,
                     data: MemberForm,
                     onSuccess: (() -> Void)? = nil,
                     onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            memberService.updateMemberById(id: id, data: data),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadMembers(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func deleteMember(id: Int,
                     onSuccess: (() -> Void)? = nil,
                     onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            memberService.removeMemberById(id: id),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadMembers(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func createMember(data: MemberForm,
                     onSuccess: (() -> Void)? = nil,
                     onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            memberService.createMember(data: data),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadMembers(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
} 