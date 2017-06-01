//
//  AccountManagementViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation

class AccountManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :AccountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountCell
        
        
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
    
    @IBAction func dimiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

class AccountCell : UITableViewCell {
    
    
    
}
