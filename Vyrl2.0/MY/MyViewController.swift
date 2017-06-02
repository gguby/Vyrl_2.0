//
//  MyViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var dropTableView: UIView!
    
    @IBOutlet weak var accountTable: UITableView!
    
    @IBOutlet weak var footer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        print("My");
        
        self.accountTable.delegate = self
        self.accountTable.dataSource = self
        self.accountTable.rowHeight = 50        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showAccountSelectView(_ sender: Any) {
        dropTableView.isHidden  = false
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func showSetting(){
        self.pushView(storyboardName: "My", controllerName: "setting")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :MyAccountCell = tableView.dequeueReusableCell(withIdentifier: "myaccountcell") as! MyAccountCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footer
    }

}

class MyAccountCell : UITableViewCell{
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var iconCheck: UIImageView!
    @IBOutlet weak var iconDot: UIImageView!
    
}
