//
//  StartCoverViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 5. 24..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class StartCoverViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var images: Array<UIImage> = []
        images.append(UIColor.blue.convertImage())
        images.append(UIColor.clear.convertImage())
        images.append(UIColor.brown.convertImage())
        
        coverImageView.animationImages = images;
        coverImageView.animationDuration = 5;
        coverImageView.startAnimating()
    }
    
    @IBAction func showSearchViewController(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainController = storyboard.instantiateInitialViewController()!
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainController
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


public extension UIColor {
    func convertImage() -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 300, height: 300))
        UIGraphicsBeginImageContext(rect.size)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.cgColor)
        context.fill(rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}


