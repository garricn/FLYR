//
//  Observable.swift
//  Pods
//
//  Created by Garric Nahapetian on 10/14/16.
//
//

class Observable<T> {
    var completion: ((T) -> Any)?

    func observe(completion: (T) -> Any) {
        self.completion = completion
    }

    func next(event: T) {
        completion?(event)
    }
}
