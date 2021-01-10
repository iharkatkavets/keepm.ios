//
//  GoogleDriveOperation.swift
//  iOSApp
//
//  Created by igork on 9.01.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

open class GoogleDriveOperation: Operation {
    public enum State: String {
        case ready, executing, finished

        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    public var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    open override var isReady: Bool {
        return super.isReady && state == .ready
    }

    open override var isExecuting: Bool {
        return state == .executing
    }

    open override var isFinished: Bool {
        return state == .finished
    }

    open override func start() {
        if isCancelled {
            state = .finished
            return
        }

        main()
        state = .executing
    }

    open override func cancel() {
        super.cancel()
        state = .finished
    }
}
