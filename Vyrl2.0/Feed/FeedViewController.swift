//
//  FeedViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import RxSwift

import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class FeedViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        registerSwipe()
        
        LoginManager.sharedInstance.checkPush(viewConroller: self)        
        
        self.setupFeedTableView()
    }
    
    func setupFeedTableView (){
        if LoginManager.sharedInstance.isExistFollower == false {
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
}


struct Article : Mappable {
    
    var id : Int!
    var content : String!
    
    var images : [String]!
    var videos : [String]!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        id <- map["id"]
        content <- map["content"]
        images <- map["images"]
        videos <- map["videos"]
    }
}
