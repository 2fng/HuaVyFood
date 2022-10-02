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
        let getOrderStatusTrigger: Driver<Void>
        let getPaymentStatusTrigger: Driver<Void>
        let updateOrderStatusTrigger: Driver<Order>
        let updateOrderPaymentStatusTrigger: Driver<Order>
    }

    struct Output {
        let getOrders: Driver<[Order]>
        let statuses: Driver<[OrderStatus]>
        let paymentStatus: Driver<[String]>
        let updateOrderStatus: Driver<Void>
        let updateOrderPaymentStatus: Driver<Void>
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

        let getStatuses = input.getOrderStatusTrigger
            .flatMapLatest { _ in
                return self.userRepository.getOrderStatuses()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let getPaymentStatus = input.getPaymentStatusTrigger
            .flatMapLatest { _ in
                return self.userRepository.getPaymentStatus()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let updateOrderStatus = input.updateOrderStatusTrigger
            .flatMapLatest { order in
                return self.userRepository.updateOrderStatus(order: order)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        let updateOrderPaymentStatus = input.updateOrderPaymentStatusTrigger
            .flatMapLatest { order in
                return self.userRepository.updateOrderPaymentStatus(order: order)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        return Output(getOrders: getOrders.asDriver(),
                      statuses: getStatuses.asDriver(),
                      paymentStatus: getPaymentStatus.asDriver(),
                      updateOrderStatus: updateOrderStatus.asDriver(),
                      updateOrderPaymentStatus: updateOrderPaymentStatus.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
