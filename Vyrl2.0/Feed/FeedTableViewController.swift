//
//  FeedTableViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class FeedTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell :FeedTableCell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedTableCell
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedTableCell
            break
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "advertisingFeed") as! FeedTableCell
            break
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "textOnlyFeed") as! FeedTableCell
            break
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "multiFeed") as! FeedTableCell
            break
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "channelFeed") as! FeedTableCell
            break
        default: break
        }
        
        return cell
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class FeedTableCell : UITableViewCell {
    
    
    
}
