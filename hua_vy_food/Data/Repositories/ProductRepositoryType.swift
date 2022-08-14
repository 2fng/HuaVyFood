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
    func addNewCategory(categoryName: String) -> Observable<String>
}

final class ProductRepository: ProductRepositoryType {
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
}
