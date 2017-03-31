//
//  Authenticator.swift
//  FLYR
//
//  Created by Garric Nahapetian on 10/5/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import CloudKit
import GGNObservable

protocol Authenticating {
    func authenticate(completion: @escaping (Authenticator.AuthResponse) -> Void)
    func authenticate()
    func ownerReference() -> CKReference?
}

class Authenticator: Authenticating {
    
    enum AuthResponse {
        case authenticated(CKReference)
        case notAuthenticated(Error)
    }
    
    private let container: Container
    private var user: User?

    init(defaultContainer: Container) {
        self.container = defaultContainer
        self.container.fetchUserRecordID { [weak self] response in
            guard case .successful(let recordID as CKRecordID) = response else { return }
            let reference = CKReference(recordID: recordID, action: .none)
            self?.user = User(ownerReference: reference)
        }
    }

    func ownerReference() -> CKReference? {
        return user?.ownerReference
    }
    
    func authenticate() {
        authenticate(completion: { _ in })
    }

    func authenticate(completion: @escaping (Authenticator.AuthResponse) -> Void) {
        if let user = user {
            let response = Authenticator.AuthResponse.authenticated(user.ownerReference)
            return completion(response)
        } else {
            authenticate(with: completion)
        }
    }
    
    private func authenticate(with completion: @escaping (Authenticator.AuthResponse) -> Void) {
        container.fetchUserRecordID { response in
            switch response {
            case .successful(let any):
                guard let recordID = any as? CKRecordID else { return }
                let reference = CKReference(recordID: recordID, action: .none)
                let response = Authenticator.AuthResponse.authenticated(reference)
                completion(response)
            case .notSuccessful(let error):
                let response = Authenticator.AuthResponse.notAuthenticated(error)
                completion(response)
            }
        }
    }
}

protocol Container {
    func fetchUserRecordID(completion: @escaping (Response) -> Void)
}

extension CKContainer: Container {
    func fetchUserRecordID(completion: @escaping (Response) -> Void) {
        self.fetchUserRecordID { recordID, error in
            let response: Response

            if let recordID = recordID {
                response = .successful(recordID)
            } else {
                let _error: Error

                if let error = error {
                    _error = error
                } else {
                    _error = GGNError(message: "Unknown container error.")
                }

                response = .notSuccessful(_error)
            }
            completion(response)
        }
    }
}
