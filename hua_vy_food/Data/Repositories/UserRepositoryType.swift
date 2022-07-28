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
}
