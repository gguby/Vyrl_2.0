//
//  WriteMediaViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 7. 6..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation

class WriteMediaViewConroller : UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var topView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleView.alpha = 0
        
        self.view.backgroundColor = .white
        
        if let nc = self.navigationController as? FeedNavigationController {
            nc.si_delegate = self
            nc.fullScreenSwipeUp = true
            
            nc.isNavigationBarHidden = true
            
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.parent?.navigationController?.si_dismissModalView(toViewController: self.parent!, completion: {
                
                if let nc = self.navigationController as? FeedNavigationController {
                    nc.si_delegate?.navigationControllerDidClosed?(navigationController: nc)
                }
            })
            
        }
    }
    
}

extension WriteMediaViewConroller : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if ( indexPath.row < 2 ){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MediaButtonCell
            
            if (indexPath.row == 1){
                cell.btnImg.image = UIImage(named: "icon_video_01")
                cell.label.text = "동영상 촬영"
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! MediaPhotoCell
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
}

extension WriteMediaViewConroller: FeedNavigationControllerDelegate {
    
    // MARK: - FeedNavigationControllerDelegate
    func navigationControllerDidSpreadToEntire(navigationController: UINavigationController) {
        print("spread to the entire")
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        
                        self.titleView.alpha = 1
                        
        }, completion: nil)
    }
    
    func navigationControllerDidClosed(navigationController: UINavigationController) {
        print("decreased on the view")  
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        
                        self.titleView.alpha = 0
                        
        }, completion: nil)
      
    }
   
}

class MediaButtonCell : UICollectionViewCell {
    @IBOutlet weak var btnImg: UIImageView!
    @IBOutlet weak var label: UILabel!
}

class MediaPhotoCell : UICollectionViewCell {
    
}
