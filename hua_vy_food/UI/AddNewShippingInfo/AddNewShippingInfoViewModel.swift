//
//  AddNewShippingInfoViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 22/09/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct AddNewShippingInfoViewModel {
    let userRepository: UserRepositoryType
}

extension AddNewShippingInfoViewModel {
    struct Input {
        let updateUserShippingInfoTrigger: Driver<UserShippingInfo>
    }

    struct Output {
        let updateUserShippingInfo: Driver<String>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let updateUserShippingInfo = input.updateUserShippingInfoTrigger
            .flatMapLatest { profile in
                return self.userRepository.addNewShippingInfoProfile(profile: profile)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(updateUserShippingInfo: updateUserShippingInfo.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

