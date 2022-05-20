//
//  UsersViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 5/11/22.
//

import Foundation
import FirebaseCrashlytics

class UsersViewModel {
    
    enum UsersViewModelError: LocalizedError {
        case userListenerError
        case userDeleteError
        
        var errorDescription: String? {
            switch self {
            case .userListenerError:
                return "Could not sync user data"
            case .userDeleteError:
                return "Could not delete user"
            }
        }
    }
    
    var service = UserService.shared
    
    var users = [User]()
    
    func usersListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        service.startListener()
        service.listener = { result in
            switch result {
            case .success(let users):
                self.users = users.sorted(by: { $0.dateAdded < $1.dateAdded })
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func stopListener() {
        service.stopListener()
    }
    
    func signedInUser() -> User {
        return AuthService.shared.signedInUser
    }
    
    func getUser(_ user: User) -> User? {
        return users.first(where: { $0.id == user.id })
    }
    
    func deleteUser(_ user: User) async -> Result<(), Error> {
        do {
            try await service.removeUser(user)
            return .success(())
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return .failure(UsersViewModelError.userDeleteError)
        }
    }
}
