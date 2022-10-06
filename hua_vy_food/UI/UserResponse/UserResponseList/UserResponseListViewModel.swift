//
//  UserResponseListViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 06/10/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct UserResponseListViewModel {
    let userRepository: UserRepositoryType
}

extension UserResponseListViewModel {
    struct Input {
        let getResponseTrigger: Driver<Void>
    }

    struct Output {
        let responses: Driver<[Response]>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let responses = input.getResponseTrigger
            .flatMapLatest {
                return self.userRepository.getUserResponse()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(responses: responses.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

