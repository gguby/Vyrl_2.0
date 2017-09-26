
//
//  SearchViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnActivity: UIButton!
    @IBOutlet weak var searchTableView: UIView!
    
    @IBOutlet weak var placeHolder: UILabel!
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    @IBOutlet weak var btnTag: UIButton!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnFan: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var historySwitch: UISwitch!
    
    var historyOn = false
    
    var historyList = [History]()
    
    var searchObj : SearchObj!
    var tagList = [Tag]()
    var userList = [SearchUser]()
    var fanPageList = [FanPage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        
        initSearchBar()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        searchTable.dataSource = self
        searchTable.delegate = self
        
        self.historyTable.dataSource = self
        self.historyTable.delegate = self

        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.historyTable.tableFooterView = self.historyView
        
        self.loadHistory()
        
        self.historyOn = UserDefaults.standard.bool(forKey: "HistorySearch")
        self.historySwitch.setOn(self.historyOn, animated: false)
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
        
        searchBar.delegate = self
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        self.historyOn = sender.isOn
        UserDefaults.standard.set(self.historyOn, forKey: "HistorySearch")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func removeAllHitory(_ sender: UIButton) {
        self.clearHistory()
    }
    
    @IBAction func hiddenAction(_ sender: Any) {
        btnCancel.isHidden = true
        btnActivity.isHidden = false
        
        searchTableView.isHidden = true
        
        self.placeHolder.isHidden = false
        
        searchBar.resignFirstResponder()
        
        self.tagList.removeAll()
        self.fanPageList.removeAll()
        self.userList.removeAll()
    }
    
    @IBOutlet weak var selectedLine1: UIView!
    @IBOutlet weak var selectedLine2: UIView!
    @IBOutlet weak var selectedLine3: UIView!
    
    var selectedIdx = 1
    
    @IBAction func tagAction(_ sender: UIButton) {
        sender.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        btnFan.setTitleColor(UIColor.black, for: .normal)
        btnUser.setTitleColor(UIColor.black, for: .normal)
        
        selectedLine1.isHidden = false
        selectedLine2.isHidden = true
        selectedLine3.isHidden = true
        
        selectedIdx  = 1
        
        searchTable.reloadData()
        
        placeHolder.isHidden = true
        
        self.loadHistory()
    }
    
    @IBAction func userAction(_ sender: UIButton) {
        sender.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        btnTag.setTitleColor(UIColor.black, for: .normal)
        btnFan.setTitleColor(UIColor.black, for: .normal)
        
        selectedLine1.isHidden = true
        selectedLine2.isHidden = false
        selectedLine3.isHidden = true
        
        selectedIdx  = 2
        
        searchTable.reloadData()
        
        placeHolder.isHidden = true
        
        self.loadHistory()
    }
    
    @IBAction func fanAction(_ sender: UIButton) {
        sender.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        btnTag.setTitleColor(UIColor.black, for: .normal)
        btnUser.setTitleColor(UIColor.black, for: .normal)
        
        selectedLine1.isHidden = true
        selectedLine2.isHidden = true
        selectedLine3.isHidden = false
        
        selectedIdx  = 3
        
        searchTable.reloadData()
        
        placeHolder.isHidden = true
        
        self.loadHistory()
    }
    
    func serializeTuple(tuple: History) -> HistoryDict {
        return [
            "title" : tuple.title,
            "date" : tuple.date
        ]
    }
    
    func deserializeDictionary(dictionary: HistoryDict) -> History {
        return History(
            dictionary["title"] as String!,
            dictionary["date"] as String!
        )
    }
    
    func historyKey() -> String {
        if selectedIdx == 1 {
            return "TagHistoryList"
        }else if selectedIdx == 2 {
            return "UserHistoryList"
        }else {
            return "FanHistoryList"
        }
    }
    
    func loadHistory() {
        
        self.historyList.removeAll()
        
        guard let array = UserDefaults.standard.array(forKey: self.historyKey()) as? [HistoryDict] else {
        
            self.historyTable.reloadData()
            return
        }
        
        for dict in array {
            self.historyList.append(self.deserializeDictionary(dictionary: dict))
        }
        
        self.historyTable.reloadData()
    }
    
    func saveHitory(){
        var array = Array<Any>()
        
        for history in self.historyList {
            array.append(self.serializeTuple(tuple: history))
        }
        
        UserDefaults.standard.set(array, forKey: self.historyKey())
        UserDefaults.standard.synchronize()
    }
    
    func clearHistory(){
        UserDefaults.standard.removeObject(forKey: self.historyKey())
        UserDefaults.standard.synchronize()
        self.historyList.removeAll()
        self.historyTable.reloadData()
    }
    
    func removeHistory(key : String){
        self.historyList = self.historyList.filter{ $0.title != key }
        self.saveHitory()
        self.historyTable.reloadData()
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource , HistoryCellDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == self.searchTable {
            switch self.selectedIdx {
            case 1:
                return self.tagList.count
            case 2:
                return self.userList.count
            case 3:
                return self.fanPageList.count
            default:
                break
            }
            
            return 0
        }else if tableView == self.historyTable {
            return self.historyList.count
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.searchTable {
            
            var ret : CGFloat = 47
            switch selectedIdx {
            case 1:
                ret = 47
            case 2:
                ret = 50
            case 3:
                ret = 72
            default:
                ret = 55
            }
            
            return ret
        }
        else if tableView == self.historyTable {
            return 47
        }
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == self.searchTable {
            switch selectedIdx {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "tagcell") as! TagCell
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "usercell") as! UserCell
                
                let user = self.userList[indexPath.row]
                
                if user.profileImagePath.isEmpty {
                    
                }else {
                    cell.profile.af_setImage(withURL: URL.init(string: user.profileImagePath)!)
                }
                
                cell.title.text = user.nickName
                cell.followers.text = "\(user.followerCount!)"
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "fancell") as! FanCell
                
                let fanPage = self.fanPageList[indexPath.row]
                
                if fanPage.pageprofileImagePath != nil {
                    if fanPage.pageprofileImagePath.isEmpty == false {
                        cell.profile.af_setImage(withURL: URL(string: fanPage.pageprofileImagePath)!)
                    }
                }
                
                cell.members.text = "\(fanPage.cntMember!) members"
                cell.title.text = fanPage.pageName
                cell.intro.text = fanPage.pageInfo
                return cell
            default:
                break
            }
        }else if tableView == self.historyTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
            
            let history = self.historyList[indexPath.row]
            cell.title.text = history.title
            cell.date.text = history.date
            cell.delegate = self
            return cell

        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowCell
            return cell
        }
        
        return UITableViewCell()
    }
    
    func remove(cell: HistoryCell) {
        self.removeHistory(key: cell.title.text!)
    }
    
    func showVC(idx : Int){
        if selectedIdx == 1 {
            
        }else if selectedIdx == 2 {
            let user = self.userList[idx]
            
            let otherProfile = self.pushViewControllrer(storyboardName: "Search", controllerName: "OtherProfile") as! OtherProfileViewController
            otherProfile.profileUserId = user.userId
        }else {
            let fanpage = self.fanPageList[idx]
            let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
            vc.fanPageId = fanpage.fanPageId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.searchTable {
            
            self.showVC(idx: indexPath.row)
            
            if self.historyOn == false {
                return
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM.dd"
            let dateString = formatter.string(from: Date())
            
            self.historyList = self.historyList.filter{ $0.title != self.searchBar.text! }
            historyList.append((self.searchBar.text!, dateString))
            
            self.saveHitory()

        }else if tableView == self.historyTable {
            let history = self.historyList[indexPath.row]
            self.searchBar.text = history.title
            
            self.search(text: self.searchBar.text!)
        }
    }
}

extension SearchViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.postCollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell
            
            return cell
        } else {
          let cell : OfficialCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfficialCollectionCell", for: indexPath) as! OfficialCollectionCell
          
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}

extension SearchViewController {
    
    func clearAll(){
        self.tagList.removeAll()
        self.userList.removeAll()
        self.fanPageList.removeAll()
        self.searchTable.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchTableView.isHidden = false
        
        btnCancel.isHidden = false
        btnActivity.isHidden = true
        
        placeHolder.isHidden = false

        if (searchBar.text?.isEmpty)!  {
            self.historyTable.alpha = 1
            self.historyTable.reloadData()
        }
        return true
    }
    
    func search(text:String){
        self.searchTable.alpha = 1
        self.historyTable.alpha = 0
        
        let uri = Constants.VyrlSearchURL.search(searchWord: text)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseObject { (response: DataResponse<SearchObj>) in
            self.searchObj = response.result.value
            
            self.tagList.removeAll()
            self.userList.removeAll()
            self.fanPageList.removeAll()
            
            self.tagList = self.searchObj.tagList
            self.userList = self.searchObj.userList
            self.fanPageList = self.searchObj.fanPageList
            
            self.searchTable.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {

            self.clearAll()
            
            self.searchTable.alpha = 0
            self.historyTable.alpha = 1
            self.historyTable.reloadData()
            
            self.placeHolder.isHidden = false

            return
        }
        
        self.search(text: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        return true
    }

}

class LeftAlignedSearchBar: UISearchBar, UISearchBarDelegate {
    override var placeholder:String? {
        didSet {
            if #available(iOS 9.0, *) {
                
                if let text = placeholder {
                    if text.characters.last! != " " {
                        // get the font attribute
                        let attr = UITextField.appearance(whenContainedInInstancesOf: [LeftAlignedSearchBar.self]).defaultTextAttributes
                        // define a max size
                        let maxSize = CGSize(width: UIScreen.main.bounds.size.width - 87, height: 40)
                        // let maxSize = CGSize(width:self.bounds.size.width - 92,height: 40)
                        // get the size of the text
                        let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        // get the size of one space
                        let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                        let spaces = floor((maxSize.width - widthText) / widthSpace)
                        // add the spaces
                        let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator: "")))
                        // apply the new text if nescessary
                        if newText != text {
                            placeholder = newText
                        }
                    }
                }
            }
        }
    }
}

extension UIFont {
    class func ivTextStyleFont() -> UIFont? {
        return UIFont(name: "AppleSDGothicNeo-Medium", size: 16.0)
    }
}

extension UIColor {
    class var ivPaleGrey: UIColor {
        return UIColor(red: 242.0 / 255.0, green: 240.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    }
}

class OfficialCollectionCell : UICollectionViewCell {
    
    
    
}

class FollowCell : UITableViewCell {
    
    
    
}

class TagCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var contents: UILabel!
}

class UserCell : UITableViewCell {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var followers: UILabel!
}

class FanCell : UITableViewCell {
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var members: UILabel!
    @IBOutlet weak var intro: UILabel!
}

struct Tag : Mappable {
    var hashTag : String!
    var postCount : Int!
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map){
        hashTag <- map["hashTag"]
        postCount <- map["postCount"]
    }
}

struct SearchUser  : Mappable{
    
    var followerCount : Int!
    var level : String!
    var nickName : String!
    var profileImagePath : String!
    var userId : Int!
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map){
        followerCount <- map["followerCount"]
        level <- map["level"]
        nickName <- map["nickName"]
        profileImagePath <- map["profileImagePath"]
        userId <- map["userId"]
    }
}

struct SearchObj : Mappable {
    
    var fanPageList : [FanPage]!
    var tagList : [Tag]!
    var userList : [SearchUser]!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        fanPageList <- map["fanPageList"]
        tagList <- map["tagList"]
        userList <- map["userList"]
    }
}

