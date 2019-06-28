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
    
    var allDiaries = [QueryDocumentSnapshot]()
    var allUserDiaries = [QueryDocumentSnapshot]()
    var allCoEditDiaries = [QueryDocumentSnapshot]()
    var isFirstGetPhotos = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        getDiaries()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        diariesAnimateCollectionView()
    }
    
    func getDiaries(){
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let coEditID = userData["coEditID"] as? String,
                        let coEditStatus = userData["coEditStatus"] as? String,
                        coEditStatus == "共同編輯中"{
                        
                        db.collection("LifeStory").document(userID).collection("diaries").order(by: "date", descending: true).addSnapshotListener({ (userDiaries, error) in
                            if let userDiaries = userDiaries{
                                if userDiaries.documents.isEmpty{
                                    self.allDiaries.removeAll()
                                    self.allUserDiaries.removeAll()
                                    if self.allCoEditDiaries.isEmpty == false{
                                        for allCoEditDiary in self.allCoEditDiaries{
                                            self.allDiaries.append(allCoEditDiary)
                                        }
                                    }
                                    self.diaryCollectionView.reloadData()
                                }
                                else{
                                    let documentChange = userDiaries.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allDiaries.removeAll()
                                        self.allUserDiaries = userDiaries.documents
                                        for userDiary in self.allUserDiaries{
                                            self.allDiaries.append(userDiary)
                                        }
                                        if self.allCoEditDiaries.isEmpty{
                                            self.allCoEditDiaries.removeAll()
                                        }
                                        else{
                                            for coEditDiary in self.allCoEditDiaries{
                                                self.allDiaries.append(coEditDiary)
                                            }
                                        }
                                        self.diaryCollectionView.reloadData()
                                    }
                                }
                            }
                        })
                        db.collection("LifeStory").document(coEditID).collection("diaries").order(by: "date", descending: true).addSnapshotListener({ (coEditDiaries, error) in
                            if let coEditDiaries = coEditDiaries{
                                if coEditDiaries.documents.isEmpty{
                                    self.allDiaries.removeAll()
                                    self.allCoEditDiaries.removeAll()
                                    
                                    if self.allUserDiaries.isEmpty == false{
                                        for userDiary in self.allUserDiaries{
                                            self.allDiaries.append(userDiary)
                                        }
                                    }
                                    self.diaryCollectionView.reloadData()
                                }
                                else{
                                    let documentChange = coEditDiaries.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allDiaries.removeAll()
                                        self.allCoEditDiaries = coEditDiaries.documents
                                        for coEditDiary in self.allCoEditDiaries{
                                            self.allDiaries.append(coEditDiary)
                                        }
                                        if self.allUserDiaries.isEmpty{
                                            self.allUserDiaries.removeAll()
                                        }
                                        else{
                                            for userDiary in self.allUserDiaries{
                                                self.allDiaries.append(userDiary)
                                            }
                                        }
                                        self.diaryCollectionView.reloadData()
                                    }
                                }
                            }
                        })
                        
                    }
                    else{
                        db.collection("LifeStory").document(userID).collection("diaries").order(by: "date", descending: true).addSnapshotListener { (diaries, error) in
                            
                            if let diaries = diaries {
                                if diaries.documents.isEmpty{
                                    self.allDiaries.removeAll()
                                    self.diaryCollectionView.reloadData()
                                }
                                else{
                                    let documentChange = diaries.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allDiaries = diaries.documents
                                        self.diaryCollectionView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
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
        return allDiaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diaryCell", for: indexPath) as! DiaryCollectionViewCell
        
        let diary = allDiaries[indexPath.row]
        
        if let mood = diary.data()["mood"] as? Float,
            let title = diary.data()["title"] as? String,
            let diaryText = diary.data()["diaryText"] as? String,
            let photoUrl = diary.data()["photoUrl"] as? String{
            
            cell.emojiView.rateValue = mood
            cell.titleLabel.text = title
            cell.diaryTextView.text = diaryText
            cell.dailyImageView.kf.setImage(with: URL(string: photoUrl))
        }
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月dd日"
        dateFormatter.locale = Locale(identifier: "zh_TW")
        dateFormatter.timeZone = TimeZone(identifier: "zh_TW")
        let dateText = dateFormatter.string(from: Date())
        cell.dateLabel.text = dateText
        
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
        
        let diary = allDiaries[indexPath.row]
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email,
            let documentID = diary.data()["documentID"] as? String{
            
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let coEditID = userData["coEditID"] as? String,
                        let coEditStatus = userData["coEditStatus"] as? String,
                        coEditStatus == "共同編輯中"{
                        
                        db.collection("LifeStory").document(userID).collection("diaries").document(documentID).delete()
                        db.collection("LifeStory").document(coEditID).collection("diaries").document(documentID).delete()
                        
                        self.allDiaries.remove(at: indexPath.row)
                        self.diaryCollectionView.reloadData()
                        
                    }
                    else{
                        db.collection("LifeStory").document(userID).collection("diaries").document(documentID).delete()
                        
                        self.allDiaries.remove(at: indexPath.row)
                        self.diaryCollectionView.reloadData()
                    }
                }
            }
        }
    }
}
