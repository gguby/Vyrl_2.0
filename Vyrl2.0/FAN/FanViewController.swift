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

protocol ReCommendCellDelegate {
    func joinFanPage(cell : RecommendFanPageCell)
}

protocol HistoryCellDelegate {
    func remove(cell : HistoryCell)
}

typealias History = (title: String, date: String)
typealias HistoryDict = [String:String]

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
    @IBOutlet weak var more: UIButton!
    
    @IBOutlet weak var histroyView: UIView!
    @IBOutlet weak var historyTable: UITableView!
    
    @IBOutlet weak var historySwitch: UISwitch!
    var historyList = [History]()
    
    var moreCount : Int = 1
    var joinFanPages = [FanPage]()
    var suggestFanPages = [SuggestFanPage]()
    var searchResults = [FanPage]()
    
    var historyOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        
        self.setupPostContainer()
        
        initSearchBar()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.recommandFanpageTableView.tableFooterView = UIView(frame: .zero)
        self.searchTable.tableFooterView = UIView(frame: .zero)
        self.historyTable.tableFooterView = self.histroyView
        
        self.loadHistory()
        
        self.historyOn = UserDefaults.standard.bool(forKey: "HistorySearch")
        self.historySwitch.setOn(self.historyOn, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getMyFanPage()
        self.getSuggesetFanPage()
    }
    
    func setupPostContainer(){
        let storyboard = UIStoryboard(name: "PostCollectionViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostCollection") as! PostCollectionViewController
        addChildViewController(controller)
        
        controller.view.frame.size.height = self.container.frame.height
        controller.type = .Fan
        
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
    
    @IBAction func clearHistory(_ sender: Any) {
        self.clearHistory()
    }
    
    @IBAction func historySwitchAction(_ sender: UISwitch) {
        self.historyOn = sender.isOn
        UserDefaults.standard.set(self.historyOn, forKey: "HistorySearch")
        UserDefaults.standard.synchronize()
    }
    
    func enableEmptyView(){
        if (self.joinFanPages.count == 0 ){
            self.joinFanPageHeight.constant = 197.5
            self.joinFanpageCollectionView.alpha = 0
            self.emptyView.alpha = 1
            self.more.isHidden = true
        } else {
            self.joinFanPageHeight.constant = 334
            self.joinFanpageCollectionView.alpha = 1
            self.emptyView.alpha = 0
            
            if (self.joinFanPages.count > 6){
                self.more.isHidden = false
            } else {
                self.more.isHidden = true
            }
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
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[SuggestFanPage]>) in
            
            self.suggestFanPages.removeAll()
            
            let array = response.result.value ?? []
            
            for fan in array {
                self.suggestFanPages.append(fan)
            }
            
            self.recommandFanpageTableView.reloadData()
        }
    }
    
    @IBAction func createFanPage(_ sender: Any) {
        let vc = self.pushViewControllrer(storyboardName: "FanDetail", controllerName: "FanPageCreateViewController") as! FanPageCreateViewController
        vc.delegate = self
    }
    
    @IBAction func moreFanPage(_ sender: UIButton) {
        if (self.joinFanPages.count > 6 ){
            
            let fanPageHeight = 334 + (167 * moreCount)
            self.joinFanPageHeight.constant = CGFloat(fanPageHeight)
            self.joinFanpageCollectionView.alpha = 1
            self.emptyView.alpha = 0
            self.more.isHidden = true
            
            moreCount += 1
            self.joinFanpageCollectionView.reloadData()
        }
    }
    
    func showJoinAlert(fanPageId : Int){
        let alertController = UIAlertController (title:nil, message:"가입되었습니다. 가입된 팬페이지로 바로 이동 하시겠습니까?",preferredStyle:.alert)
        let ok = UIAlertAction(title: "네", style: .default, handler: { (action) -> Void in
            let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
            vc.fanPageId = fanPageId
            vc.delegate = self
        })
        let cancel = UIAlertAction(title: "아니오", style: .cancel, handler: { (action) -> Void in
        })
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
  
}

extension FanViewController : FanViewControllerDelegate {
    func refresh() {
        self.getMyFanPage()
        self.getSuggesetFanPage()
    }
}

extension FanViewController : ReCommendCellDelegate {
    
    func joinFanPage(cell: RecommendFanPageCell) {
        let uri = URL.init(string: Constants.VyrlFanAPIURL.joinFanPage(fanPageId: cell.fanPage.fanPageId))
        Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                self.showJoinAlert(fanPageId: cell.fanPage.fanPageId)
                self.refresh()
                print(json)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension FanViewController : HistoryCellDelegate {
    func remove(cell: HistoryCell) {
        self.removeHistory(key: cell.title.text!)
    }
}

class FanCollectionCell : UICollectionViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurImgView: UIImageView!
}

extension FanViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == self.joinFanPages.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "createFan", for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FanCollectionCell
        
        let fan = self.joinFanPages[indexPath.row]
        
        if fan.pageprofileImagePath.isEmpty == false {
            cell.imageView.af_setImage(withURL: URL.init(string: fan.pageprofileImagePath)!)
            cell.blurImgView.af_setImage(withURL: URL.init(string: fan.pageprofileImagePath)!)
        }else {
            if fan.randomImage != 0 {
                let str = "img_fanbg_default_0\(fan.randomImage!)"
                cell.imageView.image = UIImage.init(named: str)
                cell.blurImgView.image = UIImage.init(named: str)
            }
        }
        cell.textView.text = fan.pageName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if ( self.joinFanPages.count > 5 ){
            
            let count = 6 * moreCount
            if(count > self.joinFanPages.count)
            {
                self.more.isHidden = true
                return self.joinFanPages.count
            } else {
                return count
            }
        }
        
        return self.joinFanPages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if cell?.reuseIdentifier == "createFan" {
            let vc = self.pushViewControllrer(storyboardName: "FanDetail", controllerName: "FanPageCreateViewController") as! FanPageCreateViewController
            vc.delegate = self
        } else {
            let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
            vc.fanPageId = self.joinFanPages[indexPath.row].fanPageId
            vc.delegate = self
        }
    }
}

class RecommendFanPageCell : UITableViewCell {
    @IBOutlet weak var profile: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var member: UILabel!
    
    var delegate : ReCommendCellDelegate!
    
    var fanPage : SuggestFanPage! {
        didSet{
            if fanPage.pageprofileImagePath.isEmpty == false {
                self.profile.af_setImage(withURL: URL.init(string: fanPage.pageprofileImagePath)!)
            }
            
            self.title.text = fanPage.pageName
            self.member.text = "\(fanPage.cntMember!) members"
            self.detail.text = fanPage.pageInfo
        }
    }
    
    @IBAction func remove(_ sender: Any) {
    }
    
    @IBAction func follow(_ sender: Any) {
        delegate.joinFanPage(cell: self)
    }
}

extension FanViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == self.searchTable {
            return self.searchResults.count
        }
        else if tableView == self.historyTable {
            return historyList.count
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
            
            cell.delegate = self
            cell.fanPage = fan
            
            return cell
        }
        else if tableView == self.historyTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
            
            let history = self.historyList[indexPath.row]
            cell.title.text = history.title
            cell.date.text = history.date
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == self.searchTable) {
            let fanPage = self.searchResults[indexPath.row]
            let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
            vc.fanPageId = fanPage.fanPageId
            vc.delegate = self
            
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
        }
        else {
            let fanPage = self.suggestFanPages[indexPath.row]
            let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
            vc.fanPageId = fanPage.fanPageId
            vc.delegate = self
        }
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
    
    func loadHistory() {
        guard let array = UserDefaults.standard.array(forKey: "FanHistoryList") as? [HistoryDict] else { return }
        
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
        
        UserDefaults.standard.set(array, forKey: "FanHistoryList")
        UserDefaults.standard.synchronize()
    }
    
    func clearHistory(){
        UserDefaults.standard.removeObject(forKey: "FanHistoryList")
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

extension FanViewController : UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchTableView.isHidden = false
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.historyTable.alpha = 0
        self.search(searchText: searchBar.text!)
    }
    
    func search(searchText : String ){
        
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.searchResults.removeAll()
            self.searchTable.reloadData()
            self.historyTable.alpha = 1
            self.emptyLabel.alpha = 1
            self.historyTable.reloadData()
            return
        }
        
        self.historyTable.alpha = 0
        
        self.search(searchText: searchText)
    }
}

class HistoryCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var delegate : HistoryCellDelegate!
    
    @IBAction func remove(_ sender: Any) {
        delegate.remove(cell: self)
    }
}

struct FanPageArticle : Mappable {
    
    var bookmark : Bool!
    var cntComment : Int!
    var cntLike : Int!
    var cntShare : Int!
    var cntView : Int!
    var comments : [Comment]!

    
    var content : String!
    var date : Date?
    var fanPageId : Int!
    var fanPagePostId : Int!
    var likeCheck : Bool!
    var medias : [FanPageArticleMedia]!
    
    var openYn : Bool!
    var profile : Profile!
    var shareCheck : Bool!
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        bookmark <- map["bookmark"]
        cntComment <- map["cntComment"]
        cntLike <- map["cntLike"]
        cntShare <- map["cntShare"]
        cntView <- map["cntView"]
        comments <- map["comments"]

        
        content <- map["content"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date
        }
        
        fanPageId <- map["fanPageId"]
        fanPagePostId <- map["fanPagePostId"]
        likeCheck <- map["likeCheck"]
        medias <- map["media"]
        openYn <- map["openYn"]
        profile <- map["profile"]
        shareCheck <- map["shareCheck"]
        
    }
}

struct FanPageArticleMedia : Mappable {
    var mediaId : Int!
    var thumbnail : String?
    var type : String?
    var url : String?
    var fileSize :Int64?
    var mbFileSize : Int64?
    var imageUrl : String!
    var seq : Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        mediaId <- map["mediaId"]
        seq <- map["seq"]
        thumbnail <- map["thumbnail"]
        type <- map["type"]
        url <- map["url"]
        
        if type! == "IMAGE" {
            imageUrl = url
        } else {
            imageUrl = thumbnail
        }
        
        fileSize <- map["size"]
        mbFileSize = fileSize! / 1024 / 1024
    }
    
}

struct SuggestFanPage : Mappable {
    
    var fanPageId : Int!
    var pageInfo : String!
    var pageName : String!
    var pageprofileImagePath : String!
    
    var cntMember : Int!
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        fanPageId <- map["fanPageId"]
        pageInfo <- map["pageInfo"]
        pageName <- map["pageName"]
        pageprofileImagePath <- map["profileImagePath"]
        cntMember <- map["memberCount"]
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
    var isAlarm : Bool!
    
    var alarm : String!
    var randomImage : Int!
    
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
        randomImage <- map["randomImage"]
        
        alarm <- map["alarm"]        
        if alarm != nil && alarm == "ON" {
            isAlarm = true
        }else {
            isAlarm = false
        }
    }
}
