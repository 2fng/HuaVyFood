//
//  SharedSequenceConvertibleType+.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 30/07/2022.
//

import Foundation
import RxSwift
import RxCocoa

private let kErrorMessage = "`drive*` family of methods can be only called from `MainThread`.\n" +
    "This is required to ensure that the last replayed `Driver` element is delivered on `MainThread`.\n"

extension SharedSequenceConvertibleType {

    public func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }

    public func mapToOptional() -> SharedSequence<SharingStrategy, Element?> {
        return map { value -> Element? in value }
    }

    public func unwrap<T>() -> SharedSequence<SharingStrategy, T> where Element == T? {
        return flatMap { SharedSequence.from(optional: $0) }
    }
}

extension SharedSequenceConvertibleType where Element == Bool {
    public func not() -> SharedSequence<SharingStrategy, Bool> {
        return map(!)
    }

    public static func or(_ sources: SharedSequence<DriverSharingStrategy, Bool>...)
        -> SharedSequence<DriverSharingStrategy, Bool> {
            return Driver.combineLatest(sources)
                .map { $0.contains { $0 } }
    }

    public static func and(_ sources: SharedSequence<DriverSharingStrategy, Bool>...)
        -> SharedSequence<DriverSharingStrategy, Bool> {
            return Driver.combineLatest(sources)
                .map { $0.allSatisfy { $0 } }
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    public func drive<Observer: ObserverType>(_ observers: Observer...) -> Disposable where Observer.Element == Element {
        MainScheduler.ensureRunningOnMainThread(errorMessage: kErrorMessage)
        return self.asSharedSequence()
            .asObservable()
            .subscribe { e in
                observers.forEach { $0.on(e) }
            }
    }
}
