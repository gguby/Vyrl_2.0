//
//  FeedTableCell.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 7. 24..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

class FeedTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentLabel: UILabel!
    
    var article : Article?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(self.collectionView != nil) {
            self.collectionView.delegate = self as UICollectionViewDelegate
            self.collectionView.dataSource = self as UICollectionViewDataSource
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}


extension FeedTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (article?.images.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxCell", for: indexPath) as! BoxCell
        Alamofire.request((article?.images[indexPath.row])!).responseImage { (response) in
            if let image = response.result.value {
                DispatchQueue.main.async {
                    cell.imageView.image = image
                
                }
            }
        }
        
        return cell
    }
}

class BoxCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
}

