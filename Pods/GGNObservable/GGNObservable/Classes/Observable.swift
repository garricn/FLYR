//
//  GGNObservable.swift
//  Pods
//
//  Created by Garric Nahapetian on 10/18/16.
//
//

import Foundation

/// The `GGNObservable` class can be used for simple reactive style programming. This class has a generic type constraint.
public class Observable<T> {
    // MARK: - Initialization
    /**
     Initializes an instance of an `Obersvable` that's constrained to generic type `T`.
     
     - Example: `let alertOutput = Observable<UIAlertController>()`
    */
    public init() {}

    // MARK: - Properties
    /**
     This typealias exists mainly for convenience, however it's type is important. `Closure` is an `optional` function that takes an instance of the generic type `T` and returns `Void`.
     
     - parameter T: A function that takes a `T`
     
     - Returns: `Void`
    */
    public typealias Closure = ((T) -> Void)
    private var closures: [Closure] = []

    // MARK: - Methods
    /**
     Call this method on an instance of `Observable` to respond to events emitted from it. This method captures the passed in closure, stores it, and performs it when `emit(event:)` is called on the same instance of `Observable`. One `Observable` can have multiple observers.
     
     - parameter closure: The closure to perform on `emit(event:)`.
     
     - Example: `viewModel.alertOutput.onNext { [weak self] alert in self?.presentViewController(alert, animated: true, completion: nil) }`
    */
    public func onNext(perform closure: Closure) {
        self.closures.append(closure)
    }

    /**
     Call this method on an instance of `Observable` to emit an instance of the generic type `T`. This method performs any and all closures that are captured by calls to `onNext(perform:)`.
    
     - parameter event: An instance of the generic type `T`.
     
     - Example: `alertOutput.emit(alert)`
    */
    public func emit(event: T) {
        closures.forEach { emit in
            emit(event)
        }
    }
}
