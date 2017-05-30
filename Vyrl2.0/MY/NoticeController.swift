//
//  ExpandableCell.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 30..
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :NoticeCell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell") as! NoticeCell
        
        cell.isExpanded = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NoticeCell
            else { return }
        
        cell.isExpanded = false
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47 + 271
    }
}

class NoticeCell : UITableViewCell {
    
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var newNoticeDotImg: UIImageView!
    @IBOutlet weak var noticeTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconArrow: UIImageView!
    
    var isExpanded:Bool = false
    {
        didSet{
            if ( !isExpanded ){
//                self.noticeTextHeightConstraint.constant = 0.0
                iconArrow.image = UIImage(named: "icon_arrow_01_close")
            }else {
//                self.noticeTextHeightConstraint.constant = 271.5
                iconArrow.image = UIImage(named: "icon_arrow_01_open")
            }
        }
    }
}
