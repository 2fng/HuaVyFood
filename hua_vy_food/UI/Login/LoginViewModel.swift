//
//  LoginViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/07/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct LoginViewModel {
    let userRepository: UserRepositoryType
}

extension LoginViewModel {
    struct Input {
        let emailTrigger: Driver<String>
        let passwordTrigger: Driver<String>
        let loginTrigger: Driver<Void>
    }

    struct Output {
        let login: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let login = input.loginTrigger
            .withLatestFrom(Driver.combineLatest(
                input.emailTrigger,
                input.passwordTrigger))
            .flatMapLatest { email, password in
                self.userRepository.login(email: email, password: password)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: { userSignIn in
                if let userSignIn = userSignIn {
                    UserManager.shared.setUserID(userSignIn.uid)
                    UserManager.shared.setIsAdmin(userSignIn.isAdmin)
                }
            })
            .mapToVoid()

        return Output(login: login,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
