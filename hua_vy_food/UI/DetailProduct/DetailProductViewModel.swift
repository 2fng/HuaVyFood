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
    let cartRepository: CartRepositoryType
}

extension DetailProductViewModel {
    struct Input {
        let updateLikeAndDislikeStatusTrigger: Driver<(Bool, String)>
        let getLikeAndDislikeTrigger: Driver<String>
        let updateCartTrigger: Driver<Cart>
        let commentTrigger: Driver<(String, String)>
        let getCommentTrigger: Driver<String>
    }

    struct Output {
        let likeAndDislike: Driver<(Int, Bool, Bool)>
        let likeAndDislikeStatus: Driver<Void>
        let updateCart: Driver<Void>
        let productComment: Driver<Void>
        let comments: Driver<[Comment]>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }

    func transform(_ input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let activityIndicator = ActivityIndicator()

        let getLikeAndDislike = input.getLikeAndDislikeTrigger
            .flatMapLatest { productID -> Driver<(Int, Bool, Bool)> in
                return self.productRepository.getProductLikeAndDislike(productID: productID)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let likeAndDislikeStatus = input.updateLikeAndDislikeStatusTrigger
            .flatMapLatest { (isLike, productID) -> Driver<Void> in
                return self.productRepository.updateLikeAndDislikeStatus(productID: productID, isLike: isLike)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let updateCart = input.updateCartTrigger
            .flatMapLatest { cart in
                return self.cartRepository.updateCart(cart: cart)
                    .mapToVoid()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }

        let submitComment = input.commentTrigger
            .flatMapLatest { productID, comment in
                return self.productRepository.submitProductComment(productID: productID, comment: comment)
                    .mapToVoid()
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        let comments = input.getCommentTrigger
            .flatMapLatest { productID in
                return self.productRepository.getProductComments(productID: productID)
                    .trackError(errorTracker)
                    .trackActivity(activityIndicator)
                    .asDriverOnErrorJustComplete()
            }

        return Output(likeAndDislike: getLikeAndDislike.asDriver(),
                      likeAndDislikeStatus: likeAndDislikeStatus.asDriver(),
                      updateCart: updateCart.asDriver(),
                      productComment: submitComment.asDriver(),
                      comments: comments.asDriver(),
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
}

