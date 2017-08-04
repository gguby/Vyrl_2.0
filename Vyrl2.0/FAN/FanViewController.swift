//
//  FanViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class FanViewController: UIViewController {
    
    @IBOutlet weak var joinFanpageCollectionView: UICollectionView!
    
    @IBOutlet weak var joinFanPageHeight: NSLayoutConstraint!
    @IBOutlet weak var recommandFanpageTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var searchTableView: UIView!
    
    var joinFanPages = [FanPage]()
    var suggestFanPages = [FanPage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        
        initSearchBar()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.getMyFanPage()
        
        self.getSuggesetFanPage()
    }
    
    func initSearchBar()
    {
        searchBar.setImage(UIImage.init(named: "icon_search_02_off"), for: UISearchBarIcon.search, state: UIControlState.normal)
        searchBar.placeholder = "검색"
        searchBar.backgroundImage = UIImage()
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.clear
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.font = UIFont.ivTextStyleFont()
        
    }
    
    @IBAction func hiddenAction(_ sender: Any) {
        searchTableView.isHidden = true;
        searchBar.resignFirstResponder()
    }
    
    func enableEmptyView(){
        if (self.joinFanPages.count == 0 ){
            self.joinFanPageHeight.constant = 197.5
            self.joinFanpageCollectionView.alpha = 0
        } else {
            self.joinFanPageHeight.constant = 334
            self.joinFanpageCollectionView.alpha = 1
        }
    }
    
    func getMyFanPage(){
        
        let uri = Constants.VyrlFanAPIURL.FANPAGELIST
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[FanPage]>) in
            
            self.joinFanPages.removeAll()
            
            let array = response.result.value ?? []
            
            for fan in array {
                self.joinFanPages.append(fan)
            }
            
            self.joinFanpageCollectionView.reloadData()
            
            self.enableEmptyView()
        }
    }
    
    func getSuggesetFanPage(){
        
        let uri = Constants.VyrlFanAPIURL.SUGGESTFANPAGELIST
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[FanPage]>) in
            
            self.suggestFanPages.removeAll()
            
            let array = response.result.value ?? []
            
            for fan in array {
                self.suggestFanPages.append(fan)
            }
            
            self.recommandFanpageTableView.reloadData()
        }
    }
    
    @IBAction func createFanPage(_ sender: Any) {
        self.pushView(storyboardName: "FanDetail", controllerName: "FanPageCreateViewController")
    }
}

class FanCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}

extension FanViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FanCollectionCell
        
        let fan = self.joinFanPages[indexPath.row]
        
        cell.imageView.af_setImage(withURL: URL.init(string: fan.pageprofileImagePath)!)
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.joinFanPages.count
    }
}

class RecommendFanPageCell : UITableViewCell {
    @IBOutlet weak var profile: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var member: UILabel!
    
    @IBAction func remove(_ sender: Any) {
    }
    
    @IBAction func follow(_ sender: Any) {
    }
}

extension FanViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.suggestFanPages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {        
        if(tableView == self.searchTable)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfficialBannerCell", for: indexPath) as UITableViewCell
            return cell
        } else if(tableView == self.recommandFanpageTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecommandFanpageCell", for: indexPath) as! RecommendFanPageCell
            
            let fan = self.suggestFanPages[indexPath.row]
            
            cell.profile.af_setImage(withURL: URL.init(string: fan.pageprofileImagePath)!)
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension FanViewController : UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchTableView.isHidden = false
        return true
    }
}

struct FanPage : Mappable {
    
    var fanPageId : Int!
    var level : String!
    var link : String!
    var nickName : String!
    var pageInfo : String!
    var pageName : String!
    var pageprofileImagePath : String!
    
    var cntPost : Int!
    var cntMember : Int!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        fanPageId <- map["fanPageId"]
        level <- map["level"]
        link <- map["link"]
        nickName <- map["nickName"]
        pageInfo <- map["pageInfo"]
        pageName <- map["pageName"]
        pageprofileImagePath <- map["profileImagePath"]
        cntPost <- map["postCount"]
        cntMember <- map["memberCount"]
    }
}
