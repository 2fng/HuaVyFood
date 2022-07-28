//
//  ActivityIndicator.swift
//  hua_vy_food
//
//  Created by Hua Son Tung on 28/07/2022.
//

import Foundation
import RxSwift
import RxCocoa

public class ActivityIndicator: SharedSequenceConvertibleType {

    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _variable = BehaviorRelay(value: false)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _variable
            .asDriver()
            .debounce(.microseconds(500))
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.sendStopLoading()
            }, onError: { _ in
                    self.sendStopLoading()
                }, onCompleted: {
                    self.sendStopLoading()
                }, onSubscribe: subscribed)
    }

    private func subscribed() {
        _lock.lock()
        _variable.accept(true)
        _lock.unlock()
    }

    private func sendStopLoading() {
        _lock.lock()
        _variable.accept(false)
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }

    func show(isShow: Bool) {
        _lock.lock()
        _variable.accept(isShow)
        _lock.unlock()
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}
