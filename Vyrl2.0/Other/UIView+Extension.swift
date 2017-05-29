//
//  UIView+Extension.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 5. 29..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

//
// Inspectable - Design and layout for View
// cornerRadius, borderWidth, borderColor
//
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
}


