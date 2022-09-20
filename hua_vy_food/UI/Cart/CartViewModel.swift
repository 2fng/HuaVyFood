//
//  CartViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 18/09/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct CartViewModel {
    let cartRepository: CartRepositoryType
}

extension CartViewModel {
    struct Input {
        let updateCartTrigger: Driver<Cart>
    }

    struct Output {
        let updateCart: Driver<String>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let updateCart = input.updateCartTrigger
            .flatMapLatest { cart in
                return self.cartRepository.updateCart(cart: cart)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        return Output(updateCart: updateCart,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
