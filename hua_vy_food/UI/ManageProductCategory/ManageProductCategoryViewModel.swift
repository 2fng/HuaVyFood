//
//  ManageProductCategoryViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/09/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct ManageProductCategoryViewModel {
    let productRepository: ProductRepositoryType
}

extension ManageProductCategoryViewModel {
    struct Input {
        let getProductCategoryTrigger: Driver<Void>
        let addNewCategoryTrigger: Driver<String>
        let updateCategoryTrigger: Driver<ProductCategory>
        let deleteCategoryTrigger: Driver<String>
    }

    struct Output {
        let productCategories: Driver<[ProductCategory]>
        let addNewProductCategory: Driver<String>
        let updateCategory: Driver<Void>
        let deleteCategory: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let productCategories = input.getProductCategoryTrigger
            .flatMapLatest {
                return self.productRepository.getProductCategories()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let addNewProductCategory = input.addNewCategoryTrigger
            .flatMapLatest { categoryName in
                return self.productRepository.addNewCategory(categoryName: categoryName)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let updateCategory = input.updateCategoryTrigger
            .flatMapLatest { category in
                return self.productRepository.updateCategory(category: category)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let deleteCategory = input.deleteCategoryTrigger
            .flatMapLatest { documentID in
                return self.productRepository.deleteCategory(documentID: documentID)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }


        return Output(productCategories: productCategories.asDriver(),
                      addNewProductCategory: addNewProductCategory.asDriver(),
                      updateCategory: updateCategory.asDriver(),
                      deleteCategory: deleteCategory.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
