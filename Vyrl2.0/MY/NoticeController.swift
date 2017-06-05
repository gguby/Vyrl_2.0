//
//  ExpandableCell.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 30..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation

class NoticeController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    private func getData() -> [Notice?] {
        
        let notice_01 = Notice(title: "공지사항 01", date: "2017.04.10", content: "alsdmakldmaklsdmkalsdnalskdnaklsdnasdlkansdlaskndalsdnasdknalsndlasndlansdklansklansdlkasnd", isNewNotice: true)
        let notice_02 = Notice(title: "공지사항 02", date: "2017.04.11", content: "안녕하세요, 바이럴 팀입니다~\n 항상 바이럴을 이용해 주시는 분들 감사합니다.~ \n 오늘은 팬패에지 관련 공지가 있습니다.! \n\n 팬페이지를 개설하는 방법은 FAQ를 참고해 주세요.\n 팬페이지는 여러개 개설 할 수 있습니다.\n 팬페이지에 참여하여 더욱 즐거운 바이럴을 이용하세요.\n 여러분의 바이럴입니다. \n\n 날씨가 많이 더워졌지만 \n 언제나 열일하는 바이럴 팀이었습니다! \n 좋은 소식으로 또 만나요~~~" , isNewNotice: true)
        let notice_03 = Notice(title: "공지사항 03", date: "2017.04.12", content: "안녕하세요, 바이럴 팀입니다~\n항상 바이럴을 이용해 주시는 분들 감사합니다.~ \n오늘은 팬패에지 관련 공지가 있습니다.! \n\n 팬페이지를 개설하는 방법은 FAQ를 참고해 주세요.\n 팬페이지는 여러개 개설 할 수 있습니다.\n팬페이지에 참여하여 더욱 즐거운 바이럴을 이용하세요.\n 여러분의 바이럴입니다. \n\n 날씨가 많이 더워졌지만 \n 언제나 열일하는 바이럴 팀이었습니다! \n 좋은 소식으로 또 만나요~~~" , isNewNotice: false)
        
        return [notice_01 ,notice_02 , notice_03]
    }
    
    var noticeData :[Notice?]?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        noticeData = getData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        tableView.tableFooterView = UIView(frame: .zero)
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
    
    
    init(title :String , date :String, content :String, isNewNotice:Bool)
    {
        self.title = title;
        self.date  = date
        self.content = content
        self.isNewNotice = isNewNotice
    }
}
