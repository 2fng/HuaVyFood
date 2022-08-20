//
//  AddNewViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 14/08/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct AddNewViewModel {
    let productRepository: ProductRepositoryType
}

extension AddNewViewModel {
    struct Input {
        let getProductCategories: Driver<Void>
        let addNewProductTextFieldTrigger: Driver<String>
        let addNewCategoryTrigger: Driver<Void>
        let submitTrigger: Driver<Product>
    }

    struct Output {
        let addNewCategory: Driver<String>
        let productCategories: Driver<[ProductCategory]>
        let addNewProduct: Driver<String>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let addNewCategory = input.addNewCategoryTrigger
            .withLatestFrom(input.addNewProductTextFieldTrigger)
            .flatMapLatest { categoryName in
                return self.productRepository.addNewCategory(categoryName: categoryName)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let productCategories = input.getProductCategories
            .flatMapLatest {
                return self.productRepository.getProductCategories()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
        
        let addNewProduct = input.submitTrigger
            .flatMapLatest { product in
                return self.productRepository.addNewProduct(product: product)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(addNewCategory: addNewCategory,
                      productCategories: productCategories,
                      addNewProduct: addNewProduct,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
