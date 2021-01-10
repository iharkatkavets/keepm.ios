//
//  DribbbleTextView.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import os.log

class DribbbleTextView: UITextView {
    let outLog = OSLog(subsystem: "DribbbleTextView", category: String(describing: self))
    let shapeLayer = CALayer()
    var beginEditingToken: NSObjectProtocol? = nil
    var endEditingToken: NSObjectProtocol? = nil

    var borderEditingWidthInternal: CGFloat = 1
    var borderNormalWidthInternal: CGFloat = 1
    var radiusInternal: CGFloat = 5
    var borderNormalColorInternal = UIColor(red: 228/255, green: 230/255, blue: 234.255, alpha: 1)
    var borderEditingColorInternal = UIColor(red: 42/255, green: 145/255, blue: 1, alpha: 1)

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        applyState()
    }

    func setup() {
        backgroundColor = UIColor.clear
        layer.masksToBounds = false

        shapeLayer.masksToBounds = true
        shapeLayer.rasterizationScale = UIScreen.main.scale
        layer.insertSublayer(shapeLayer, at: 0)

        beginEditingToken = NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: self, queue: nil) { [weak self] (notification) in
            self?.applyEditingStateDesign()
        }

        endEditingToken = NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: self, queue: nil) { [weak self] (notification) in
            self?.applyNormalStateDesign()
        }
    }

    @IBInspectable
    public dynamic var borderNormalWidth: CGFloat {
        set {
            borderNormalWidthInternal = newValue
            if #available(iOS 12.0, *) {
                os_log(.info, log: outLog, "setBorderNormalWidth: %{public}f", radiusInternal)
            }
            applyState()
        }
        get { return borderNormalWidthInternal }
    }

    @IBInspectable
       public dynamic var borderEditingWidth: CGFloat {
           set {
               borderEditingWidthInternal = newValue
               if #available(iOS 12.0, *) {
                   os_log(.info, log: outLog, "setBorderEditingWidth: %{public}f", radiusInternal)
               }
               applyState()
           }
           get { return borderEditingWidthInternal }
       }

    @IBInspectable
    public dynamic var radius: CGFloat {
        set {
            radiusInternal = newValue.clamped(to: 0...min(bounds.size.width, bounds.size.height)/2)
            if #available(iOS 12.0, *) {
                os_log(.info, log: outLog, "setRadius: %{public}f", radiusInternal)
            }
            applyState()
        }
        get { return radiusInternal }
    }


    @IBInspectable
    public dynamic var borderNormalColor: UIColor {
        set {
            borderNormalColorInternal = newValue
            applyState()
        }
        get { return borderNormalColorInternal }
    }

    @IBInspectable
    public dynamic var borderEditingColor: UIColor {
        set {
            borderEditingColorInternal = newValue
            applyState()
        }
        get { return borderEditingColorInternal }
    }

    func applyState() {
        if isFirstResponder {
            applyEditingStateDesign()
        }
        else {
            applyNormalStateDesign()
        }
    }

    func applyNormalStateDesign() {
        if #available(iOS 12.0, *) {
            os_log(.info, log: outLog, "applyNormalStateDesign")
        }

        layer.shadowPath = nil
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.backgroundColor = nil
        layer.borderWidth = 0
        layer.cornerRadius = radiusInternal
        layer.borderColor = nil

        shapeLayer.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 248/255, alpha: 1).cgColor
        shapeLayer.bounds = bounds
        shapeLayer.borderColor = borderNormalColor.cgColor
        shapeLayer.borderWidth = borderNormalWidth
        shapeLayer.cornerRadius = radiusInternal
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func applyEditingStateDesign() {
        if #available(iOS 12.0, *) {
            os_log(.info, log: outLog, "applyEditingStateDesign")
        }

        layer.borderWidth = borderEditingWidth;
        layer.borderColor = borderEditingColor.cgColor
        layer.cornerRadius = radiusInternal
        layer.shadowColor = lightShadowColor(borderEditingColor).cgColor
        layer.shadowOffset = CGSize.zero;
        layer.shadowOpacity = 1
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radiusInternal).cgPath
        layer.shadowRadius = 2

        shapeLayer.backgroundColor = UIColor.white.cgColor
        shapeLayer.bounds = bounds
        shapeLayer.borderColor = borderEditingColor.cgColor
        shapeLayer.borderWidth = borderEditingWidth
        shapeLayer.cornerRadius = radiusInternal
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func lightShadowColor(_ color: UIColor) -> UIColor {
        return color.adjustSaturation(by: 0.2)
    }
}

fileprivate extension UIColor {
    func adjustSaturation(by value: CGFloat) -> UIColor {
        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0

        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            s = max(0,s-value)
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }

        return self
    }
}
