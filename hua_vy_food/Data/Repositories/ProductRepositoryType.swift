//
//  ProductRepositoryType.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 14/08/2022.
//

import Foundation
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol ProductRepositoryType {
    func getProductCategories() -> Observable<[ProductCategory]>
    func addNewCategory(categoryName: String) -> Observable<String>
    func updateCategory(category: ProductCategory) -> Observable<Void>
    func deleteCategory(documentID: String) -> Observable<Void>
    func addNewProduct(product: Product) -> Observable<String>
    func getProducts() -> Observable<[Product]>
    func deleteProduct(documentID: String) -> Observable<String>
    func updateProduct(product: Product) -> Observable<String>
    func updateLikeAndDislikeStatus(productID: String, isLike: Bool) -> Observable<Void>
}

final class ProductRepository: ProductRepositoryType {
    func getProductCategories() -> Observable<[ProductCategory]> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("categories").getDocuments { snapShot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let snapShot = snapShot {
                        if snapShot.isEmpty {
                            observer.onNext([])
                        } else {
                            var returnCategories = [ProductCategory]()
                            for document in snapShot.documents {
                                returnCategories.append(ProductCategory(
                                    documentID: document.documentID,
                                    id: document["id"] as? String ?? "",
                                    name: document["name"] as? String ?? ""))
                            }
                            observer.onNext(returnCategories)
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func addNewCategory(categoryName: String) -> Observable<String> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            var numberOfCategory = 0
            database.collection("categories").getDocuments { snapShot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if categoryName.isEmpty {
                        observer.onNext("Tên thể loại không được để trống")
                    } else {
                        numberOfCategory = snapShot?.count ?? 0
                        let _existCategory = database.collection("categories").whereField("name", isEqualTo: categoryName)
                        _existCategory.getDocuments { _snapShot, _error in
                            guard let _snapShot = _snapShot else { return }
                            if _snapShot.isEmpty {
                                database.collection("categories").addDocument(data: [
                                    "id": "HVFC\(numberOfCategory)",
                                    "name":  categoryName
                                ]) { error in
                                    if let error = error {
                                        observer.onError(error)
                                    } else {
                                        observer.onNext("Thêm mới thể loại thành công!")
                                    }
                                }
                            } else {
                                observer.onNext("Thể loại đã tồn tại!")
                            }
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func addNewProduct(product: Product) -> Observable<String> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("images/\(product.imageName)")
            var numberOfProduct = 0

            if product.name.isEmpty ||
                product.price <= 0 ||
                product.category.name.isEmpty ||
                product.image == UIImage() {
                observer.onNext("Các trường thông tin phải được điền đầy đủ!")
            }

            database.collection("products").getDocuments { snapShot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    numberOfProduct = snapShot?.count ?? 0
                    let _existProduct = database.collection("products").whereField("name", isEqualTo: product.name)
                    _existProduct.getDocuments { _snapShot, _error in
                        guard let _snapShot = _snapShot else { return }
                        if _snapShot.isEmpty {
                            var imageURL = ""
                            if let imageData = product.image.pngData() {
                                imageRef.putData(imageData) { _, error in
                                    if let error = error {
                                        observer.onError(error)
                                    } else {
                                        imageRef.downloadURL { url, error in
                                            imageURL = url?.absoluteString ?? ""
                                            database.collection("products").addDocument(data: [
                                                "id": "HVFP\(numberOfProduct)",
                                                "name":  product.name,
                                                "price": product.price,
                                                "categoryID": product.category.id,
                                                "categoryName": product.category.name,
                                                "imageName": product.imageName,
                                                "imageURL": imageURL,
                                            ]) { error in
                                                if let error = error {
                                                    observer.onError(error)
                                                } else {
                                                    observer.onNext("Thêm mới sản phẩm thành công!")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            observer.onNext("Sản phẩm đã tồn tại!")
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func getProducts() -> Observable<[Product]> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("products").getDocuments { snapShot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let snapShot = snapShot {
                        if snapShot.isEmpty {
                            observer.onNext([])
                        } else {
                            var returnProducts = [Product]()
                            for document in snapShot.documents {
                                var product = Product()
                                product.id = document["id"] as? String ?? ""
                                product.documentID = document.documentID
                                product.name = document["name"] as? String ?? ""
                                product.price = document["price"] as? Double ?? 0.0
                                product.category.id = document["categoryID"] as? String ?? ""
                                product.category.name = document["categoryName"] as? String ?? ""
                                product.imageURL = document["imageURL"] as? String ?? ""
                                product.imageName = document["imageName"] as? String ?? ""
                                returnProducts.append(product)
                            }
                            observer.onNext(returnProducts)
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    func deleteProduct(documentID: String) -> Observable<String> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("products").document(documentID).delete { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext("Xoá thành công!")
                }
            }
            return Disposables.create()
        }
    }

    func updateProduct(product: Product) -> Observable<String> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("images/\(product.imageName)")
            var imageURL = ""
            if let imageData = product.image.pngData() {
                imageRef.putData(imageData) { _, error in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        imageRef.downloadURL { url, error in
                            imageURL = url?.absoluteString ?? ""
                            database.collection("products").document(product.documentID).setData([
                                "name":  product.name,
                                "price": product.price,
                                "categoryID": product.category.id,
                                "categoryName": product.category.name,
                                "imageName": product.imageName,
                                "imageURL": imageURL,
                            ]) { error in
                                if let error = error {
                                    observer.onError(error)
                                } else {
                                    observer.onNext("Cập nhật sản phẩm thành công!")
                                }
                            }
                        }
                    }
                }
            } else {
                observer.onNext("Cập nhật không thành công!")
            }
            return Disposables.create()
        }
    }

    func updateCategory(category: ProductCategory) -> Observable<Void> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("categories").document(category.documentID).updateData([
                "name" : category.name
            ]) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
    }
    
    func deleteCategory(documentID: String) -> Observable<Void> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            database.collection("categories").document(documentID).delete { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
    }

    func updateLikeAndDislikeStatus(productID: String, isLike: Bool) -> Observable<Void> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            let collectionName = isLike ? "productLikes" : "productDislikes"
            let oppositeCollectionName = isLike ? "productDislikes" : "productLikes"
            database.collection(collectionName).whereField("productID", isEqualTo: productID)
                .getDocuments(completion: { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    if let snapshot = snapshot {
                        var documentID = ""
                        let isContained = snapshot.documents.contains { document in
                            let userID = document["uid"] as? String ?? ""
                            documentID = userID == UserManager.shared.getUserID() ? document.documentID : ""
                            return userID == UserManager.shared.getUserID()
                        }

                        if isContained {
                            database.collection(collectionName).document(documentID).delete { error in
                                if let error = error {
                                    observer.onError(error)
                                } else {
                                    observer.onNext(())
                                }
                            }
                        } else {
                            database.collection(collectionName).addDocument(data: [
                                "uid" : UserManager.shared.getUserID(),
                                "productID": productID
                            ]) { error in
                                if error != nil {
                                    print("Error: \(String(describing: error))")
                                    observer.onError(error!)
                                } else {
                                    // Delete dislike if like and vice versa
                                    database.collection(oppositeCollectionName).whereField("productID", isEqualTo: productID)
                                        .getDocuments { deleteSnapshot, error in
                                            if let error = error {
                                                observer.onError(error)
                                            } else {
                                                if let deleteSnapshot = deleteSnapshot {
                                                    var documentID = ""
                                                    let isContained = deleteSnapshot.documents.contains { document in
                                                        let userID = document["uid"] as? String ?? ""
                                                        documentID = userID == UserManager.shared.getUserID() ? document.documentID : ""
                                                        return userID == UserManager.shared.getUserID()
                                                    }

                                                    if isContained {
                                                        database.collection(oppositeCollectionName).document(documentID).delete { error in
                                                            if let error = error {
                                                                observer.onError(error)
                                                            } else {
                                                                observer.onNext(())
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
                    }
                }
            })
            return Disposables.create()
        }
    }
}
