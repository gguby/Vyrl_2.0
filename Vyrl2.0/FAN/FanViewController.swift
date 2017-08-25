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

protocol FanViewControllerDelegate {
    func refresh()
}

class FanViewController: UIViewController {
    
    @IBOutlet weak var joinFanpageCollectionView: UICollectionView!
    
    @IBOutlet weak var joinFanPageHeight: NSLayoutConstraint!
    @IBOutlet weak var recommandFanpageTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var searchTableView: UIView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var postView: UIView!
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    var joinFanPages = [FanPage]()
    var suggestFanPages = [FanPage]()
    var searchResults = [FanPage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        
        self.setupPostContainer()
        
        initSearchBar()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.getMyFanPage()
        
        self.getSuggesetFanPage()
        
        self.recommandFanpageTableView.tableFooterView = UIView(frame: .zero)
        self.searchTable.tableFooterView = UIView(frame: .zero)
    }
    
    func setupPostContainer(){
        self.container.translatesAutoresizingMaskIntoConstraints  = false
        let storyboard = UIStoryboard(name: "PostCollectionViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostCollection")
        addChildViewController(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
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
        self.searchResults.removeAll()
        self.searchTable.reloadData()
        self.emptyLabel.alpha = 1
        searchBar.resignFirstResponder()
    }
    
    func enableEmptyView(){
        if (self.joinFanPages.count == 0 ){
            self.joinFanPageHeight.constant = 197.5
            self.joinFanpageCollectionView.alpha = 0
            self.emptyView.alpha = 1
        } else {
            self.joinFanPageHeight.constant = 334
            self.joinFanpageCollectionView.alpha = 1
            self.emptyView.alpha = 0
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

extension FanViewController : FanViewControllerDelegate {
    func refresh() {
        self.getMyFanPage()
    }
}

class FanCollectionCell : UICollectionViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
}

extension FanViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == self.joinFanPages.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "createFan", for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FanCollectionCell
        
        let fan = self.joinFanPages[indexPath.row]
        
        if fan.pageprofileImagePath.isEmpty == false {
            cell.imageView.af_setImage(withURL: URL.init(string: fan.pageprofileImagePath)!)
        }
        cell.textView.text = fan.pageName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if ( self.joinFanPages.count > 5 ){
            return 6
        }
        
        return self.joinFanPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if cell?.reuseIdentifier == "createFan" {
            let vc = self.pushViewControllrer(storyboardName: "FanDetail", controllerName: "FanPageCreateViewController") as! FanPageCreateViewController
            vc.delegate = self
        } else {
            let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
            vc.fanPage = self.joinFanPages[indexPath.row]        
        }
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
        if tableView == self.searchTable {
            return self.searchResults.count
        }
        
        return self.suggestFanPages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {        
        if(tableView == self.searchTable)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fanSearch", for: indexPath) as! FanCell
            let fanPage = self.searchResults[indexPath.row]
            
            cell.profile.af_setImage(withURL: URL(string: fanPage.pageprofileImagePath)!)
            cell.members.text = "\(fanPage.cntMember!) members "
            cell.title.text = fanPage.pageName
            cell.intro.text = fanPage.pageInfo
            
            return cell
        } else if(tableView == self.recommandFanpageTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecommandFanpageCell", for: indexPath) as! RecommendFanPageCell
            
            let fan = self.suggestFanPages[indexPath.row]
            
            if fan.pageprofileImagePath.isEmpty == false {
                cell.profile.af_setImage(withURL: URL.init(string: fan.pageprofileImagePath)!)
            }
            
            cell.title.text = fan.pageName
            cell.member.text = "\(fan.cntMember!) members"
            cell.detail.text = fan.pageInfo
            
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.searchResults.removeAll()
            self.searchTable.reloadData()
            self.emptyLabel.alpha = 1
            return
        }
        
        let uri = Constants.VyrlFanAPIURL.search(searchWord: searchText)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[FanPage]>) in
            
            self.searchResults.removeAll()
            let array  = response.result.value ?? []
            
            if array.isEmpty {
                self.emptyLabel.alpha = 1
            }else {
                self.emptyLabel.alpha = 0
            }
            
            self.searchResults.append(contentsOf: array)
            
            self.searchTable.reloadData()
        }
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
        nickName <- map["nickname"]
        pageInfo <- map["pageInfo"]
        pageName <- map["pageName"]
        pageprofileImagePath <- map["profileImagePath"]
        cntPost <- map["postCount"]
        cntMember <- map["memberCount"]
    }
}
