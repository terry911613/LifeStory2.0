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
    
    var diaries = [QueryDocumentSnapshot]()
    var isFirstGetPhotos = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        diaries = [QueryDocumentSnapshot]()
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        db.collection(userID).document("LifeStory").collection("Diaries").order(by: "Date", descending: true).addSnapshotListener { (querySnapshot, error) in
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

extension DiaryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diaryCell", for: indexPath) as! DiaryCollectionViewCell
        
        let diary = diaries[indexPath.row]
        cell.emojiView.rateValue = diary.data()["Mood"] as! Float
        cell.titleLabel.text = diary.data()["Title"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月dd日"
        dateFormatter.locale = Locale(identifier: "zh_TW")
        dateFormatter.timeZone = TimeZone(identifier: "zh_TW")
        let dateText = dateFormatter.string(from: Date())
        cell.dateLabel.text = dateText
        
        cell.diaryTextView.text = diary.data()["DiaryText"] as? String
        if let urlString = diary.data()["PhotoUrl"] as? String{
            cell.dailyImageView.kf.setImage(with: URL(string: urlString))
        }
        return cell
    }
}

extension DiaryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: diaryCollectionView.bounds.width, height: diaryCollectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: NSInteger) -> CGFloat {
        return -5
    }
}
