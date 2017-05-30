//
//  ProfilePhotoViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 5. 25..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class ProfilePhotoViewController: UIViewController {

    @IBOutlet weak var fileSizeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fileSizeLabel.layer.borderColor = UIColor.white.cgColor
        fileSizeLabel.layer.borderWidth = 1
        fileSizeLabel.layer.cornerRadius = 9.5
        fileSizeLabel.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
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