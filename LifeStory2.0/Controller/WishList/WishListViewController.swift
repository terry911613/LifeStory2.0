//
//  ToDoListViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/24.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import ViewAnimator
import ChameleonFramework

class WishListViewController: UIViewController {
    
    @IBOutlet weak var WishListCollectionView: UICollectionView!
    
    var wishListArray = [QueryDocumentSnapshot]()
    @IBOutlet var longpress: UILongPressGestureRecognizer!
    
    var p: CGPoint?
    var longPressed = false {
        didSet {
            if oldValue != longPressed {
                WishListCollectionView?.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WishListCollectionView.addGestureRecognizer(longpress)
        
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        db.collection(userID).document("LifeStory").collection("wishLists").order(by: "index", descending: false).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty{
                    self.wishListArray = [QueryDocumentSnapshot]()
                }
                else{
                    let documentChange = querySnapshot.documentChanges[0]
                    if documentChange.type == .added {
                        self.wishListArray = querySnapshot.documents
                        self.animateWishListCollectionView()
                    }
                }
            }
        }
        
//        db.collection(userID).document("LifeStory").collection("WishLists").order(by: "Date", descending: true).addSnapshotListener { (querySnapshot, error) in
//            if let querySnapshot = querySnapshot {
//                if querySnapshot.documents.isEmpty{
//                    self.wishListArray = [QueryDocumentSnapshot]()
//                }
//                else{
//                    let documentChange = querySnapshot.documentChanges[0]
//                    if documentChange.type == .added {
//                        self.wishListArray = querySnapshot.documents
//                        self.animateWishListCollectionView()
//                    }
//                }
//            }
//        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateWishListCollectionView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addWishListVC = segue.destination as! AddWishListViewController
        addWishListVC.index = wishListArray.count
    }
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            guard let selectedIndexPath = WishListCollectionView.indexPathForItem(at: sender.location(in: WishListCollectionView)) else {
                break
            }
            WishListCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            WishListCollectionView.updateInteractiveMovementTargetPosition(sender.location(in: sender.view!))
        case .ended:
            WishListCollectionView.endInteractiveMovement()
        default:
            WishListCollectionView.cancelInteractiveMovement()
        }
    }
    //  顯示特效
    func animateWishListCollectionView(){
        WishListCollectionView.reloadData()
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        WishListCollectionView.performBatchUpdates({
            UIView.animate(views: self.WishListCollectionView.orderedVisibleCells,
                           animations: animations, completion: nil)
        }, completion: nil)
    }
}

extension WishListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wishListArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wishListCell", for: indexPath) as! WishListCollectionViewCell
        
        let wishList = wishListArray[indexPath.row]
        cell.wishListLabel.text = wishList.data()["wishListText"] as? String
        if wishList.data()["color"] as? String == "green"{
            cell.backView.backgroundColor = UIColor.flatMint()
        }
        else if wishList.data()["color"] as? String == "yellow"{
            cell.backView.backgroundColor = UIColor.flatYellow()
        }
        else{
            cell.backView.backgroundColor = UIColor.flatWatermelon()
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        if destinationIndexPath.item > sourceIndexPath.item{
            if destinationIndexPath.item - sourceIndexPath.item > 1{
                for i in sourceIndexPath.item+1...destinationIndexPath.item{
                    let wish = wishListArray[i]
                    let index = wish.data()["index"] as! Int
                    let ref = db.collection(userID).document("LifeStory").collection("wishLists").document(wish.data()["documentID"] as! String)
                    ref.updateData(["index": index-1])
                }
                let wish = wishListArray[sourceIndexPath.item]
                let ref = db.collection(userID).document("LifeStory").collection("wishLists").document(wish.data()["documentID"] as! String)
                ref.updateData(["index": destinationIndexPath.item])
            }
            else{
                let wishSou = wishListArray[sourceIndexPath.item]
                let refSou = db.collection(userID).document("LifeStory").collection("wishLists").document(wishSou.data()["documentID"] as! String)
                refSou.updateData(["index": destinationIndexPath.item])
                
                let wishDes = wishListArray[destinationIndexPath.item]
                let refDes = db.collection(userID).document("LifeStory").collection("wishLists").document(wishDes.data()["documentID"] as! String)
                refDes.updateData(["index": sourceIndexPath.item])
            }
        }
        else{
            if sourceIndexPath.item - destinationIndexPath.item > 1{
                for i in destinationIndexPath.item...sourceIndexPath.item{
                    let wish = wishListArray[i]
                    let index = wish.data()["index"] as! Int
                    let ref = db.collection(userID).document("LifeStory").collection("wishLists").document(wish.data()["documentID"] as! String)
                    ref.updateData(["index": index+1])
                    
                }
                let wish = wishListArray[sourceIndexPath.item]
                let ref = db.collection(userID).document("LifeStory").collection("wishLists").document(wish.data()["documentID"] as! String)
                ref.updateData(["index": destinationIndexPath.item])
            }
            else{
                let wishSou = wishListArray[sourceIndexPath.item]
                let refSou = db.collection(userID).document("LifeStory").collection("wishLists").document(wishSou.data()["documentID"] as! String)
                refSou.updateData(["index": destinationIndexPath.item])
                
                let wishDes = wishListArray[destinationIndexPath.item]
                let refDes = db.collection(userID).document("LifeStory").collection("wishLists").document(wishDes.data()["documentID"] as! String)
                refDes.updateData(["index": sourceIndexPath.item])
            }
            
        }
        
        let wishList = wishListArray.remove(at: sourceIndexPath.item)
        wishListArray.insert(wishList, at: destinationIndexPath.item)
        
        db.collection(userID).document("LifeStory").collection("wishLists").order(by: "index", descending: false).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty{
                    self.wishListArray = [QueryDocumentSnapshot]()
                }
                else{
                    let documentChange = querySnapshot.documentChanges[0]
                    if documentChange.type == .added {
                        self.wishListArray = querySnapshot.documents
                        self.WishListCollectionView.reloadData()
                    }
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: WishListCollectionView.bounds.width, height: WishListCollectionView.bounds.width/4)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: NSInteger) -> CGFloat {
        return -5
    }
}
