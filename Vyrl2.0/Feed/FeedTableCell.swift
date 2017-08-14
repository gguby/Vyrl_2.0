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

@objc protocol FeedCellDelegate {
    func didPressCell(sender: Any, cell : FeedTableCell)
    @objc optional func showFeedAlert(cell : FeedTableCell)
    @objc optional func showFeedShareAlert(cell : FeedTableCell)
}

class FeedTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewLeading: NSLayoutConstraint!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var cntLike: UIButton!
    
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var comment: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var firstCommentView: UIView!
    @IBOutlet weak var firstCommentNicknameButton: UIButton!
    @IBOutlet weak var firstCommentContent: UILabel!
    
    
    @IBOutlet weak var secondCommentView: UIView!
    @IBOutlet weak var secondCommentNicknameButton: UIButton!
    @IBOutlet weak var seconCommentContent: UILabel!
    
    
    
    var cellWidth = 124

    var delegate: FeedCellDelegate!
    
    var article : Article? {
        didSet{
            
            var count = article?.medias.count
            
            if ( count == 1 ){
                let str = article?.medias[0].url
                let url : URL = URL.init(string: str!)!
                self.photo.af_setImage(withURL: url)
            }
            
            var str : String!
            
            if let url = URL.init(string:(article?.profile.imagePath)!) {
                self.profileButton.af_setBackgroundImage(for: .normal, url: url)
            }
            
            self.nickNameLabel.text = article?.profile.nickName
            
            
            if let x = article?.cntLike {
                str = "\(x)"
            } else {
                str = "0"
            }
            
            self.cntLike.setTitle(str, for: .normal)
            
            if let x = article?.cntComment {
                str = "\(x)"
            }else {
                str = "0"
            }
            self.comment.setTitle(str, for: .normal)
            if(article?.cntComment == 0) {
                self.commentView.isHidden = true
            } else if (article?.cntComment == 1){
                self.commentView.isHidden = false
                self.secondCommentView.isHidden = true
            } else {
                self.commentView.isHidden = false
                self.secondCommentView.isHidden = false
            }
            
            if let x = article?.cntShare {
                str = "\(x)"
            }else {
                str = "0"
            }
            
            self.share.setTitle(str, for: .normal)
            
            guard self.collectionView != nil else {                
                return
            }
  
            if ( count == 2 ){
                cellWidth = 186
            }
            
            if ( count! > 6){
                count = 6
            }
            
            contentHeight.constant = CGFloat(ceilf( Float(count!) / 3) * Float(cellWidth))
        }
    }
    
    @IBAction func commentButtonClick(_ sender: UIButton) {
       delegate.didPressCell(sender: sender, cell: self)
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
    
    @IBAction func like(_ sender: UIButton) {
        if sender.tag == 0 {
            let uri = URL.init(string: Constants.VyrlFeedURL.feedLike(articleId: (self.article?.id)!))
            Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
                response in switch response.result {
                case .success(let json):
                    print(json)
                    sender.setImage(UIImage.init(named: "icon_heart_01_on"), for: .normal)
                    sender.tag = 1
                case .failure(let error):
                    print(error)
                }
            })
        }else {
            
            let uri = URL.init(string: Constants.VyrlFeedURL.feedLike(articleId: (self.article?.id)!))
            Alamofire.request(uri!, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
                response in switch response.result {
                case .success(let json):
                    print(json)
                    sender.setImage(UIImage.init(named: "icon_heart_01"), for: .normal)
                    sender.tag = 0
                    
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    @IBAction func editFeed(_ sender: Any) {
        delegate.showFeedAlert!(cell: self)
    }
    
    @IBAction func share(_ sender: Any) {
        delegate.showFeedShareAlert!(cell: self)
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
        return (article?.medias.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxCell", for: indexPath) as! BoxCell
        
        let media : ArticleMedia = (self.article?.medias[indexPath.row])!
        
        let str = media.image
        
        let url : URL = URL.init(string: str!)!
        
        cell.imageView.af_setImage(withURL: url)
        
        return cell
    }
}

class BoxCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

