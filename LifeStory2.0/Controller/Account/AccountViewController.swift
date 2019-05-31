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
    
    @IBOutlet weak var totalExpenditureLabel: UILabel!
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var accountingCollectionView: UICollectionView!
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var dateLabel: UILabel!
    
    var now = Date()
    var selectDateText = ""
    var selectDate = Date()
    let formatter: DateFormatter = DateFormatter()
    var selectDateAccounting = [QueryDocumentSnapshot]()
    let datePicker = UIDatePicker()
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        editButtonItem.tintColor = .white
        addButton.tintColor = .white
//        navigationItem.rightBarButtonItem?.tintColor = .white
        
        formatter.dateFormat = "yyyy年M月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone(identifier: "zh_TW")
        selectDateText = formatter.string(from: now)
        dateLabel.text = selectDateText
        
        db.collection(userID).document("LifeStory").collection("accounting").document("list").collection(self.selectDateText).order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                if querySnapshot.documents.isEmpty{
                    self.selectDateAccounting = [QueryDocumentSnapshot]()
                    self.totalExpenditureLabel.text = ""
                    self.totalIncomeLabel.text = ""
                }
                else{
                    let documentChange = querySnapshot.documentChanges[0]
                    if documentChange.type == .added {
                        if self.selectDateText == self.formatter.string(from: self.datePicker.date){
                            self.selectDateAccounting = querySnapshot.documents
                            self.animateCollectionView()
                        }
                    }
                    var totalExpenditure = 0
                    var totalIncome = 0
                    for accounting in querySnapshot.documents{
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
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateCollectionView()
    }
    @IBAction func clickDate(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        datePicker.locale = Locale(identifier: "zh_TW")
        dateFormatter.locale = datePicker.locale
        dateFormatter.dateStyle = .medium
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 250)
        
        let dateAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        dateAlert.view.addSubview(datePicker)
        //  警告控制器裡的確定按鈕
        let okAction = UIAlertAction(title: "確定", style: .default) { (alert: UIAlertAction) in
            
            // 按下確定，讓標題改成選取到的日期
            self.selectDateText = dateFormatter.string(from: self.datePicker.date)
            self.dateLabel.text = self.selectDateText
            self.selectDate = self.datePicker.date
            self.db.collection(self.userID).document("LifeStory").collection("accounting").document("list").collection(self.selectDateText).order(by: "index", descending: true).addSnapshotListener { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    if querySnapshot.documents.isEmpty{
                        self.selectDateAccounting = [QueryDocumentSnapshot]()
                        self.accountingCollectionView.reloadData()
                        self.totalExpenditureLabel.text = ""
                        self.totalIncomeLabel.text = ""
                    }
                    else{
                        let documentChange = querySnapshot.documentChanges[0]
                        if documentChange.type == .added {
                            if self.selectDateText == self.formatter.string(from: self.datePicker.date){
                                self.selectDateAccounting = querySnapshot.documents
                                self.animateCollectionView()
                            }
                        }
                        var totalExpenditure = 0
                        var totalIncome = 0
                        for accounting in querySnapshot.documents{
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
            }
        }
        dateAlert.addAction(okAction)
        //  警告控制器裡的取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        dateAlert.addAction(cancelAction)
        
        self.present(dateAlert, animated: true, completion: nil)
    }
    //  顯示特效
    func animateCollectionView(){
        accountingCollectionView.reloadData()
        let animations = [AnimationType.from(direction: .top, offset: 30.0)]
        accountingCollectionView.performBatchUpdates({
            UIView.animate(views: self.accountingCollectionView.orderedVisibleCells,
                           animations: animations, completion: nil)
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAccount"{
            let addAccountVC = segue.destination as! AddAccountViewController
            addAccountVC.selectDateText = selectDateText
            addAccountVC.selectDate = selectDate
            addAccountVC.index = selectDateAccounting.count
        }
    }
}

extension AccountViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectDateAccounting.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accountingCell", for: indexPath) as! DetailCollectionViewCell
        cell.indexPath = indexPath
        cell.delegate = self
        
        let accounting = selectDateAccounting[indexPath.row]
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
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addButton.isEnabled = !editing
        
        let indexPaths = accountingCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths{
            let cell = accountingCollectionView.cellForItem(at: indexPath) as! DetailCollectionViewCell
            cell.deleteViewButton.isHidden = !editing
        }
        
    }

    func delete(at indexPath: IndexPath) {
        let accounting = selectDateAccounting[indexPath.row]
        db.collection(userID).document("LifeStory").collection("accounting").document("list").collection(self.selectDateText).document(accounting.data()["documentID"] as! String).delete { (error) in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
        selectDateAccounting.remove(at: indexPath.row)
        accountingCollectionView.reloadData()
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: accountingCollectionView.bounds.width, height: accountingCollectionView.bounds.width/4)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: NSInteger) -> CGFloat {
        return -5
    }
}
