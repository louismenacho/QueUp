//
//  RoomViewModel.swift
//  QueUp
//
//  Created by Louis Menacho on 5/11/22.
//

import Foundation

class RoomViewModel {
    
    var service = RoomService.shared

    var room = Room()
        
    func roomListener(_ listener: @escaping (Result<(), Error>) -> Void) {
        service.startListener()
        service.listener = { result in
            switch result {
            case .success(let room):
                self.room = room
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
