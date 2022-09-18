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
}
