//
//  UserRepositoryType.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/07/2022.
//

import Foundation
import RxSwift
import FirebaseAuth
import FirebaseFirestore

protocol UserRepositoryType {
    func register(email: String, password: String) -> Observable<Void>
    func login(email: String, password: String) -> Observable<UserSignIn?>
}

final class UserRepository: UserRepositoryType {
    func register(email: String, password: String) -> Observable<Void> {
        return Observable.create { observer in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error on register: \(error)")
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    let database = Firestore.firestore()
                    if let uid = result?.user.uid {
                        database.collection("users").addDocument(data: [
                            "uid" : uid,
                            "email": email,
                            "password": password,
                            "isAdmin": false
                        ]) { error in
                            if error != nil {
                                print("Error adding user to database: \(String(describing: error))")
                            }
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func login(email: String, password: String) -> Observable<UserSignIn?> {
        return Observable.create { observer in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error on register: \(error)")
                    observer.onError(error)
                } else {
                    let database = Firestore.firestore()
                    database.collection("users").whereField("uid", isEqualTo: result?.user.uid)
                        .getDocuments(completion: { snapshot, error in
                            if error != nil {
                                print("Error receiving user from database! \n Error: \(error)")
                            } else {
                                if let snapshot = snapshot {
                                    let currentUserSignIn = snapshot.documents.map { document in
                                        return UserSignIn(uid: document["uid"] as? String ?? "",
                                                          isAdmin: document["isAdmin"] as? Bool ?? false)
                                    }
                                    observer.onNext(currentUserSignIn.first)
                                }
                            }
                        })
                }
            }
            return Disposables.create()
        }
    }
}