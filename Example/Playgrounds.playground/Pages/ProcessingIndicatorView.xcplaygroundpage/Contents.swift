//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import PlaygroundsUI

let indicatorView = SpinnerView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
PlaygroundPage.current.liveView = indicatorView
indicatorView.isAnimating = true
indicatorView.lineColor = UIColor.green

//: [Next](@next)
