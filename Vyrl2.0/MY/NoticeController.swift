//
//  ExpandableCell.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 30..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire

class NoticeController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    var noticeData :[Notice?]?
    
    var isNoticeType = true
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        noticeData = Array()
        
        if ( isNoticeType == true ){
            getNoticeData()
            titleLabel.text = "공지사항"
        }
        else  {
            getFAQData()
            titleLabel.text = "자주묻는 질문"
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func getFAQData(){
        
        let uri = Constants.VyrlAPIConstants.baseURL + "notices/faq"
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseJSON(completionHandler: {
            response in
            
            switch response.result {
            case .success(let json):
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        let jsonDataArray = json as! NSArray
                        
                        for json in jsonDataArray {
                            
                            let jsonData = json as! NSDictionary
                            
                            let title = jsonData["title"] as? String
                            let content = jsonData["content"] as? String
                            let noticeId = jsonData["id"] as? NSNumber
                            let date = jsonData["createdAt"] as? String
                            
                            let notice : Notice = Notice.init(id: noticeId!.stringValue, title: title!, date: (date?.convertDateString())!, content: content!, isNewNotice: true)
                            
                            self.noticeData?.append(notice)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
                
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }

    
    func getNoticeData(){
        
        let uri = Constants.VyrlAPIConstants.baseURL + "notices/update"
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseJSON(completionHandler: {
            response in
            
            switch response.result {
            case .success(let json):
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        let jsonDataArray = json as! NSArray
                        
                        for json in jsonDataArray {
                            
                            let jsonData = json as! NSDictionary
                            
                            let title = jsonData["title"] as? String
                            let content = jsonData["content"] as? String
                            let noticeId = jsonData["id"] as? NSNumber
                            let date = jsonData["createdAt"] as? String
                            
                            let notice : Notice = Notice.init(id: noticeId!.stringValue, title: title!, date: (date?.convertDateString())!, content: content!, isNewNotice: true)
                            
                            self.noticeData?.append(notice)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
                
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if noticeData?[indexPath.row] != nil {
            return 47
        }else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if noticeData?[indexPath.row] != nil {
            return 47
        }else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let data = noticeData {
            return data.count
        }
        else {
            return 0
        }
    }

    private func getParentCellIndex(expansionIndex: Int) -> Int {
        
        var selectedCell: Notice?
        var selectedCellIndex = expansionIndex
        
        while(selectedCell == nil && selectedCellIndex >= 0) {
            selectedCellIndex -= 1
            selectedCell = noticeData?[selectedCellIndex]
        }
        
        return selectedCellIndex
    }
    
    private func expandCell(tableView: UITableView, index: Int) {
        noticeData?.insert(nil, at: index + 1)
        tableView.insertRows(at: [NSIndexPath(row: index + 1, section: 0) as IndexPath] , with: .top)
    }
    
    private func contractCell(tableView: UITableView, index: Int) {
        noticeData?.remove(at: index+1)
        tableView.deleteRows(at: [NSIndexPath(row: index+1, section: 0) as IndexPath], with: .top)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let notice = noticeData![indexPath.row] {
            let cell :NoticeCell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell") as! NoticeCell
            
            cell.titleLabel.text = notice.title
            cell.dateLabel.text = notice.date
            cell.newNoticeDotImg.isHidden = !notice.isNewNotice
            cell.isExpanded = false
            return cell
        }
        else {
            if let rowData = noticeData![getParentCellIndex(expansionIndex: indexPath.row)] {
                
                let expansionCell = tableView.dequeueReusableCell(withIdentifier: "NoticeExpandCell", for: indexPath) as! NoticeExpandCell
                
                expansionCell.noticeTextView.text = rowData.content
                expansionCell.selectionStyle = .none
                return expansionCell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (noticeData?[indexPath.row]) != nil {
            let cell :NoticeCell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell") as! NoticeCell
            
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let noticeCell = tableView.cellForRow(at: indexPath) as! NoticeCell
        noticeCell.isExpanded = !noticeCell.isExpanded
        
        if (noticeData?[indexPath.row]) != nil
        {
            if ( indexPath.row + 1 >= (noticeData?.count)! ){
                expandCell(tableView: tableView, index: indexPath.row)
            }else
            {
                if (noticeData?[indexPath.row+1] != nil ){
                    expandCell(tableView: tableView, index: indexPath.row)
                }else {
                    contractCell(tableView: tableView, index: indexPath.row)
                }
            }
        }
    }
 
}

class NoticeCell : UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newNoticeDotImg: UIImageView!
    @IBOutlet weak var iconArrow: UIImageView!
    
    
    var isExpanded:Bool = false
    {
        didSet{
            if ( !isExpanded ){
                iconArrow.image = UIImage(named: "icon_arrow_01_close")
            }else {
                iconArrow.image = UIImage(named: "icon_arrow_01_open")
            }
        }
    }
}

class NoticeExpandCell :UITableViewCell {
    
    @IBOutlet weak var noticeTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let padding = noticeTextView.textContainer.lineFragmentPadding
        noticeTextView.textContainerInset = UIEdgeInsetsMake(0, -padding, 0 , -padding)
    }
}

struct Notice {
    
    var title : String
    var date  : String
    var content : String
    var isNewNotice = false
    var id : String
    
    
    init(id : String, title :String , date :String, content :String, isNewNotice:Bool)
    {
        self.id = id
        self.title = title
        self.date  = date
        self.content = content
        self.isNewNotice = isNewNotice
    }
}

extension String{
    func convertDateString () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let dateObj = dateFormatter.date(from: self)
        
        dateFormatter.dateFormat = "yyy.MM.dd"
        
        let dateStr = dateFormatter.string(from: dateObj!)
        
        return dateStr
    }
}
