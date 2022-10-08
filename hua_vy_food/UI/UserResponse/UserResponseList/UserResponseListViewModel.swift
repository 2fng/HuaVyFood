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
        let deleteResponeTrigger: Driver<String>
    }

    struct Output {
        let responses: Driver<[Response]>
        let deleteResponse: Driver<Void>
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

        let deleteResponse = input.deleteResponeTrigger
            .flatMap { doucmentID in
                return self.userRepository.deleteResponse(id: doucmentID)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(responses: responses.asDriver(),
                      deleteResponse: deleteResponse,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

