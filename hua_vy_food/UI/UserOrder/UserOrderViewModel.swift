//
//  UserOrderViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 01/10/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct UserOrderViewModel {
    let cartRepository: CartRepositoryType
    let userRepository: UserRepositoryType
}

extension UserOrderViewModel {
    struct Input {
        let getOrdersTrigger: Driver<Void>
        let userShippingInfoTrigger: Driver<Void>
    }

    struct Output {
        let getOrders: Driver<[Order]>
        let userShippingInfo: Driver<UserShippingInfo>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let getOrders = input.getOrdersTrigger
            .flatMapLatest { _ in
                return self.userRepository.getUserOrders()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let userShippingInfo = input.userShippingInfoTrigger
            .flatMapLatest { _ in
                return self.userRepository.getUserShippingInfo()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(getOrders: getOrders.asDriver(),
                      userShippingInfo: userShippingInfo.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
