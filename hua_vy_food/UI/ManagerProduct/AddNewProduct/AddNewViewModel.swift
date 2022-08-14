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
        let addNewProductTextFieldTrigger: Driver<String>
        let addNewCategoryTrigger: Driver<Void>
    }

    struct Output {
        let addNewProduct: Driver<String>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let addNewProduct = input.addNewCategoryTrigger
            .withLatestFrom(input.addNewProductTextFieldTrigger)
            .flatMapLatest { categoryName in
                return self.productRepository.addNewCategory(categoryName: categoryName)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(addNewProduct: addNewProduct,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
