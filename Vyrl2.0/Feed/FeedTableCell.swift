//
//  FeedTableCell.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 7. 24..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

protocol YourCellDelegate: NSObjectProtocol{
    func didPressCell(sender: Any)
}

class FeedTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewLeading: NSLayoutConstraint!
    
    @IBOutlet weak var photo: UIImageView!
    
    var cellWidth = 124

    var delegate: YourCellDelegate!
    
    var article : Article? {
        didSet{
            
            let count = (self.article!.mediaCount)!
            
            guard self.collectionView != nil else {
                
                if ( count == 1 ){
                    let url : URL = URL.init(string: (article?.images[0])!)!
                    self.photo.af_setImage(withURL: url)
                }
                
                return
            }
  
            if ( count == 1 ){
                let url : URL = URL.init(string: (article?.images[0])!)!
                self.photo.af_setImage(withURL: url)
            }
            
            if ( count == 2 ){
                cellWidth = 186
            }
            
            contentHeight.constant = CGFloat(ceilf( Float(count) / 3) * Float(cellWidth))
        }
    }
    
    @IBAction func commentButtonClick(_ sender: UIButton) {
       delegate.didPressCell(sender: sender)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(self.collectionView != nil) {
            self.collectionView.delegate = self as UICollectionViewDelegate
            self.collectionView.dataSource = self as UICollectionViewDataSource
            
            let size = UIScreen.main.bounds
       
            if (size.width > 375){
                self.collectionViewLeading.constant = 20
            }            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension FeedTableCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}


extension FeedTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (article?.images.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxCell", for: indexPath) as! BoxCell
        
        let url : URL = URL.init(string: (article?.images[indexPath.row])!)!
        
        cell.imageView.af_setImage(withURL: url)
        
        return cell
    }
}

class BoxCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

