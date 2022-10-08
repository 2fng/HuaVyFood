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
        let deleteResponseTrigger: Driver<String>
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
                return self.userRepository.getResponse()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let deleteResponse = input.deleteResponseTrigger
            .flatMap { documentID in
                return self.userRepository.deleteResponse(id: documentID)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(responses: responses.asDriver(),
                      deleteResponse: deleteResponse.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}
