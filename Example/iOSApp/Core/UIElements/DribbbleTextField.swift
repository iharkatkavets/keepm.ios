//
//  DribbbleTextField.swift
//  DribbbleTextField
//
//  Created by Igor Kotkovets on 2/23/20.
//

import UIKit
import os.log

class DribbbleTextField: UITextField {
    let outLog = OSLog(subsystem: "NeuTextField", category: String(describing: self))
    let shadowLayer = CALayer()
    let shapeLayer = CALayer()
    var beginEditingToken: NSObjectProtocol? = nil
    var endEditingToken: NSObjectProtocol? = nil

    var borderEditingWidthInternal: CGFloat = 1
    var borderNormalWidthInternal: CGFloat = 1

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyState()
    }

    func setup() {
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        shadowLayer.masksToBounds = false
        layer.addSublayer(shadowLayer)

        shapeLayer.rasterizationScale = UIScreen.main.scale
        layer.addSublayer(shapeLayer)

        beginEditingToken = NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self, queue: nil) { [weak self] (notification) in
            self?.applyEditingStateDesign()
        }

        endEditingToken = NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: self, queue: nil) { [weak self] (notification) in
            self?.applyEditingStateDesign()
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

    var radiusInternal: CGFloat = 5
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

    var borderColorNormalInternal = UIColor(red: 228/255, green: 230/255, blue: 234.255, alpha: 1)
    @IBInspectable
    public dynamic var borderColorNormal: UIColor {
        set {
            borderColorNormalInternal = newValue
        }
        get { return borderColorNormalInternal }
    }

    var borderColorEditingInternal = UIColor(red: 42/255, green: 145/255, blue: 1, alpha: 1)
    @IBInspectable
    public dynamic var borderColorEditing: UIColor {
        set {
            borderColorEditingInternal = newValue
        }
        get { return borderColorEditingInternal }
    }

    public override var isEnabled: Bool {
        set {
            if #available(iOS 12.0, *) {
                os_log(.info, log: outLog, "setEnabled:: %{public}s", newValue ? "true":"false")
            }
            super.isEnabled = newValue
        }
        get {
            return super.isEnabled
        }
    }

    func applyState() {
        if isEditing {
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

        shadowLayer.shadowPath = nil
        shadowLayer.shadowColor = nil
        shadowLayer.shadowOpacity = 0
        shadowLayer.bounds = bounds
        shadowLayer.cornerRadius = radiusInternal
        shadowLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        shapeLayer.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 248/255, alpha: 1).cgColor
        shapeLayer.bounds = bounds
        shapeLayer.borderColor = borderColorNormal.cgColor
        shapeLayer.borderWidth = borderNormalWidthInternal
        shapeLayer.cornerRadius = radiusInternal
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func applyEditingStateDesign() {
        if #available(iOS 12.0, *) {
            os_log(.info, log: outLog, "applyEditingStateDesign")
        }

        shadowLayer.borderWidth = borderEditingWidthInternal;
        shadowLayer.shadowRadius = 2
        shadowLayer.backgroundColor = UIColor.clear.cgColor
        shadowLayer.bounds = bounds
        shadowLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shadowLayer.cornerRadius = radiusInternal
        shadowLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shadowLayer.shadowColor = lightShadowColor(borderColorEditing).cgColor
        shadowLayer.shadowOffset = CGSize.zero;
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radiusInternal).cgPath


        shapeLayer.backgroundColor = UIColor.white.cgColor
        shapeLayer.bounds = bounds
        shapeLayer.borderColor = borderColorEditing.cgColor
        shapeLayer.borderWidth = borderEditingWidthInternal
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

