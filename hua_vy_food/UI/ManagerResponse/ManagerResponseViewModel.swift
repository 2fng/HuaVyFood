//
//  ManagerResponseViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 06/10/2022.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct ManagerResponseViewModel {
    let userRepository: UserRepositoryType
}

extension ManagerResponseViewModel {
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
                return self.userRepository.getResponse()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(responses: responses.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
