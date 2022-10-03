//
//  UserResponseViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 03/10/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct UserResponseViewModel {
    let userRepository: UserRepositoryType
}

extension UserResponseViewModel {
    struct Input {
        let submitResponseTrigger: Driver<String>
    }

    struct Output {
        let response: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let response = input.submitResponseTrigger
            .flatMapLatest { content in
                return self.userRepository.submitResponse(content: content)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(response: response.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
