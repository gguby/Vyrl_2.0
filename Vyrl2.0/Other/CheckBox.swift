//
//  CheckBox.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 23..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

protocol checkBoxDelegate {
    func respondCheckBox(checkBox : CheckBox)
}

class CheckBox : UIButton
{
    var delegate: checkBoxDelegate?
    
    let checkedImage = UIImage(named: "icon_check_03_on")! as UIImage
    let uncheckedImage = UIImage(named: "icon_check_03_off")! as UIImage
    
    var label : UILabel?
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
                label?.textColor = UIColor.ivLighterPurple
            } else {
                self.setImage(uncheckedImage, for: .normal)
                label?.textColor = UIColor.ivGreyish
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
            delegate?.respondCheckBox(checkBox: self)
        }
    }
}

fileprivate let minimumHitArea = CGSize(width: 100, height: 100)

extension CheckBox {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}

extension UIColor {
    class var ivGreyishBrown: UIColor {
        return UIColor(red: 83.0 / 255.0, green: 79.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)
    }
    
    class var ivGreyishBrownTwo: UIColor {
        return UIColor(red: 62.0 / 255.0, green: 58.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
    }
    
    class var ivGreyish: UIColor {
        return UIColor(white: 172.0 / 255.0, alpha: 1.0)
    }
    
    class var ivLighterPurple: UIColor {
        return UIColor(red: 128.0 / 255.0, green: 82.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    }
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

