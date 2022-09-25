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
    let userRepository: UserRepositoryType
}

extension CartViewModel {
    struct Input {
        let updateCartTrigger: Driver<Cart>
        let userShippingInfoTrigger: Driver<Void>
    }

    struct Output {
        let updateCart: Driver<String>
        let userShippingInfo: Driver<UserShippingInfo>
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

        let userShippingInfo = input.userShippingInfoTrigger
            .flatMapLatest { _ in
                return self.userRepository.getUserShippingInfo()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(updateCart: updateCart,
                      userShippingInfo: userShippingInfo,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
