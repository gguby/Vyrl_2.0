//
//  FeedViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit


class FeedViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var feedTtile: UILabel!
    @IBOutlet weak var selectImageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        registerSwipe()
        
        LoginManager.sharedInstance.checkPush(viewConroller: self)        
        
        self.setupFeedTableView()
    }
    
    func setupFeedTableView (){
        if LoginManager.sharedInstance.isExistFollower == false {
            self.containerView.translatesAutoresizingMaskIntoConstraints  = false
            let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "feedTable")
            addChildViewController(controller)
            containerView.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
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
            
            feedView?.feedType = FeedTableType.MYFEED
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

