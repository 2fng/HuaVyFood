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
        let getProductsTrigger: Driver<Void>
    }

    struct Output {
        let categories: Driver<[ProductCategory]>
        let products: Driver<[Product]>
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

        let products = input.getProductsTrigger
            .flatMapLatest {
                return self.productRepository.getProducts()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(categories: productCategories,
                      products: products,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

