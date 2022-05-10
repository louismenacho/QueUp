//
//  FirestoreRepository.swift
//  TurnTune
//
//  Created by Louis Menacho on 5/31/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreRepository<Object: Codable> {
    
    var collectionReference: CollectionReference
    var collectionListener: ListenerRegistration?
    
    init(collectionPath: String) {
        collectionReference = Firestore.firestore().collection(collectionPath)
    }
    
    func get(id: String) async throws -> Object {
        let documentSnapshot = try await collectionReference.document(id).getDocument()
        let object = try documentSnapshot.data(as: Object.self)
        return object
    }
    
    func list() async throws -> [Object] {
        let querySnapshot = try await collectionReference.getDocuments()
        let objectList = try querySnapshot.documents.compactMap { try $0.data(as: Object.self) }
        return objectList
    }
    
    func create(id: String? = nil, with object: Object) throws {
        if let id = id {
            try collectionReference.document(id).setData(from: object)
        } else {
            _ = try collectionReference.addDocument(from: object)
        }
    }
    
    func update(id: String, with object: Object) throws {
        try collectionReference.document(id).setData(from: object)
    }
    
    func delete(id: String) async throws {
        try await collectionReference.document(id).delete()
    }
    
    func addListener(id: String, _ listener: @escaping (Result<Object, Error>) -> Void) {
        collectionListener = collectionReference.document(id).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                listener(.failure(error))
                return
            }
            
            do {
                let object = try documentSnapshot?.data(as: Object.self)
                listener(.success(object!))
            } catch {
                listener(.failure(error))
            }
        }
    }

    func addListener(_ listener: @escaping (Result<[Object], Error>) -> Void) {
        collectionListener = collectionReference.addSnapshotListener { querySnapshot, error in
            if let error = error {
                listener(.failure(error))
                return
            }
            
            do {
                let dataList = try querySnapshot?.documents.compactMap { try $0.data(as: Object.self) }
                listener(.success(dataList!))
            } catch {
                listener(.failure(error))
            }
        }
    }
    
    func removeListener() {
        collectionListener?.remove()
        collectionListener = nil
    }
}
