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
    func getUserOrders(isAdmin: Bool) -> Observable<[Order]>
    func getOrderStatuses() -> Observable<[OrderStatus]>
    func getPaymentStatus() -> Observable<[String]>
    func updateOrderStatus(order: Order) -> Observable<Void>
    func updateOrderPaymentStatus(order: Order) -> Observable<Void>
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
                        observer.onError(error!)
                    } else {
                        if let snapshot = snapshot {
                            let userShippingInfo = snapshot.documents.map { document in
                                return UserShippingInfo(id: document.documentID,
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

    func getUserOrders(isAdmin: Bool = false) -> Observable<[Order]> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            let currentUID = UserManager.shared.getUserID()
            let getCollection = isAdmin ? database.collection("orders") : database.collection("orders").whereField("uid", isEqualTo: currentUID)
            
            getCollection.getDocuments(completion: { snapshot, error in
                if error != nil {
                    observer.onError(error!)
                } else {
                    var orders = [Order]()
                    if let snapshot = snapshot {
                        for document in snapshot.documents {
                            var order = Order()
                            order.documentID = document.documentID
                            order.couponUsed = Coupon(id: document["couponUsedID"] as? String ?? "",
                                                      name: document["couponUsedName"] as? String ?? "",
                                                      value: document["couponUsedValue"] as? Int ?? 0)
                            order.id = document["id"] as? String ?? ""
                            order.orderDate = Date(timeIntervalSince1970: document["orderDate"] as? TimeInterval ?? 0)
                            order.paidDate = Date(timeIntervalSince1970: document["paidDate"] as? TimeInterval ?? 0)
                            order.paymentMethod.name = document["paymentMethodName"] as? String ?? ""
                            order.status = document["status"] as? String ?? ""
                            order.totalValue = document["totalValue"] as? Int ?? 0
                            order.totalValueBeforeCoupon = document["totalValueBeforeCoupon"] as? Int ?? 0
                            order.uid = document["uid"] as? String ?? ""
                            order.userShippingInfo.id = document["userShippingInfoID"] as? String ?? ""
                            database.collection("userShippingInfo").document(order.userShippingInfo.id)
                                .getDocument { snapshot0, error in
                                    if error != nil {
                                        observer.onError(error!)
                                    } else {
                                        if let snapshot0 = snapshot0 {
                                            order.userShippingInfo = UserShippingInfo(
                                                id: snapshot0.documentID,
                                                uid: snapshot0["uid"] as? String ?? "",
                                                profileName: snapshot0["profileName"] as? String ?? "",
                                                fullName: snapshot0["fullName"] as? String ?? "",
                                                mobileNumber: snapshot0["mobileNumber"] as? String ?? "",
                                                address: snapshot0["address"] as? String ?? "")
                                            database.collection("orderDetails").whereField("orderID", isEqualTo: order.id)
                                                .getDocuments { snapshot1, error in
                                                    if error != nil {
                                                        observer.onError(error!)
                                                    } else {
                                                        var cart = Cart()
                                                        if let snapshot1 = snapshot1 {
                                                            for document1 in snapshot1.documents {
                                                                cart.items.append(Product(id: "",
                                                                                          documentID: "",
                                                                                          name: document1["productName"] as? String ?? "",
                                                                                          price: document1["productPrice"] as? Double ?? 0.0,
                                                                                          category: ProductCategory(documentID: "",
                                                                                                                    id: document1["productCategoryID"] as? String ?? "",
                                                                                                                    name: document1["productCategoryName"] as? String ?? ""),
                                                                                          image: UIImage(),
                                                                                          imageName: document1["productImageName"] as? String ?? "",
                                                                                          imageURL: document1["productImageURL"] as? String ?? "",
                                                                                          quantity: document1["productQuantity"] as? Int ?? 0))
                                                            }
                                                        }
                                                        order.cart = cart
                                                        orders.append(order)
                                                        observer.onNext(orders)
                                                    }
                                                }
                                        }
                                    }
                                }
                        }
                    }

                }
            })
            return Disposables.create()
        }
    }

    func getOrderStatuses() -> Observable<[OrderStatus]> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("orderStatus").getDocuments { snapshot, error in
                if error != nil {
                    observer.onError(error!)
                } else {
                    var returnStatuses = [OrderStatus]()
                    if let snapshot = snapshot {
                        for document in snapshot.documents {
                            returnStatuses.append(OrderStatus(id: document["id"] as? String ?? "",
                                                              name: document["name"] as? String ?? ""))
                        }
                        observer.onNext(returnStatuses)
                    }
                }
            }
            return Disposables.create()
        }
    }

    func getPaymentStatus() -> Observable<[String]> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("paymentStatus").getDocuments { snapshot, error in
                if error != nil {
                    observer.onError(error!)
                } else {
                    var returnStatuses = [String]()
                    if let snapshot = snapshot {
                        for document in snapshot.documents {
                            returnStatuses.append(document["name"] as? String ?? "")
                        }
                        observer.onNext(returnStatuses)
                    }
                }
            }
            return Disposables.create()
        }
    }

    func updateOrderStatus(order: Order) -> Observable<Void> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("orders").document(order.documentID).updateData([
                "status" : order.status
            ]) { error in
                if error != nil {
                    observer.onError(error!)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
    }

    func updateOrderPaymentStatus(order: Order) -> Observable<Void> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("orders").document(order.documentID).updateData([
                "paidDate" : order.paidDate?.timeIntervalSince1970
            ]) { error in
                if error != nil {
                    observer.onError(error!)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
    }
}
