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
    
    func pushModal(storyboardName : String, controllerName : String)-> UIViewController {
        let storyboard = UIStoryboard(name:storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: controllerName)
        self.present(controller, animated: true, completion: nil)
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
    
    func selectTab(index : Int){
        tabBarController?.selectedIndex = index
    }
    
    func registerSwipe(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func showToast(str: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = appDelegate.rootViewController
        vc?.showToast(string: str)
    }
    
    func showLoading(show : Bool){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = appDelegate.rootViewController
        
        UIView.animate(withDuration: 1.0, animations: {
            vc?.loadingImageView.alpha = CGFloat(show ? 0 : 1)
        }) { (true) in
            UIView.animate(withDuration: 1.0, animations: {
                vc?.loadingImageView.alpha = CGFloat(show ? 1 : 0)
            })
        }
    }
}

class ViewController: UITabBarController , UITabBarControllerDelegate {
    
    lazy var loadingImageView : UIImageView = {
        let imageView = UIImageView()
        
        var images: Array<UIImage> = []
        images.append(UIImage.init(named: "icon_loader_01_1")!)
        images.append(UIImage.init(named: "icon_loader_01_2")!)
        images.append(UIImage.init(named: "icon_loader_01_3")!)
        
        imageView.animationImages = images;
        imageView.animationDuration = 5;
        imageView.startAnimating()
        
        return imageView
    }()
    
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
    
    func setupLoadingView(){
        if !self.loadingImageView.isDescendant(of: self.view){
            
            self.loadingImageView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(loadingImageView)
            
            loadingImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            loadingImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            
            self.loadingImageView.alpha = 0
        }
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
        
        self.setupLoadingView()
        
        self.setupTabbar()

        self.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.rootViewController = self
    }
    
    func setupTabbar(){
        
        var tabBar = (self.tabBar.items?[0])! as UITabBarItem
        tabBar.image = UIImage.init(named: "icon_home_01_off")
        tabBar.selectedImage = UIImage.init(named: "icon_home_01_on")
        
        tabBar = (self.tabBar.items?[1])! as UITabBarItem
        tabBar.image = UIImage.init(named: "icon_fan_01_off")
        tabBar.selectedImage = UIImage.init(named: "icon_fan_01_on")
        
        tabBar = (self.tabBar.items?[2])! as UITabBarItem
        tabBar.image = UIImage.init(named: "icon_write_01_off")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBar.selectedImage = UIImage.init(named: "icon_write_01_on")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        tabBar = (self.tabBar.items?[3])! as UITabBarItem
        tabBar.image = UIImage.init(named: "icon_search_01_off")
        tabBar.selectedImage = UIImage.init(named: "icon_search_01_on")
        
        tabBar = (self.tabBar.items?[4])! as UITabBarItem
        tabBar.image = UIImage.init(named: "icon_user_01_off")
        tabBar.selectedImage = UIImage.init(named: "icon_user_01_on")
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
        }else if viewController.title == "feed" {
            let vc = viewController.childViewControllers.last as! FeedViewController            
            vc.refresh()
        }
        return true
    }

}

