//
//  AppImage.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 2/4/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CoreGraphics

struct ImageBuilder {
    static func popoverArrowFitInSize(_ size: CGSize) -> UIImage {
        let context = createContext(size)

        context?.beginPath()
        context?.setStrokeColor(AppColors[.popover].cgColor)
        context?.setFillColor(AppColors[.popover].cgColor)
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: size.width*0.5, y: size.height))
        context?.addLine(to: CGPoint(x: size.width, y: 0))
        context?.closePath()
        context?.drawPath(using: .fillStroke)

        if let cgImage = context?.makeImage() {
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        }

        return UIImage()
    }

    static func createContext(_ size: CGSize) -> CGContext? {
        let bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(bounds.size.width), height: Int(bounds.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        return context
    }

    static func popoverBackgroundWithSize(_ size: CGSize) -> UIImage {
        let context = createContext(size)

        context?.beginPath()
        context?.setStrokeColor(AppColors[.popover].cgColor)
        context?.setFillColor(AppColors[.popover].cgColor)
        context?.addRect(CGRect(origin: CGPoint.zero, size: size))
        context?.closePath()
        context?.drawPath(using: .fillStroke)

        if let cgImage = context?.makeImage() {
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        }

        return UIImage()
    }

    static func addCustomFieldButton(_ size: CGSize) -> UIImage {
        let context = createContext(size)

        context?.beginPath()
        context?.setFillColor(AppColors[.secondary].cgColor)
        context?.addRect(CGRect(origin: CGPoint.zero, size: size))
        context?.closePath()
        context?.drawPath(using: .fill)

        if let cgImage = context?.makeImage() {
            var uiImage = UIImage(cgImage: cgImage)
            let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            uiImage = uiImage.resizableImage(withCapInsets: insets)
            return uiImage
        }

        return UIImage()
    }

    static func deleteButton(_ size: CGSize) -> UIImage {
        let context = createContext(size)

        context?.beginPath()
        context?.setFillColor(AppColors[.error].cgColor)
        context?.addRect(CGRect(origin: CGPoint.zero, size: size))
        context?.closePath()
        context?.drawPath(using: .fill)

        if let cgImage = context?.makeImage() {
            var uiImage = UIImage(cgImage: cgImage)
            let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            uiImage = uiImage.resizableImage(withCapInsets: insets)
            return uiImage
        }

        return UIImage()
    }

    static func popupButton(_ size: CGSize) -> UIImage {
        let context = createContext(size)

        context?.beginPath()
        context?.setFillColor(AppColors[.secondary].cgColor)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let bezier = UIBezierPath(roundedRect: rect, cornerRadius: 5)
        context?.addPath(bezier.cgPath)
        context?.closePath()
        context?.drawPath(using: .fill)

        if let cgImage = context?.makeImage() {
            var uiImage = UIImage(cgImage: cgImage)
            let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            uiImage = uiImage.resizableImage(withCapInsets: insets)
            return uiImage
        }

        return UIImage()
    }

    static func errorButton(_ size: CGSize) -> UIImage {
        let context = createContext(size)

        context?.beginPath()
        context?.setFillColor(AppColors[.error].cgColor)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let bezier = UIBezierPath(roundedRect: rect, cornerRadius: 5)
        context?.addPath(bezier.cgPath)
        context?.closePath()
        context?.drawPath(using: .fill)

        if let cgImage = context?.makeImage() {
            var uiImage = UIImage(cgImage: cgImage)
            let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            uiImage = uiImage.resizableImage(withCapInsets: insets)
            return uiImage
        }

        return UIImage()
    }
}
