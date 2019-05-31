//
//  DiaryCollectionViewCell.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/24.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import TTGEmojiRate

class DiaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dailyImageView: UIImageView!
    @IBOutlet weak var emojiView: EmojiRateView!
    @IBOutlet weak var diaryTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
}
