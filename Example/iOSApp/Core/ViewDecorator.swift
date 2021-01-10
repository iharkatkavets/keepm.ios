//
//  ViewDecorator.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

protocol ViewDecorator: class {
    associatedtype View: Decoratable
    func decorate(view: View)
}

protocol Decoratable {
    func decorate<T: ViewDecorator>(with decorator: T) where T.View == Self
}

extension Decoratable where Self: UIView {
    func decorate<T: ViewDecorator>(with decorator: T) where T.View == Self {
        decorator.decorate(view: self)
    }
}
