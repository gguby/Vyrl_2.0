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
    
    func pop()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func back(){
        self.pop()
    }
    
    func goSearch(){
        tabBarController?.selectedIndex = 3
    }
    
    func pushView(storyboardName : String, controllerName : String ){
        let storyboard = UIStoryboard(name:storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: controllerName)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushViewControllrer(storyboardName : String, controllerName : String) -> UIViewController {
        let storyboard = UIStoryboard(name:storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: controllerName)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
        return controller
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

class ViewController: UITabBarController , UITabBarControllerDelegate {
    
    lazy var toastView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.85)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var toastLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14.0)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override func viewWillLayoutSubviews() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 45
        tabFrame.origin.y = self.view.frame.size.height - 45
        self.tabBar.frame = tabFrame
    }
    
    func setupToasView(){
        if !toastView.isDescendant(of: self.view) {
            
            self.view.addSubview(toastView)
            
            toastView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            toastView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            toastView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            toastView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            toastView.heightAnchor.constraint(equalToConstant: 45).isActive = true
            
            self.toastView.frame.origin.y = self.view.frame.size.height
            
            self.toastView.alpha = 0
            
            if !toastLabel.isDescendant(of: toastView){
                toastView.addSubview(toastLabel)
                toastLabel.centerXAnchor.constraint(equalTo: toastView.centerXAnchor).isActive = true
                toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor).isActive = true
            }
        }
    }
    
    func showToast(string : String){
        
        self.toastLabel.text = string
        
        UIView.animate(withDuration: 1.0, animations: {
            self.toastView.alpha = 1
            self.toastView.frame.origin.y = self.view.frame.size.height - 45
        }) { (true) in
            UIView.animate(withDuration: 1.0, animations: {
                self.toastView.frame.origin.y = self.view.frame.size.height
                self.toastView.alpha = 0
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupToasView()
        
//        self.showToast(string: "!")
        
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title == "WriteNavi" {
            let storyboard = UIStoryboard(name: "Write", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "writenavi") as? UINavigationController
            present(vc!, animated: true, completion: nil)
            return false
        }
        return true
    }

}

