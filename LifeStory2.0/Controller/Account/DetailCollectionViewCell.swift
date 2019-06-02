//
//  CollectionViewCell.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/23.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit



class DetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeDetailLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var deleteViewButton: UIButton!
    
    var indexPath: IndexPath!
    weak var delegate: CollectionViewCellDelegate?
    
    var isEditing: Bool = false{
        didSet{
            deleteViewButton.isHidden = !isEditing
        }
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        if indexPath != nil {
            delegate?.delete(at: indexPath)
        }
    }
}
