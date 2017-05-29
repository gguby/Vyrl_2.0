//
//  AppDelegate.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Google
import FirebaseCore
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import TwitterKit

extension AppDelegate
{
    func setupGAI()
    {
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
        }
        gai.tracker(withTrackingId: Constants.GoogleAnalysis.kTrackingId)
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        
        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        gai.logger.logLevel = .verbose;
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var naviController : UINavigationController?
    
    func popController()
    {
        naviController!.popViewController(animated: true)
    }
    
    func pushViewController(viewController : UIViewController )
    {
        naviController!.pushViewController(viewController, animated: true)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupGAI()
        
//        GIDSignIn.sharedInstance()?.signOut()
//        
//        let firebaseAuth = FIRAuth.auth()
//        do{
//            try firebaseAuth?.signOut()
//        } catch let signOutError as NSError {
//            print ("Error signing out : %@", signOutError)
//        }
        
        FIRAuth.auth()?.addStateDidChangeListener(){ (auth , user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let loginController = storyboard.instantiateInitialViewController()!
                self.naviController = UINavigationController(rootViewController: loginController)
                self.naviController?.isNavigationBarHidden = true
                self.window?.rootViewController = self.naviController
                self.window?.makeKeyAndVisible()
            }
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions);
        Fabric.with([Twitter.self])
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            if (url.scheme?.hasPrefix("fb"))! {
                return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            } else {
                return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: nil)
            }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                            sourceApplication: sourceApplication,
                                                            annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

