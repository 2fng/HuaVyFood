//
//  DetailProductViewModel.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 02/01/2023.
//

import Foundation
import Then
import RxSwift
import RxCocoa

struct DetailProductViewModel {
    let productRepository: ProductRepositoryType
}

extension DetailProductViewModel {
    struct Input {
        let updateLikeAndDislikeStatusTrigger: Driver<(Bool, String)>
    }

    struct Output {
        let likeAndDislikeStatus: Driver<Void>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let likeAndDislikeStatus = input.updateLikeAndDislikeStatusTrigger
            .flatMapLatest { (isLike, productID) -> Driver<Void> in
                return self.productRepository.updateLikeAndDislikeStatus(productID: productID, isLike: isLike)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()

        return Output(likeAndDislikeStatus: likeAndDislikeStatus.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

