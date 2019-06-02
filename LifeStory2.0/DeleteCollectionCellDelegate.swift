//
//  DeleteCollectionCellDelegate.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/31.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import Foundation

protocol CollectionViewCellDelegate: class {
    func delete(at indexPath: IndexPath)
}
