//
//  TagSearchCollectionViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 11. 13..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class TagSearchCollectionViewController: UIViewController {
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var tagString : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resultLabel.text = "#\(tagString)"
        self.setupPostContainer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupPostContainer(){
        let storyboard = UIStoryboard(name: "PostCollectionViewController", bundle: nil)
        let controller : PostCollectionViewController = storyboard.instantiateViewController(withIdentifier: "PostCollection") as! PostCollectionViewController
        controller.type = PostType.HashTag
        
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
        
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

}
