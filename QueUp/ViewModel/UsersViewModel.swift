//
//  UsersViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 5/11/22.
//

import Foundation

class UsersViewModel {
    
    var service = UserService.shared
    
    var users = [User]()
    
    func usersListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        service.startListener()
        service.listener = { result in
            switch result {
            case .success(let users):
                self.users = users
                listener(.success(()))
            case .failure(let error):
                listener(.failure(error))
            }
        }
    }
    
    func stopListener() {
        service.stopListener()
    }
}
