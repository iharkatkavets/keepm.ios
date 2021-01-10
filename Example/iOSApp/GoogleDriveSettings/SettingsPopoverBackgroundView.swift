//
//  SettingsPopoverBackgroundView.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 1/6/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class SettingsPopoverBackgroundView: UIPopoverBackgroundView {
    let arrowImageView: UIImageView
    let backgroundImageView: UIImageView
    let cornerRadius: CGFloat = 15

    override init(frame: CGRect) {
        arrowImageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                   width: SettingsPopoverBackgroundView.arrowBase(),
                                                   height: SettingsPopoverBackgroundView.arrowHeight()))
        backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        backgroundImageView.layer.cornerRadius = cornerRadius;
        backgroundImageView.layer.masksToBounds = true;
        super.init(frame: frame)

        addSubview(arrowImageView)
        addSubview(backgroundImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupImages() {
        let arrowSize = CGSize(width: SettingsPopoverBackgroundView.arrowBase(),
                               height: SettingsPopoverBackgroundView.arrowHeight())
        arrowImageView.image = ImageBuilder.popoverArrowFitInSize(arrowSize)
        backgroundImageView.image = ImageBuilder.popoverBackgroundWithSize(CGSize(width: 25, height: 25))
    }

    override var arrowDirection: UIPopoverArrowDirection {
        set {
            setNeedsDisplay()
        }
        get {
            return .up
        }
    }

    var arrowOffsetInternal: CGFloat = 0
    override var arrowOffset: CGFloat {
        get {
            return arrowOffsetInternal
        }
        set {
            arrowOffsetInternal = newValue
            setNeedsDisplay()
        }
    }

    override class var wantsDefaultContentAppearance: Bool {
        return true
    }

    override class func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }

    override class func arrowHeight() -> CGFloat {
        return 15
    }

    override class func arrowBase() -> CGFloat {
        return 35
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupImages()
    }

    override func layoutSubviews() {
        let arrowHeight = SettingsPopoverBackgroundView.arrowHeight()
        var backgroundFrame = self.frame
        var arrowCenter = CGPoint.zero
        var arrowTransformationInRadians: CGFloat = 0

        if (arrowDirection == .up) {
            backgroundFrame.origin.y += arrowHeight
            backgroundFrame.size.height -= arrowHeight
            arrowTransformationInRadians = 0
            arrowCenter = CGPoint(x: backgroundFrame.size.width*0.5+arrowOffset-SettingsPopoverBackgroundView.contentViewInsets().right-cornerRadius,
                                  y: arrowHeight*0.5)
        }
        else if (arrowDirection == .down) {

        }
        else if (arrowDirection == .left) {

        }
        else if arrowDirection == .right {

        }

        backgroundImageView.frame = backgroundFrame
        arrowImageView.center = arrowCenter
        arrowImageView.transform = CGAffineTransform(rotationAngle: arrowTransformationInRadians)
    }

}
