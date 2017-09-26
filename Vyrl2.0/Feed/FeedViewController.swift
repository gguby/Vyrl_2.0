//
//  FeedViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

class FeedViewController: UIViewController {
    
    @IBOutlet weak var feedTtile: UILabel!
    @IBOutlet weak var selectImageview: UIImageView!
    
    var embedController : EmbedController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        registerSwipe()
        
        LoginManager.sharedInstance.checkPush(viewConroller: self)
        
        embedController = EmbedController.init(rootViewController: self)
        
        self.setupFeedTableView()
    }

//    func checkExistFollow() {
//        let uri = Constants.VyrlAPIConstants.baseURL + "/follows/exists"
//        
//        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseJSON(completionHandler: {
//            response in switch response.result {
//            case .success(let json):
//                
//                DispatchQueue.main.async {
//                    let jsonData = json as! NSDictionary
//                    
//                    let isExistFollow = jsonData["exist"] as! Bool
//                    
//                    LoginManager.sharedInstance.isExistFollower = isExistFollow
//                    
//                    self.setupFeedTableView()
//                }
//                
//            case .failure(let error):
//                print(error)
//            }
//        })
//    }
    
    func refresh(){
        if embedController.controllers.last != nil {
            let vc = embedController.controllers.last as! FeedTableViewController
            vc.getAllFeed()
        }
    }
    
    func setupFeedTableView (){
//        if LoginManager.sharedInstance.isExistFollower == true {
            let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "feedTable") as! FeedTableViewController
            controller.feedView = self
            
            controller.view.frame.origin = CGPoint.init(x: 0, y: 66)
            controller.view.frame.size.height -= 66
            
            embedController.append(viewController: controller)
//        }else {
//            embedController.remove()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeFeed(_ sender: UIButton) {
        self.showAlert()
    }
    
    func showAlert() {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let feedView = appDelegate.feedView
        
        let allFeedAction = UIAlertAction(title: "All Feed", style: .default,handler: { (action) -> Void in
            self.feedTtile.text = "전체 피드"
            self.selectImageview.image = UIImage.init(named: "btn_select_down_02")
            
            feedView?.feedType = FeedTableType.ALLFEED
            feedView?.getAllFeed()
            
            alertController.dismiss(animated: true, completion: nil )
        })
        let myFeedAction = UIAlertAction(title: "My Feed", style: .default, handler: { (action) -> Void in
            self.feedTtile.text = "내 피드"
            self.selectImageview.image = UIImage.init(named: "btn_select_down_02")
            
            feedView?.feedType = FeedTableType.MYFEED
            feedView?.getAllFeed()
            
            alertController.dismiss(animated: true, completion: nil)
        })
        let fanFeedAction = UIAlertAction(title: "Fan Feed", style: .default, handler: { (action) -> Void in
            self.feedTtile.text = "팬 피드"
            self.selectImageview.image = UIImage.init(named: "btn_select_down_02")
            
            feedView?.feedType = FeedTableType.FANALLFEED
            feedView?.getAllFeed()
            
            alertController.dismiss(animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(allFeedAction)
        alertController.addAction(myFeedAction)
        alertController.addAction(fanFeedAction)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: {
            self.selectImageview.image = UIImage.init(named: "btn_select_up_01")
        })
    }
}

class EmbedController {
    
    public private(set) weak var rootViewController: UIViewController?
    
    public private(set) var controllers = [UIViewController]()
    
    init (rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    func append(viewController: UIViewController) {
        if let rootViewController = self.rootViewController {
            for controller in controllers {
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
            }
            controllers.removeAll()
            controllers.append(viewController)
            rootViewController.addChildViewController(viewController)
            rootViewController.view.addSubview(viewController.view)
        }
    }
    
    func remove(){
        if let rootViewController = self.rootViewController {
            for controller in controllers {
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
            }
            controllers.removeAll()
        }
    }
    
    deinit {
        if self.rootViewController != nil {
            for controller in controllers {
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
            }
            controllers.removeAll()
            self.rootViewController = nil
        }
    }
}
