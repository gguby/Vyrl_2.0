//
//  LoginViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInButton : GIDSignInButton!
    
    @IBOutlet weak var signOutBtn : UIButton!    
    
    @IBOutlet weak var firstLabel: UILabel!
    
    func initView()
    {
        firstLabel.font = UIFont.ivTextStyle2Font()
        
        for  v in self.view.subviews {
            if ( v.tag == 1 )
            {
                v.layer.borderWidth = 1
                v.layer.borderColor = UIColor(red: 62.0 / 255.0, green: 58.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0).cgColor
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self;
        
        initView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapSignOut(sender: AnyObject)
    {
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func didTapSignIn(sender: AnyObject)
    {
        print(sender.tag)
        
        switch sender.tag {
       
        case 4 :
            GIDSignIn.sharedInstance().signIn()
        
        default:
            print(sender.tag)

        }
    }

}

extension LoginViewController
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension UIFont {
    class func ivTextStyle2Font() -> UIFont? {
        return UIFont(name: "AppleSDGothicNeo-UltraLight", size: 22.0)
    }
}

