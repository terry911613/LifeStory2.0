//
//  CheckCoEditViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/6/2.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CheckCoEditViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    
    var status: String?
    var coEditID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStatus()
    }
    
    func getStatus(){
        
        emailLabel.text = ""
        statusLabel.text = ""
        confirmButton.isHidden = true
        denyButton.isHidden = true
        statusLabel.isHidden = false
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                
                if let userData = user?.data(){
                    if let coEditStatus = userData["coEditStatus"] as? String,
                        let coEditID = userData["coEditID"] as? String{
                        self.coEditID = coEditID
                        if coEditStatus == "已送出"{
                            self.emailLabel.text = coEditID
                            self.statusLabel.text = coEditStatus
                        }
                        else if coEditStatus == "共同編輯中"{
                            self.emailLabel.text = "與\(coEditID)"
                            self.statusLabel.text = coEditStatus
                        }
                        else{
                            self.emailLabel.text = "尚未送出任何申請"
                            self.statusLabel.text = ""
                        }
                    }
                    else{
                        self.emailLabel.text = "尚未送出任何申請"
                        self.statusLabel.text = ""
                    }
                }
            }
        }
    }
    
    func getAsk(){
        
        emailLabel.text = ""
        statusLabel.text = ""
        statusLabel.isHidden = true
        confirmButton.isHidden = false
        denyButton.isHidden = false
        status = nil
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                
                if let userData = user?.data(){
                    if let coEditStatus = userData["coEditStatus"] as? String,
                        let coEditID = userData["coEditID"] as? String{
                        if coEditStatus == "請審核"{
                            self.emailLabel.text = coEditID
                            self.statusLabel.text = coEditStatus
                            self.status = coEditStatus
                        }
                        else if coEditStatus == "共同編輯中"{
                            self.emailLabel.text = "與\(coEditID)"
                            self.statusLabel.text = coEditStatus
                            self.confirmButton.isHidden = true
                            self.denyButton.isHidden = true
                            self.status = coEditStatus
                        }
                        else{
                            self.emailLabel.text = "未收到任何請求"
                            self.confirmButton.isHidden = true
                            self.denyButton.isHidden = true
                        }
                    }
                    else{
                        self.emailLabel.text = "未收到任何請求"
                    }
                }
            }
        }
    }
    
    @IBAction func segment(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            getStatus()
        }
        else{
            getAsk()
        }
    }
    @IBAction func confirmCoEditButton(_ sender: UIButton) {
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            if let status = status{
                if status == "請審核"{
                    let data: [String: Any] = ["coEditStatus": "共同編輯中",
                                               "isCoEdit": 1]
                    db.collection("LifeStory").document(userID).updateData(data)
                    
                    if let coEditID = coEditID{
                        db.collection("LifeStory").document(coEditID).updateData(data)
                    }
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func denyButton(_ sender: UIButton) {
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            if let status = status{
                if status == "請審核"{
                    let data: [String: Any] = ["coEditStatus": FieldValue.delete(),
                                               "coEditID": FieldValue.delete(),
                                               "isCoEdit": 0]
                    db.collection("LifeStory").document(userID).updateData(data)
                    
                    if let coEditID = coEditID{
                        db.collection("LifeStory").document(coEditID).updateData(data)
                    }
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
