//
//  WishListTableViewCell.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/6/20.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class WishListTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var wishListLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
