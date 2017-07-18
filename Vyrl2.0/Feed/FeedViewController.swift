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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        registerSwipe()
        print("Feed");
        
        LoginManager.sharedInstance.checkPush(viewConroller: self)
        
        self.getAllFeed()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "Test") {
            let secondViewController = segue.destination as! FeedTableViewController
        }
    }
    
    func getAllFeed(){
        
        let url = URL.init(string: Constants.VyrlAPIURL.feedWrite)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            let array = response.result.value ?? []
            
            for article in array {
                print(article.id)
            }
        }
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
