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
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var socialImage: UIImageView!
    
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var accountList : Array<Account> = []
    var currentAccount :Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.refresh()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        self.tableViewHeightConstraint.constant = self.tableView.contentSize.height + 20        
    }
    
    func refresh(){
        self.currentAccount = LoginManager.sharedInstance.getCurrentAccount()!
        if let image = UserDefaults.standard.image(forKey: (self.currentAccount?.userId!)!){
            profileView.image = image
        }
        socialImage.image = currentAccount?.logoImage
        nickName.text = currentAccount?.nickName
        emailLabel.text = (currentAccount?.email)! + "으로 연결된 계정"
        self.accountList = LoginManager.sharedInstance.includeNotCurrentUser()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return accountList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :AccountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! AccountCell
        
        let account = self.accountList[indexPath.row]
        
        cell.emailLabel.text = (account.email)! + "으로 연결된 계정"
        if let image = UserDefaults.standard.image(forKey: account.userId!){
            cell.profileImageView.image = image
        }
        cell.logoImageView.image = account.logoImage
        cell.nickNameLabel.text = account.nickName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = self.accountList[indexPath.row]
        
        LoginManager.sharedInstance.changeCookie(account: account)
        
        self.refresh()
        
        tableView.reloadData()
    }
    
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func withDraw(_ sender: Any) {
        print("withDraw")
        
        LoginManager.sharedInstance.withDraw()
    }
    
    @IBAction func addAccount(_ sender: Any) {
        let vc : LoginViewController = self.pushViewControllrer(storyboardName: "Login", controllerName: "Login") as! LoginViewController
        vc.isAddAccount = true
        vc.accountVC = self
    }
    
    @IBAction func logoutALL(_ sender: Any) {
        LoginManager.sharedInstance.logoutAll()        
    }
    
    @IBAction func logout(_ sender: Any)
    {
        let alertController = UIAlertController (title:nil, message:"로그아웃 하시겠습니까?",preferredStyle:.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default,handler: { (action) -> Void in
            LoginManager.sharedInstance.signout {
                
            }            
        })

        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in
        })
        
        alertController.addAction(cancel)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func refreshTable(){
        self.accountList = LoginManager.sharedInstance.includeNotCurrentUser()
        self.tableView.reloadData()
        self.tableViewHeightConstraint.constant = self.tableView.contentSize.height + 20
    }
}

class AccountCell : UITableViewCell {
    
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
}
