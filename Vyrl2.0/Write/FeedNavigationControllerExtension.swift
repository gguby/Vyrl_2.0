//
//  FeedNavigationControllerExtension.swift
//  Transition
//
//  Created by Gabor Csontos on 12/23/16.
//  Copyright © 2016 GaborMajorszki. All rights reserved.
//

import UIKit


public extension UINavigationController {
    
    
    var parentTargetView: UIView {
        return view
    }
    
    func si_presentViewController(toViewController:UIViewController, completion: (() -> Void)?) {
        
        toViewController.beginAppearanceTransition(true, animated: true)
        ModalAnimatorPhoto.present(toViewController.view, fromView: parentTargetView) { [weak self] in
            guard let strongself = self else { return }
            toViewController.endAppearanceTransition()
            toViewController.didMove(toParentViewController: strongself)
        }
    }
    
    func si_dismissModalView(toViewController:UIViewController, completion: (() -> Void)?){
    
        
        ModalAnimatorPhoto.dismiss(toViewController.view, fromView: parentTargetView, completion: {
            
            _ in completion?()
        
        })
            
    }
    
    func si_dissmissOnBottom(toViewController:UIViewController, kbSize : CGSize , completion: (() -> Void)?){
        
        
        ModalAnimatorPhoto.dismissOnBottom(toViewController.view, fromView: parentTargetView, completion: {
            
            _ in completion?()
            
        })
    }
    
    func si_showFullScreen(toViewController:UIViewController,completion: (() -> Void)?){
        
        ModalAnimatorPhoto.showOnfullScreen(toViewController.view, fromView: parentTargetView, completion: {
            
            _ in completion?()
            
        })
    }


    
}
