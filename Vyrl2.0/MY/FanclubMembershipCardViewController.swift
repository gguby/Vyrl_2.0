//
//  FanclubMembershipCardViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 2..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class FanclubMembershipCardViewController: UIViewController {

    @IBOutlet weak var fanclubImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.fanclubImageView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.gray.cgColor]
        gradient.locations = [0.5, 1.0]
        self.fanclubImageView.layer.addSublayer(gradient)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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


