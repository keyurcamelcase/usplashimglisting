//
//  BasicStuff.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 13/04/24.
//

import Foundation
import UIKit

extension UIView {
    func addShadow(_ color:CGColor = UIColor.gray.cgColor) {
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 4
        layer.masksToBounds = false
        clipsToBounds = false
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}


extension Notification.Name {
    static let internetStatusChanged = Notification.Name("internetStatusChanged")
}


