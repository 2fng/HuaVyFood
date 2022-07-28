//
//  ObservableType+.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/07/2022.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {

    public func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    public func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { _ in
            return Driver.empty()
        }
    }

    public func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }

    public func mapToOptional() -> Observable<Element?> {
        return map { value -> Element? in value }
    }

    public func unwrap<T>() -> Observable<T> where Element == T? {
        return flatMap { Observable.from(optional: $0) }
    }
}
