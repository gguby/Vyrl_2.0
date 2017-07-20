//
//  FeedTableViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire


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
    
    
    @IBAction func photoClick(_ sender: UIButton) {
        self.pushView(storyboardName: "Feed", controllerName: "FeedFullScreenViewController")
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

    func getAllFeed(){
        
        let url = URL.init(string: Constants.VyrlFeedURL.FEED)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            //            let array = response.result.value ?? []
            //
            //            for article in array {
            //                print(article.id)
            //            }
        }
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
