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
    func forgotPassword(email: String) -> Observable<Void>
    func logout() -> Observable<Void>
    func addNewShippingInfoProfile(profile: UserShippingInfo) -> Observable<String>
    func getUserShippingInfo() -> Observable<UserShippingInfo>
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
                                print("Error receiving user from database! \n Error: \(String(describing: error))")
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

    func forgotPassword(email: String) -> Observable<Void> {
        return Observable.create { observer in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if error != nil {
                    print("Error on sending reset password email: \(String(describing: error))")
                    observer.onError(error!)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
    }

    func logout() -> Observable<Void> {
        return Observable.create { observer in
            do {
                try Auth.auth().signOut()
                observer.onNext(())
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    func addNewShippingInfoProfile(profile: UserShippingInfo) -> Observable<String> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("userShippingInfo").whereField("uid", isEqualTo: profile.uid)
                .getDocuments { snapshot, error in
                    if error != nil {
                        print("Error:: \(String(describing: error))")
                    } else {
                        if let snapshot = snapshot {
                            if snapshot.documents.isEmpty {
                                database.collection("userShippingInfo").addDocument(data: [
                                    "uid" : profile.uid,
                                    "profileName": profile.profileName,
                                    "fullName": profile.fullName,
                                    "mobileNumber": profile.mobileNumber,
                                    "address": profile.address
                                ]) { error in
                                    if error != nil {
                                        print("Error: \(String(describing: error))")
                                        observer.onError(error!)
                                    } else {
                                        observer.onNext("Thêm mới thông tin giao hàng thành công!")
                                    }
                                }
                            } else {
                                database.collection("userShippingInfo").document(snapshot.documents.first?.documentID ?? "")
                                    .updateData(["profileName": profile.profileName,
                                                 "fullName": profile.fullName,
                                                 "mobileNumber": profile.mobileNumber,
                                                 "address": profile.address]) { error in
                                        if error != nil {
                                            print("Error: \(String(describing: error))")
                                            observer.onError(error!)
                                        } else {
                                            observer.onNext("Cập nhật thông tin giao hàng thành công!")
                                        }
                                    }
                            }
                        }
                    }
            }
            return Disposables.create()
        }
    }

    func getUserShippingInfo() -> Observable<UserShippingInfo> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            let currentUID = UserManager.shared.getUserID()
            database.collection("userShippingInfo").whereField("uid", isEqualTo: currentUID)
                .getDocuments { snapshot, error in
                    if error != nil {
                        print("Error:: \(String(describing: error))")
                        observer.onError(error!)
                    } else {
                        if let snapshot = snapshot {
                            let userShippingInfo = snapshot.documents.map { document in
                                return UserShippingInfo(id: document["id"] as? String ?? "",
                                                        uid: document["uid"] as? String ?? "",
                                                        profileName: document["profileName"] as? String ?? "",
                                                        fullName: document["fullName"] as? String ?? "",
                                                        mobileNumber: document["mobileNumber"] as? String ?? "",
                                                        address: document["address"] as? String ?? "")
                            }
                            observer.onNext(userShippingInfo.first ?? UserShippingInfo())
                        }
                    }
                }
            return Disposables.create()
        }
    }
}
