//
//  LoginViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//


import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import Fabric

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var signInButton : GIDSignInButton!
    
    @IBOutlet weak var signOutBtn : UIButton!    
    
    @IBOutlet weak var firstLabel: UILabel!
    
    func initView()
    {
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
    
    func faceBookLogin()
    {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager .logOut()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // Present the main view
                
            })
        }
    }
    
    func twitterLogin()
    {
        Twitter.sharedInstance().logIn(withMethods: .webBased) { (session, error) in
            if((session) != nil) {
                Twitter.sharedInstance().sessionStore.saveSession(withAuthToken: (session?.authToken)!, authTokenSecret: (session?.authTokenSecret)!, completion: { (session, error) in
                })
                print("Twitter authToken    :\(session?.authToken)")
                print("Twitter userName     :\(session?.userName)")
            }
            else {
                print("Twitter login failed")
            }
        }
    }
    
    @IBAction func didTapSignOut(sender: AnyObject)
    {
        GIDSignIn.sharedInstance().signOut()
    }
    
    @IBAction func didTapSignIn(sender: AnyObject)
    {
        switch sender.tag {
            
        case 1:
            faceBookLogin()
        case 2:
            twitterLogin()
        case 4:
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


class LoginCustomButton : UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

