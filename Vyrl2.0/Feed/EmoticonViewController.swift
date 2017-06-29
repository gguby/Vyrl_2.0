//
//  EmoticonViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 26..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class EmoticonViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var collectionViewArray = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         collectionViewArray = ["icon_add_01.png", "icon_add_02.png", "icon_alert_01.png", "icon_alarm_01.png", "icon_add_01.png", "icon_add_02.png", "icon_alert_01.png", "icon_alarm_01.png", "icon_add_01.png", "icon_add_02.png"
        ,"icon_add_01.png", "icon_add_02.png", "icon_alert_01.png", "icon_alarm_01.png", "icon_add_01.png", "icon_add_02.png", "icon_alert_01.png", "icon_alarm_01.png", "icon_add_01.png", "icon_add_02.png"
        ,"icon_add_01.png", "icon_add_02.png", "icon_alert_01.png", "icon_alarm_01.png", "icon_add_01.png", "icon_add_02.png", "icon_alert_01.png", "icon_alarm_01.png", "icon_add_01.png", "icon_add_02.png"];
        
        self.collectionView.reloadData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EmoticonCell
        
        cell.emoticonImageView.image = UIImage.init(named: self.collectionViewArray[indexPath.row])
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView : UICollectionReusableView? = nil
        
        if(kind == UICollectionElementKindSectionFooter) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath)
            
            reusableView = headerView
        }
        
        return reusableView!
    }
    
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
        pageControl.currentPage = Int(index);
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
        pageControl.currentPage = Int(index);

    }

}

extension EmoticonViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width / 5,
                           height: collectionView.frame.size.height / 3)
    }
    
}

class EmoticonCell :UICollectionViewCell {
    
    @IBOutlet weak var emoticonImageView: UIImageView!
}

