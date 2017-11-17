//
//  FeedDetailCommentTableCell.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 10. 12..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import ObjectMapper

struct Comment : Mappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: Map) {
        
    }
    var id : Int!
    var userId : Int!
    var content : String!
    var nickName : String!
    var profileImageURL : String!
    var createAt : String!
    var emoticon : String!
    
    mutating func mapping(map: Map){
        id <- map["id"]
        content <- map["content"]
        nickName <- map["nickName"]
        profileImageURL <- map["profile"]
        createAt <- map["createdAt"]
        userId <- map["userId"]
        emoticon <- map["emoticon"]
    }
}

protocol FeedDetailCommentTableCellProtocol {
    func commentProfileButtonDidSelect(profileId : Int)
}

class FeedDetailCommentTableCell : UITableViewCell {
    @IBOutlet weak var commentNicknameLabel: UILabel!
    @IBOutlet weak var commentProfileButton: UIButton!
    @IBOutlet weak var commentContextTextView: UITextView!
    @IBOutlet weak var commentEmoticonImageView: UIImageView!
    @IBOutlet weak var commentTimaLavel: UILabel!
    var userId : Int!
    
    var delegate: FeedDetailCommentTableCellProtocol!
    
    override func awakeFromNib() {
        self.commentContextTextView.textContainerInset = UIEdgeInsets.zero
        self.commentContextTextView.textContainer.lineFragmentPadding = 0
    }
    
    @IBAction func profileButtonClick(_ sender: UIButton) {
        delegate.commentProfileButtonDidSelect(profileId: self.userId)
    }
}
