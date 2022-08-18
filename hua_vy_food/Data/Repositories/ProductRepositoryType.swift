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

protocol ProductRepositoryType {
    func getProductCategories() -> Observable<[ProductCategory]>
    func addNewCategory(categoryName: String) -> Observable<String>
    func addNewProduct(product: Product) -> Observable<String>
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
            return Disposables.create()
        }
    }

    func addNewProduct(product: Product) -> Observable<String> {
        return Observable.create { observer in
            let database = Firestore.firestore()
            var numberOfProduct = 0
            database.collection("products").getDocuments { snapShot, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    numberOfProduct = snapShot?.count ?? 0
                    let _existProduct = database.collection("products").whereField("name", isEqualTo: product.name)
                    _existProduct.getDocuments { _snapShot, _error in
                        guard let _snapShot = _snapShot else { return }
                        if _snapShot.isEmpty {
                            database.collection("products").addDocument(data: [
                                "id": "HVFP\(numberOfProduct)",
                                "name":  product.name,
                                "price": product.price,
                                "categoryID": product.category.id,
                                "imageName": product.imageName
                            ]) { error in
                                if let error = error {
                                    observer.onError(error)
                                } else {
                                    observer.onNext("Thêm mới sản phẩm thành công!")
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
}
