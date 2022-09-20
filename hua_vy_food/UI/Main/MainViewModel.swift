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
    let cartRepository: CartRepositoryType
}

extension MainViewModel {
    struct Input {
        let getCategoriesTrigger: Driver<Void>
        let getProductsTrigger: Driver<Void>
        let getCart: Driver<Void>
        let updateCartTrigger: Driver<Cart>
    }

    struct Output {
        let categories: Driver<[ProductCategory]>
        let products: Driver<[Product]>
        let cart: Driver<Cart>
        let updateCart: Driver<String>
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

        let cart = input.getCart
            .flatMapLatest {
                return self.cartRepository.getCart()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let updateCart = input.updateCartTrigger
            .flatMapLatest { cart in
                return self.cartRepository.updateCart(cart: cart)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        return Output(categories: productCategories,
                      products: products,
                      cart: cart,
                      updateCart: updateCart,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
