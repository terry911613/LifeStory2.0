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
    
    @IBOutlet weak var wishListTableView: UITableView!
    
    var allUserWishList = [QueryDocumentSnapshot]()
    var allCoEditWishList = [QueryDocumentSnapshot]()
    var allWishList = [QueryDocumentSnapshot]()
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy年M月d日 a hh:mm"
        
        getData()
    }
    
    func getData() {
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let coEditID = userData["coEditID"] as? String,
                        let coEditStatus = userData["coEditStatus"] as? String,
                        coEditStatus == "共同編輯中"{
                        
                        db.collection("LifeStory").document(userID).collection("wishLists").order(by: "index", descending: false).addSnapshotListener { (user, error) in
                            
                            if let user = user {
                                if user.documents.isEmpty{
                                    self.allWishList.removeAll()
                                    self.allUserWishList.removeAll()
                                    if self.allCoEditWishList.isEmpty == false{
                                        for allCoEditWishList in self.allCoEditWishList{
                                            self.allWishList.append(allCoEditWishList)
                                        }
                                    }
                                    self.wishListTableView.reloadData()
                                }
                                else{
                                    let documentChange = user.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allWishList.removeAll()
                                        self.allUserWishList = user.documents
                                        for userWishList in self.allUserWishList{
                                            self.allWishList.append(userWishList)
                                        }
                                        if self.allCoEditWishList.isEmpty{
                                            self.allCoEditWishList.removeAll()
                                        }
                                        else{
                                            for coEditWishList in self.allCoEditWishList{
                                                self.allWishList.append(coEditWishList)
                                            }
                                        }
                                        self.wishListTableView.reloadData()
                                    }
                                }
                            }
                        }
                        db.collection("LifeStory").document(coEditID).collection("wishLists").order(by: "index", descending: false).addSnapshotListener{(coEdit, error) in
                            
                            if let coEdit = coEdit {
                                if coEdit.documents.isEmpty{
                                    self.allWishList.removeAll()
                                    self.allCoEditWishList.removeAll()
                                    
                                    if self.allUserWishList.isEmpty == false{
                                        for userWishList in self.allUserWishList{
                                            self.allWishList.append(userWishList)
                                        }
                                    }
                                    self.wishListTableView.reloadData()
                                }
                                else{
                                    let documentChange = coEdit.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allWishList.removeAll()
                                        self.allCoEditWishList = coEdit.documents
                                        for coEditWishList in self.allCoEditWishList{
                                            self.allWishList.append(coEditWishList)
                                        }
                                        if self.allUserWishList.isEmpty{
                                            self.allUserWishList.removeAll()
                                        }
                                        else{
                                            for selfWishList in self.allUserWishList{
                                                self.allWishList.append(selfWishList)
                                            }
                                        }
                                        self.wishListTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                    else{
                        db.collection("LifeStory").document(userID).collection("wishLists").order(by: "index", descending: false).addSnapshotListener { (querySnapshot, error) in
                            
                            if let querySnapshot = querySnapshot {
                                if querySnapshot.documents.isEmpty{
                                    self.allWishList.removeAll()
                                    self.wishListTableView.reloadData()
                                }
                                else{
                                    let documentChange = querySnapshot.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allWishList = querySnapshot.documents
                                       self.wishListTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addWishListVC = segue.destination as! AddWishListViewController
        addWishListVC.index = allWishList.count
    }
}

extension WishListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allWishList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishListCell", for: indexPath) as! WishListTableViewCell
        
        let wishList = allWishList[indexPath.row]
        
        if let goal = wishList.data()["goal"] as? String,
            let wishListText = wishList.data()["wishListText"] as? String,
            let timestamp = wishList.data()["date"] as? Timestamp{
            cell.goalLabel.text = goal
            cell.wishListLabel.text = wishListText
            cell.dateLabel.text = formatter.string(from: timestamp.dateValue())
            
            if goal == "短期目標"{
                cell.backView.backgroundColor = UIColor.flatMint()
            }
            else if goal == "中期目標"{
                cell.backView.backgroundColor = UIColor.flatYellow()
            }
            else{
                cell.backView.backgroundColor = UIColor.flatWatermelon()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let wishList = allWishList[indexPath.row]
            
            let db = Firestore.firestore()
            if let userID = Auth.auth().currentUser?.email,
                let documentID = wishList.data()["documentID"] as? String{
                
                db.collection("LifeStory").document(userID).getDocument { (user, error) in
                    if let userData = user?.data(){
                        if let coEditID = userData["coEditID"] as? String,
                            let coEditStatus = userData["coEditStatus"] as? String,
                            coEditStatus == "共同編輯中"{
                            
                            db.collection("LifeStory").document(userID).collection("wishLists").document(documentID).delete()
                            db.collection("LifeStory").document(coEditID).collection("wishLists").document(documentID).delete()
                            
                            self.allWishList.remove(at: indexPath.row)
                            self.wishListTableView.reloadData()
                            
                        }
                        else{
                            db.collection("LifeStory").document(userID).collection("wishLists").document(documentID).delete()
                            
                            self.allWishList.remove(at: indexPath.row)
                            self.wishListTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
