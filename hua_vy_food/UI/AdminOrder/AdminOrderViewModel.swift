//
//  AdminOrderViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 01/10/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct AdminOrderViewModel {
    let cartRepository: CartRepositoryType
    let userRepository: UserRepositoryType
}

extension AdminOrderViewModel {
    struct Input {
        let getOrdersTrigger: Driver<Void>
    }

    struct Output {
        let getOrders: Driver<[Order]>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let getOrders = input.getOrdersTrigger
            .flatMapLatest { _ in
                return self.userRepository.getUserOrders(isAdmin: true)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(getOrders: getOrders.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
