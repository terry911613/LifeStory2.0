//
//  DiaryViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/24.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Kingfisher
import ViewAnimator

class DiaryViewController: UIViewController {

    @IBOutlet weak var diaryCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var diaries = [QueryDocumentSnapshot]()
    var isFirstGetPhotos = true
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        diaries = [QueryDocumentSnapshot]()
        
        db.collection(userID).document("LifeStory").collection("diaries").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty{
                    self.diaries = [QueryDocumentSnapshot]()
                }
                else{
                    if self.isFirstGetPhotos {
                        self.isFirstGetPhotos = false
                        self.diaries = querySnapshot.documents
                        self.diariesAnimateCollectionView()
                    }
                    else {
                        let documentChange = querySnapshot.documentChanges[0]
                        if documentChange.type == .added {
                            self.diaries.insert(documentChange.document, at: 0)
                            self.diariesAnimateCollectionView()
                        }
                    }
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        diariesAnimateCollectionView()
    }
    //  顯示特效
    func diariesAnimateCollectionView(){
        diaryCollectionView.reloadData()
        let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]
        diaryCollectionView.performBatchUpdates({
            UIView.animate(views: self.diaryCollectionView.orderedVisibleCells,
                           animations: animations, completion: nil)
        }, completion: nil)
    }
}

extension DiaryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CollectionViewCellDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diaryCell", for: indexPath) as! DiaryCollectionViewCell
        
        let diary = diaries[indexPath.row]
        cell.emojiView.rateValue = diary.data()["mood"] as! Float
        cell.titleLabel.text = diary.data()["title"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月dd日"
        dateFormatter.locale = Locale(identifier: "zh_TW")
        dateFormatter.timeZone = TimeZone(identifier: "zh_TW")
        let dateText = dateFormatter.string(from: Date())
        cell.dateLabel.text = dateText
        
        cell.diaryTextView.text = diary.data()["diaryText"] as? String
        if let urlString = diary.data()["photoUrl"] as? String{
            cell.dailyImageView.kf.setImage(with: URL(string: urlString))
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: diaryCollectionView.bounds.width, height: diaryCollectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: NSInteger) -> CGFloat {
        return -5
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addButton.isEnabled = !editing
        
        let indexPaths = diaryCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths{
            let cell = diaryCollectionView.cellForItem(at: indexPath) as! DiaryCollectionViewCell
            cell.deleteButton.isHidden = !editing
        }
    }
    
    func delete(at indexPath: IndexPath) {
        let diary = diaries[indexPath.row]
        db.collection(userID).document("LifeStory").collection("diaries").document(diary.data()["documentID"] as! String).delete { (error) in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
        diaries.remove(at: indexPath.row)
        diaryCollectionView.reloadData()
        print(indexPath.row)
    }
}
