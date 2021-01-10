//
//  SpinnerView.swift
//  SpinnerView
//
//  Created by Igor Kotkovets on 4/15/20.
//

import Foundation
import UIKit
import os.log
import RxSwift
import RxCocoa

@IBDesignable public class SpinnerView: UIView {

    @IBInspectable dynamic public var lineColor: UIColor = UIColor.red {
        didSet {
            animatedLayer.strokeColor = lineColor.cgColor
        }
    }

    @IBInspectable public var lineWidth: CGFloat = 4 {
        didSet {
            updateLayerPosition()
        }
    }
    @IBInspectable public var animationDuration: CFTimeInterval = 4

    private var isAnimatingInternal: Bool = false
    @IBInspectable public var isAnimating: Bool {
        get {
            return isAnimatingInternal
        }
        set {
            isAnimatingInternal = newValue
            self.animatedLayer.isHidden = !isAnimatingInternal;
            if isAnimatingInternal {
                startAnimation()
            }
            else {
                stopAnimation()
            }
        }
    }

    var angleRad: CGFloat = (330*2*CGFloat.pi/360)
    var angleDegree: CGFloat = 330 {
        didSet {
            angleRad = 2*CGFloat.pi*angleDegree/360
            updateLayerPosition()
        }
    }
    var outLog = OSLog(subsystem: "SpinnerView", category: String(describing: self))

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        layer.isHidden = !isAnimatingInternal
    }

    override public class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateLayerPosition()
    }

    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerPosition()
    }

    override public func prepareForInterfaceBuilder() {
        animatedLayer.path = UIBezierPath(ovalIn: circleFrame).cgPath
        updateLayerPosition()
        prepareLayerForAnimation()
    }

    var animatedLayer: CAShapeLayer {
        return layer as! CAShapeLayer
    }

    var circleFrame: CGRect {
        return bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2)
    }

    func updateLayerPosition() {
        let radius = (bounds.size.width-lineWidth)/2
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: 0,
                                endAngle: angleRad,
                                clockwise: true)
        animatedLayer.path = path.cgPath
    }

    func updateAnimationState() {
        if isAnimating {
            startAnimation()
        }
    }

    let STROKE_ANIMATION_KEY = "animatingStrokeStart"
    let ROTATION_ANIMATION_KEY = "animatingRotate"

    func startAnimation() {
        prepareLayerForAnimation()

        if  animatedLayer.animation(forKey: STROKE_ANIMATION_KEY) == nil {
            forwardAnimation()
        }

        if animatedLayer.animation(forKey: ROTATION_ANIMATION_KEY) == nil {
            rotateAnimation()
        }
    }

    private func prepareLayerForAnimation() {
        animatedLayer.fillColor = UIColor.clear.cgColor
        animatedLayer.strokeStart = 0
        animatedLayer.strokeColor = lineColor.cgColor
        animatedLayer.lineWidth = lineWidth
    }

    func forwardAnimation() {
        CATransaction.begin()
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = 0
        strokeEnd.toValue = 1
        strokeEnd.duration = animationDuration/2
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
        strokeEnd.timingFunction = CAMediaTimingFunction(name: .linear)
        CATransaction.setCompletionBlock{ [weak self] in
            guard self?.isAnimating == true else { return }
            self?.reverseAnimation()
        }
        animatedLayer.add(strokeEnd, forKey: STROKE_ANIMATION_KEY)
        CATransaction.commit()
    }

    fileprivate func rotateAnimation() {
        CATransaction.begin()
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = 2*CGFloat.pi
        rotate.repeatCount = MAXFLOAT
        rotate.autoreverses = false
        rotate.duration = animationDuration/4
        animatedLayer.add(rotate, forKey: ROTATION_ANIMATION_KEY)
        CATransaction.commit()
    }

    func reverseAnimation() {
        CATransaction.begin()
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = animatedLayer.presentation()?.strokeEnd
        strokeEnd.toValue = 0
        strokeEnd.duration = animationDuration/2
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
        strokeEnd.timingFunction = CAMediaTimingFunction(name: .easeIn)
        CATransaction.setCompletionBlock{ [weak self] in
            guard self?.isAnimating == true else { return }
            self?.forwardAnimation()
        }
        animatedLayer.add(strokeEnd, forKey: STROKE_ANIMATION_KEY)
        CATransaction.commit()
    }

    func stopAnimation() {
        animatedLayer.removeAnimation(forKey: ROTATION_ANIMATION_KEY)
        animatedLayer.removeAnimation(forKey: STROKE_ANIMATION_KEY)
    }
}

extension Reactive where Base: SpinnerView {
    public var isAnimating: Binder<Bool> {
        return Binder(self.base) { view, isAnimating in
            view.isAnimating = isAnimating
        }
    }
}
