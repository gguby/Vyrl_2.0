//
//  WriteViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 6. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation

class WriteViewController : UIViewController {
    
    var modalNavigationController = FeedNavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSwipe()
        
        self.tabBarItem.image = UIImage(named: "icon_write_01")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        DispatchQueue.main.async {
            self.setupNavigation()
        }

    }
    
    func setupNavigation(){
        
        let storyboard = UIStoryboard(name:"Write", bundle: nil)
        let mediaVC = storyboard.instantiateViewController(withIdentifier: "media") 
        
        modalNavigationController = FeedNavigationController(rootViewController: mediaVC)
        navigationController?.addChildViewController(modalNavigationController)
        navigationController?.si_presentViewController(toViewController: modalNavigationController, completion: {
            
        })
    }
    
}
