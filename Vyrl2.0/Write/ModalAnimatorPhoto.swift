//
//  ModalAnimatorPhoto.swift
//  Transition
//
//  Created by Gabor Csontos on 12/22/16.
//  Copyright © 2016 GaborMajorszki. All rights reserved.
//

import UIKit
import Photos

public func PhotoAutorizationStatusCheck() -> Bool {
    
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
        return true
    case .denied, .restricted,.notDetermined:
        PHPhotoLibrary.authorizationStatus()
        return false
        
    }
}

public class ModalAnimatorPhoto {
    
    static var isKeyboardMode : Bool = false
    static var keyboardSize : CGSize = CGSize(width: 0, height: 0)

    public class func present(_ toView: UIView, fromView: UIView, completion: @escaping () -> Void) {
        
        var y : CGFloat = 221.0
        if ( isKeyboardMode ){
            y = fromView.bounds.size.height - keyboardSize.height - 44
        }
    
        var toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: y)
        toViewFrame.size.height = toViewFrame.size.height
        toView.frame = toViewFrame
        
        toView.alpha = 0.0
        
        fromView.addSubview(toView)
        
        UIView.animate(
            withDuration: 0.2,
            animations: { () -> Void in

                let toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: y)
                toView.frame = toViewFrame
                
                toView.alpha = 1.0
                
        }) { (result) -> Void in
            
            completion()
            
        }

    }
    
    public class func dismiss(_ toView: UIView, fromView: UIView, completion: @escaping () -> Void) {
        
        var y : CGFloat = 221.0
        if ( isKeyboardMode ){
            y = fromView.bounds.size.height
        }

        //Checking PhotoAutorizationStatus
        if PhotoAutorizationStatusCheck() {
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                
                let toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: y)
            
                toView.frame = toViewFrame
                
            }) { (result) -> Void in
                
                completion()
            }
            
        } else {
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                
                let toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: y)
               
                toView.frame = toViewFrame
                
            }) { (result) -> Void in
                
                completion()
            }
        }
    }
    
    public class func dismissOnBottom(_ toView: UIView, fromView: UIView, completion: @escaping () -> Void) {
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            
            let toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: fromView.bounds.size.height - keyboardSize.height - 44)
            toView.frame = toViewFrame
            
        }) { (result) -> Void in
            
            completion()
        }
        
    }

    public class func showOnfullScreen(_ toView: UIView, fromView: UIView, completion: @escaping () -> Void) {
        
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            
            let toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: statusBarHeight)
            toView.frame = toViewFrame
            
        }) { (result) -> Void in
            
            completion()
        }
        
    }
    
}
