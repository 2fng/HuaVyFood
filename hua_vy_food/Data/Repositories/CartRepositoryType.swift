//
//  CartRepositoryType.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 18/09/2022.
//

import Foundation
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol CartRepositoryType {
    func getCart() -> Observable<Cart>
    func updateCart(cart: Cart) -> Observable<String>
    func getPaymentMethod() -> Observable<[PaymentMethod]>
    func getCoupon() -> Observable<[Coupon]>
    func checkout(order: Order) -> Observable<Void>
}

final class CartRepository: CartRepositoryType {
    func getCart() -> Observable<Cart> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("carts").whereField("uid", isEqualTo: UserManager.shared.getUserID()).getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let snapShot = snapshot {
                        if snapShot.isEmpty {
                            observer.onNext(Cart())
                        } else {
                            var returnCart = Cart()
                            returnCart.uid = UserManager.shared.getUserID()
                            for document in snapShot.documents {
                                var product = Product()
                                returnCart.id = document["id"] as? String ?? ""
                                returnCart.documentID = document.documentID
                                product.id = document["productID"] as? String ?? ""
                                product.documentID = document["productDocumentID"] as? String ?? ""
                                product.name = document["productName"] as? String ?? ""
                                product.price = document["productPrice"] as? Double ?? 0.0
                                product.category = ProductCategory(id: document["productCategoryID"] as? String ?? "",
                                                                   name: document["productCategoryName"] as? String ?? "")
                                product.imageName = document["productImageName"] as? String ?? ""
                                product.imageURL = document["productImageURL"] as? String ?? ""
                                product.quantity = document["productQuantity"] as? Int ?? 0
                                returnCart.items.append(product)
                            }
                            observer.onNext(returnCart)
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func updateCart(cart: Cart) -> Observable<String> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("carts").whereField("uid", isEqualTo: cart.uid).getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if snapshot?.documents.count ?? 0 <= 0 {
                        for item in cart.items {
                            database.collection("carts").addDocument(data: [
                                "uid" : UserManager.shared.getUserID(),
                                "id": "\(CACurrentMediaTime().truncatingRemainder(dividingBy: 1))",
                                "productID": item.id,
                                "productDocumentID": item.documentID,
                                "productName": item.name,
                                "productPrice": item.price,
                                "productCategoryID": item.category.id,
                                "productCategoryName": item.category.name,
                                "productImageName": item.imageName,
                                "productImageURL": item.imageURL,
                                "productQuantity": item.quantity
                            ]) { error in
                                if error != nil {
                                    print("Error adding cart to database: \(String(describing: error))")
                                    observer.onError(error!)
                                }
                            }
                        }
                        observer.onNext("Cập nhật thành công!")
                    } else {
                        if let snapshot = snapshot {
                            for document in snapshot.documents {
                                database.collection("carts").document(document.documentID).delete { error in
                                    if let error = error {
                                        observer.onError(error)
                                        print("Error deleting cart: \n\(error)")
                                    }
                                }
                            }
                        }
                        for item in cart.items {
                            database.collection("carts").addDocument(data: [
                                "uid" : cart.uid,
                                "id": "\(CACurrentMediaTime().truncatingRemainder(dividingBy: 1))",
                                "productID": item.id,
                                "productDocumentID": item.documentID,
                                "productName": item.name,
                                "productPrice": item.price,
                                "productCategoryID": item.category.id,
                                "productCategoryName": item.category.name,
                                "productImageName": item.imageName,
                                "productImageURL": item.imageURL,
                                "productQuantity": item.quantity
                            ]) { error in
                                if error != nil {
                                    print("Error adding cart to database: \(String(describing: error))")
                                }
                            }
                        }
                        observer.onNext("Cập nhật thành công!")
                    }
                }
            }
            return Disposables.create()
        }
    }

    func getPaymentMethod() -> Observable<[PaymentMethod]> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("paymentMethods").getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let snapShot = snapshot {
                        if snapShot.isEmpty {
                            observer.onNext([PaymentMethod()])
                        } else {
                            var returnPaymentMethods: [PaymentMethod] = []
                            for document in snapShot.documents {
                                var method = PaymentMethod()
                                method.id = document["id"] as? String ?? ""
                                method.name = document["name"] as? String ?? ""
                                method.paymentDetail = document["paymentDetail"] as? String ?? ""
                                returnPaymentMethods.append(method)
                            }
                            observer.onNext(returnPaymentMethods)
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func getCoupon() -> Observable<[Coupon]> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("coupons").getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let snapShot = snapshot {
                        if snapShot.isEmpty {
                            observer.onNext([Coupon()])
                        } else {
                            var returnCoupons: [Coupon] = []
                            for document in snapShot.documents {
                                var coupon = Coupon()
                                coupon.id = document["id"] as? String ?? ""
                                coupon.name = document["name"] as? String ?? ""
                                coupon.value = document["value"] as? Int ?? 0
                                returnCoupons.append(coupon)
                            }
                            observer.onNext(returnCoupons)
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func checkout(order: Order) -> Observable<Void> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("orders").addDocument(data: [
                "id": order.id,
                "uid":  order.uid,
                "totalValue": order.totalValue,
                "totalValueBeforeCoupon": order.totalValueBeforeCoupon,
                "couponUsedID": order.couponUsed?.id,
                "couponUsedName": order.couponUsed?.name,
                "couponUsedValue": order.couponUsed?.value,
                "paymentMethodName": order.paymentMethod.name,
                "userShippingInfoID": order.userShippingInfo.id,
                "orderDate": order.orderDate.timeIntervalSince1970,
                "status": order.status,
                "paidDate": order.paidDate?.timeIntervalSince1970
            ]) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    for product in order.cart.items {
                        database.collection("orderDetails").addDocument(data: [
                            "orderID": order.id,
                            "uid": order.uid,
                            "productName": product.name,
                            "productPrice": product.price,
                            "productImageName": product.imageName,
                            "productImageURL": product.imageURL,
                            "productCategoryID": product.category.id,
                            "productCategoryName": product.category.name,
                            "productQuantity": product.quantity
                        ]) { error in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                database.collection("carts").whereField("uid", isEqualTo: order.cart.uid).getDocuments { snapshot, error in
                                    if let error = error {
                                        observer.onError(error)
                                    } else {
                                        if let snapshot = snapshot {
                                            for document in snapshot.documents {
                                                database.collection("carts").document(document.documentID).delete { error in
                                                    if let error = error {
                                                        observer.onError(error)
                                                        print("Error deleting cart: \n\(error)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                observer.onNext(())
                            }
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
}
