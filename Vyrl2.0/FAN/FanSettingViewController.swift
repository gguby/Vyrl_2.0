//
//  File.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 9. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class FanSettingViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }    
}

extension FanSettingViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fansettingcell", for: indexPath) as! FanSettingCell
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "프로필 수정"
        } else if indexPath.row == 1{
            cell.titleLabel.text = "팬페이지 폐쇄하기"
        }else {
            cell.titleLabel.text = "팬페이지에서 탈퇴하기"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class FanSettingCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
}
