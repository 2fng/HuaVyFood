//
//  MainViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 20/08/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct MainViewModel {
    let productRepository: ProductRepositoryType
}

extension MainViewModel {
    struct Input {
        let getCategoriesTrigger: Driver<Void>
    }

    struct Output {
        let categories: Driver<[ProductCategory]>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let productCategories = input.getCategoriesTrigger
            .flatMapLatest {
                return self.productRepository.getProductCategories()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(categories: productCategories,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

