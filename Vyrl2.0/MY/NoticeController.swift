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
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 47
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :NoticeCell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell") as! NoticeCell
        
        cell.isExpanded = false
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NoticeCell
            else { return }
        
//        cell.noticeTextView.text = "akdnlandkalsndlkansdlkansd"
        cell.isExpanded = !cell.isExpanded
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
 
}

class NoticeCell : UITableViewCell {
    
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newNoticeDotImg: UIImageView!
    @IBOutlet weak var noticeTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let padding = noticeTextView.textContainer.lineFragmentPadding
        noticeTextView.textContainerInset = UIEdgeInsetsMake(0, -padding, 21 , -padding)
    }
    
    var isExpanded:Bool = false
    {
        didSet{
            if ( !isExpanded ){
                self.noticeTextHeightConstraint.constant = 0.0
                iconArrow.image = UIImage(named: "icon_arrow_01_close")
            }else {
                self.noticeTextHeightConstraint.constant = noticeTextView.contentSize.height
                iconArrow.image = UIImage(named: "icon_arrow_01_open")
            }
        }
    }
}
