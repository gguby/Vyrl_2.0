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
        
        UIView.transition(with: self.dropTableView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
            
            self.dropTableView.isHidden  = !self.dropTableView.isHidden
            self.tabBarController?.tabBar.isHidden = !self.dropTableView.isHidden
            
        }, completion: nil)
        
    }
    
    @IBAction func pushProfile(_ sender: Any) {
        let view : ProfileController = self.pushViewControllrer(storyboardName: "My", controllerName: "profile") as! ProfileController
        view.type = .Modify
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

fileprivate let minimumHitArea = CGSize(width: 100, height: 100)

class SmallButton : UIButton {
    
}

extension SmallButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}

class CustomButton : UIButton {
    
}

extension CustomButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted
            {
                self.backgroundColor = UIColor(red: 62.0 / 255.0, green: 58.0 / 255.0, blue: 57.0 / 255.0, alpha: 0.3)
            } else
            {
                self.backgroundColor = UIColor.clear
            }
        }
    }
}
