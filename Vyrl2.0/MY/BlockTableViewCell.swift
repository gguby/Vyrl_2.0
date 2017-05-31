//
//  BlockTableViewCell.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 5. 31..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class BlockTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var nicNameLabel: UILabel!
    
    @IBOutlet weak var unBlockButton: UIButton!
    
    @IBOutlet weak var officialImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
