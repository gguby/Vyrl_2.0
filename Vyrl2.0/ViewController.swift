//
//  ViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Google

extension UIViewController
{
    func trackScreenView(screenName: String) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: screenName)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    @IBAction func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func pushView(storyboardName : String, controllerName : String ){
        let storyboard = UIStoryboard(name:storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: controllerName)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                //right view controller
                tabBarController?.selectedIndex = (tabBarController?.selectedIndex)! + 1
                break
            case UISwipeGestureRecognizerDirection.left:
                //left view controller
                tabBarController?.selectedIndex = (tabBarController?.selectedIndex)! - 1
            default:
                break
            }
        }
    }
    
    func registerSwipe(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
}

class ViewController: UITabBarController {
    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 45
        tabFrame.origin.y = self.view.frame.size.height - 45
        self.tabBar.frame = tabFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

