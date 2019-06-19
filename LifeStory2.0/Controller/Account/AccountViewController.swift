//
//  ExpenditureViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/23.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import ViewAnimator
import ChameleonFramework

class AccountViewController: UIViewController {
    
    @IBOutlet weak var accountingTableView: UITableView!
    @IBOutlet weak var totalExpenditureLabel: UILabel!
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var dateLabel: UILabel!
    
    var now = Date()
    var selectDateText = ""
    var selectDate = Date()
    let formatter: DateFormatter = DateFormatter()
    var allAccounting = [QueryDocumentSnapshot]()
    var allUserAccounting = [QueryDocumentSnapshot]()
    var allCoEditAccounting = [QueryDocumentSnapshot]()
    let datePicker = UIDatePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone(identifier: "zh_TW")
        selectDateText = formatter.string(from: now)
        dateLabel.text = selectDateText
        
        getAccounting(date: selectDateText)
    }
    
    func getAccounting(date: String){
        
        allAccounting.removeAll()
        accountingTableView.reloadData()
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("LifeStory").document(userID).getDocument { (user, error) in
                if let userData = user?.data(){
                    if let coEditID = userData["coEditID"] as? String,
                        let coEditStatus = userData["coEditStatus"] as? String,
                        coEditStatus == "共同編輯中"{
                        db.collection("LifeStory").document(userID).collection("accounting").document(date).collection("detail").addSnapshotListener { (user, error) in
                            
                            if let user = user{
                                if user.documents.isEmpty{
                                    self.allAccounting.removeAll()
                                    self.allUserAccounting.removeAll()
                                    self.accountingTableView.reloadData()
//                                    self.totalExpenditureAndIncome()
                                    if self.allCoEditAccounting.isEmpty == false{
                                        for coEditAccounting in self.allCoEditAccounting{
                                            self.allAccounting.append(coEditAccounting)
                                            self.accountingTableView.reloadData()
//                                            self.totalExpenditureAndIncome()
                                        }
                                    }
                                    self.totalExpenditureAndIncome()
                                }
                                else{
                                    let documentChange = user.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allAccounting.removeAll()
                                        self.accountingTableView.reloadData()
                                        self.allUserAccounting = user.documents
                                        for userAccounting in self.allUserAccounting{
                                            self.allAccounting.append(userAccounting)
                                            self.accountingTableView.reloadData()
//                                            self.totalExpenditureAndIncome()
                                        }
//                                        self.totalExpenditureAndIncome()
                                        if self.allCoEditAccounting.isEmpty{
                                            self.allCoEditAccounting.removeAll()
                                        }
                                        else{
                                            for coEditAccounting in self.allCoEditAccounting{
                                                self.allAccounting.append(coEditAccounting)
                                                self.accountingTableView.reloadData()
//                                                self.totalExpenditureAndIncome()
                                            }
//                                            self.totalExpenditureAndIncome()
                                        }
                                    }
                                    self.totalExpenditureAndIncome()
                                }
                            }
                        }
                        db.collection("LifeStory").document(coEditID).collection("accounting").document(date).collection("detail").addSnapshotListener{(coEdit, error) in
                            
                            if let coEdit = coEdit{
                                if coEdit.documents.isEmpty{
                                    self.allAccounting.removeAll()
                                    self.allCoEditAccounting.removeAll()
                                    self.accountingTableView.reloadData()
                                    if self.allUserAccounting.isEmpty == false{
                                        for userAccounting in self.allUserAccounting{
                                            self.allAccounting.append(userAccounting)
                                            self.accountingTableView.reloadData()
//                                            self.totalExpenditureAndIncome()
                                        }
//                                        self.totalExpenditureAndIncome()
                                    }
                                    self.totalExpenditureAndIncome()
                                }
                                else{
                                    let documentChange = coEdit.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allAccounting.removeAll()
                                        self.accountingTableView.reloadData()
                                        self.allCoEditAccounting = coEdit.documents
                                        for coEditAccounting in self.allCoEditAccounting{
                                            self.allAccounting.append(coEditAccounting)
                                            self.accountingTableView.reloadData()
//                                            self.totalExpenditureAndIncome()
                                        }
//                                        self.totalExpenditureAndIncome()
                                        if self.allUserAccounting.isEmpty{
                                            self.allUserAccounting.removeAll()
                                        }
                                        else{
                                            for userAccounting in self.allUserAccounting{
                                                self.allAccounting.append(userAccounting)
                                                self.accountingTableView.reloadData()
//                                                self.totalExpenditureAndIncome()
                                            }
//                                            self.totalExpenditureAndIncome()
                                        }
                                    }
                                    self.totalExpenditureAndIncome()
                                }
                            }
                        }
                    }
                    else{
                        db.collection("LifeStory").document(userID).collection("accounting").document(date).collection("detail").order(by: "date", descending: true).addSnapshotListener { (userAccounting, error) in
                            if let userAccounting = userAccounting {
                                if userAccounting.documents.isEmpty{
                                    self.allAccounting.removeAll()
                                    self.accountingTableView.reloadData()
                                    self.totalExpenditureLabel.text = ""
                                    self.totalIncomeLabel.text = ""
                                }
                                else{
                                    let documentChange = userAccounting.documentChanges[0]
                                    if documentChange.type == .added {
                                        self.allAccounting = userAccounting.documents
                                        self.accountingTableView.reloadData()
                                        self.totalExpenditureAndIncome()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func totalExpenditureAndIncome(){
        var totalExpenditure = 0
        var totalIncome = 0
        if allAccounting.isEmpty{
            self.totalExpenditureLabel.text = ""
            self.totalIncomeLabel.text = ""
        }
        else{
            for accounting in allAccounting{
                if accounting.data()["type"] as! String == "expenditure"{
                    let expenditureMoney = accounting.data()["money"] as! String
                    totalExpenditure += Int(expenditureMoney)!
                }
                else{
                    let incomeMoney = accounting.data()["money"] as! String
                    totalIncome += Int(incomeMoney)!
                }
            }
            self.totalExpenditureLabel.text = "-$\(totalExpenditure)"
            self.totalIncomeLabel.text = "$\(totalIncome)"
        }
    }
    
    @IBAction func clickDate(_ sender: UIBarButtonItem) {
        datePicker.locale = formatter.locale
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 250)
        
        let dateAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        dateAlert.view.addSubview(datePicker)
        //  警告控制器裡的確定按鈕
        let okAction = UIAlertAction(title: "確定", style: .default) { (alert: UIAlertAction) in
            
            // 按下確定，讓標題改成選取到的日期
            self.selectDateText = self.formatter.string(from: self.datePicker.date)
            self.dateLabel.text = self.selectDateText
            self.selectDate = self.datePicker.date
            
            self.getAccounting(date: self.selectDateText)
        }
        dateAlert.addAction(okAction)
        //  警告控制器裡的取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        dateAlert.addAction(cancelAction)
        
        self.present(dateAlert, animated: true, completion: nil)
    }
    //  顯示特效
    func animateTableView(){
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        accountingTableView.reloadData()
        UIView.animate(views: accountingTableView.visibleCells, animations: animations, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAccount"{
            let addAccountVC = segue.destination as! AddAccountViewController
            addAccountVC.selectDateText = selectDateText
            addAccountVC.selectDate = selectDate
            addAccountVC.index = allAccounting.count
        }
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccounting.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountingCell", for: indexPath) as! AccountingTableViewCell
        let accounting = allAccounting[indexPath.row]
        print(allAccounting.count)
        if let money = accounting.data()["money"] as? String{
            if accounting.data()["type"] as? String == "expenditure"{
                cell.moneyLabel.text = "-$\(money)"
                cell.backView.backgroundColor = UIColor.flatRedColorDark()
            }
            else{
                cell.moneyLabel.text = "$\(money)"
                cell.backView.backgroundColor = UIColor.flatGreenColorDark()
            }
        }
        cell.typeDetailLabel.text = accounting.data()["typeDetail"] as? String
        cell.userLabel.text = accounting.data()["userID"] as? String
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let accounting = allAccounting[indexPath.row]
            
            let db = Firestore.firestore()
            if let userID = Auth.auth().currentUser?.email,
                let documentID = accounting.data()["documentID"] as? String{
                
                db.collection("LifeStory").document(userID).getDocument { (user, error) in
                    if let userData = user?.data(){
                        if let coEditID = userData["coEditID"] as? String,
                            let coEditStatus = userData["coEditStatus"] as? String,
                            coEditStatus == "共同編輯中"{
                            
                            db.collection("LifeStory").document(userID).collection("accounting").document(self.selectDateText).collection("detail").document(documentID).delete()
                            db.collection("LifeStory").document(coEditID).collection("accounting").document(self.selectDateText).collection("detail").document(documentID).delete()
                            
                            self.allAccounting.remove(at: indexPath.row)
                            self.accountingTableView.reloadData()
                            
                            db.collection("LifeStory").document(userID).collection("accounting").document(self.selectDateText).collection("detail").getDocuments(completion: { (user, error) in
                                if let user = user {
                                    if user.documents.isEmpty{
                                        db.collection("LifeStory").document(userID).collection("accounting").document(self.selectDateText).delete()
                                    }
                                }
                            })
                            db.collection("LifeStory").document(coEditID).collection("accounting").document(self.selectDateText).collection("detail").getDocuments(completion: { (coEdit, error) in
                                if let coEdit = coEdit{
                                    if coEdit.documents.isEmpty{
                                        db.collection("LifeStory").document(coEditID).collection("accounting").document(self.selectDateText).delete()
                                    }
                                }
                            })
                            
                            
                        }
                        else{
                            db.collection("LifeStory").document(userID).collection("accounting").document(self.selectDateText).collection("detail").document(documentID).delete()
                            
                            self.allAccounting.remove(at: indexPath.row)
                            self.accountingTableView.reloadData()
                            
                            db.collection("LifeStory").document(userID).collection("accounting").document(self.selectDateText).collection("detail").getDocuments(completion: { (user, error) in
                                if let user = user{
                                    if user.documents.isEmpty{
                                        db.collection("LifeStory").document(userID).collection("accounting").document(self.selectDateText).delete()
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}
