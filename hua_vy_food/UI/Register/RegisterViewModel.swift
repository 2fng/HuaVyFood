//
//  RegisterViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/07/2022.
//

import Foundation
import RxSwift
import RxCocoa

struct RegisterViewModel {
    let userRepository: UserRepositoryType
}

extension RegisterViewModel {
    struct Input {
        let emailTrigger: Driver<String>
        let passwordTrigger: Driver<String>
        let confirmPasswordTrigger: Driver<String>
        let registerTrigger: Driver<Void>
    }

    struct Output {
        let register: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let register = input.registerTrigger
            .withLatestFrom(Driver.combineLatest(
                input.emailTrigger,
                input.passwordTrigger,
                input.confirmPasswordTrigger))
            .flatMapLatest { email, password, confirmPassword in
                self.userRepository.register(email: email, password: password)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: {
                print("Register successfully!")
            })

        return Output(register: register,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
