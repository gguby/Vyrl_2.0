//
//  ActivityViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 11. 3..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ActivityViewController : UITableViewDelegate {
    
}

class ActivityTableViewCell : UITableViewCell {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
}
