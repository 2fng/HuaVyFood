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
        let deleteOrderTrigger: Driver<String>
    }

    struct Output {
        let getOrders: Driver<[Order]>
        let userShippingInfo: Driver<UserShippingInfo>
        let deleteOrder: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let getOrders = input.getOrdersTrigger
            .flatMapLatest { _ in
                return self.userRepository.getUserOrders(isAdmin: false)
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

        let deleteOrder = input.deleteOrderTrigger
            .flatMapLatest { documentID in
                return self.userRepository.deleteOrder(documentID: documentID)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(getOrders: getOrders.asDriver(),
                      userShippingInfo: userShippingInfo.asDriver(),
                      deleteOrder: deleteOrder.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
