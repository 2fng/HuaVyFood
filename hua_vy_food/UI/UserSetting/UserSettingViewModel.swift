//
//  UserSettingViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 06/08/2022.
//

import Foundation
import RxSwift
import RxCocoa

struct UserSettingViewModel {
    let userRepository: UserRepositoryType
}

extension UserSettingViewModel {
    struct Input {
        let logoutTrigger: Driver<Void>
    }

    struct Output {
        let logout: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let logout = input.logoutTrigger
            .flatMapLatest {
                self.userRepository.logout()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: {
                UserManager.shared.clearUser()
            })
            .mapToVoid()

        return Output(logout: logout,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
