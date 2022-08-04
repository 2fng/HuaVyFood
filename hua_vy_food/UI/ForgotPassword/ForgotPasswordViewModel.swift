//
//  ForgotPasswordViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 04/08/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct ForgotPasswordViewModel {
    let userRepository: UserRepositoryType
}

extension ForgotPasswordViewModel {
    struct Input {
        let emailTrigger: Driver<String>
        let submitTrigger: Driver<Void>
    }

    struct Output {
        let submit: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let submit = input.submitTrigger
            .withLatestFrom(input.emailTrigger)
            .flatMapLatest { email in
                self.userRepository.forgotPassword(email: email)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .mapToVoid()

        return Output(submit: submit,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

