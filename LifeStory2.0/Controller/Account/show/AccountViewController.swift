//
//  ExpenditureViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/23.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import ViewAnimator

class AccountViewController: UIViewController {
    
    @IBOutlet weak var totalExpenditureLabel: UILabel!
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var expenditureCollectionView: UICollectionView!
    @IBOutlet weak var incomeCollectionView: UICollectionView!
    @IBOutlet weak var selectDateLabel: UILabel!
    
    var now = Date()
    var selectDateText = ""
    let formatter: DateFormatter = DateFormatter()
    var selectDateExpenditure = [QueryDocumentSnapshot]()
    var selectDateIncome = [QueryDocumentSnapshot]()
    let datePicker = UIDatePicker()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy年M月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone(identifier: "zh_TW")
        selectDateText = formatter.string(from: now)
        selectDateLabel.text = selectDateText
        print(selectDateText)
        
        let db = Firestore.firestore()
        db.collection("accounts").document(self.selectDateText).collection("expenditure").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            print(self.selectDateText)
            print(1)
            if let querySnapshot = querySnapshot {
                let documentChange = querySnapshot.documentChanges[0]
                if documentChange.type == .added {
                    if self.selectDateText == self.formatter.string(from: self.datePicker.date){
                        self.selectDateExpenditure = querySnapshot.documents
                        self.animateExpenditureCollectionView()
                    }
                }
                var totalExpenditure = 0
                for expenditure in querySnapshot.documents{
                    let expenditureMoney = expenditure.data()["money"] as! String
                    totalExpenditure += Int(expenditureMoney)!
                    
                }
                self.totalExpenditureLabel.text = "$\(totalExpenditure)"
            }
        }
        db.collection("accounts").document(self.selectDateText).collection("income").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            print(self.selectDateText)
            if let querySnapshot = querySnapshot {
                let documentChange = querySnapshot.documentChanges[0]
                if documentChange.type == .added {
                    if self.selectDateText == self.formatter.string(from: self.datePicker.date){
                        self.selectDateIncome = querySnapshot.documents
                        self.animateIncomeCollectionView()

                    }
                }
                var totalIncome = 0
                for income in querySnapshot.documents{
                    let incomeMoney = income.data()["money"] as! String
                    totalIncome += Int(incomeMoney)!
                }
                self.totalIncomeLabel.text = "$\(totalIncome)"
            }
        }
    }
    
    @IBAction func selectDate(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        datePicker.locale = Locale(identifier: "zh_TW")
        dateFormatter.locale = datePicker.locale
        dateFormatter.dateStyle = .medium
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 250)
        selectDateText = dateFormatter.string(from: datePicker.date)
        selectDateLabel.text = selectDateText
        
        let dateAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        dateAlert.view.addSubview(datePicker)
        //  警告控制器裡的確定按鈕
        let okAction = UIAlertAction(title: "確定", style: .default) { (alert: UIAlertAction) in
            
            print(1)
            // 按下確定，讓標題改成選取到的日期
            self.selectDateText = dateFormatter.string(from: self.datePicker.date)
            self.selectDateLabel.text = self.selectDateText
            
//            self.selectDateExpenditure = [QueryDocumentSnapshot]()
//            self.selectDateIncome = [QueryDocumentSnapshot]()
            let db = Firestore.firestore()
            db.collection("accounts").document(self.selectDateText).collection("expenditure").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    if querySnapshot.documents.isEmpty{
                        self.selectDateExpenditure = [QueryDocumentSnapshot]()
                        self.animateExpenditureCollectionView()
                    }
                    else{
                        let documentChange = querySnapshot.documentChanges[0]
                        if documentChange.type == .added {
                            if self.selectDateText == self.formatter.string(from: self.datePicker.date){
                                self.selectDateExpenditure = querySnapshot.documents
                                self.animateExpenditureCollectionView()
                            }
                        }
                        var totalExpenditure = 0
                        for expenditure in querySnapshot.documents{
                            let expenditureMoney = expenditure.data()["money"] as! String
                            totalExpenditure += Int(expenditureMoney)!
                            
                        }
                        self.totalExpenditureLabel.text = "$\(totalExpenditure)"
                    }
                    
                }
            }
            db.collection("accounts").document(self.selectDateText).collection("income").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    if querySnapshot.documents.isEmpty{
                        self.selectDateIncome = [QueryDocumentSnapshot]()
                        self.animateIncomeCollectionView()
                    }
                    else{
                        let documentChange = querySnapshot.documentChanges[0]
                        if documentChange.type == .added {
                            if self.selectDateText == self.formatter.string(from: self.datePicker.date){
                                self.selectDateIncome = querySnapshot.documents
                                self.animateIncomeCollectionView()
                            }
                        }
                        var totalIncome = 0
                        for income in querySnapshot.documents{
                            let incomeMoney = income.data()["money"] as! String
                            totalIncome += Int(incomeMoney)!
                        }
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
    func animateExpenditureCollectionView(){
        let animations = [AnimationType.from(direction: .left, offset: 10.0)]
        UIView.animate(views: expenditureCollectionView.visibleCells, animations: animations, reversed: false, initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, animationInterval: 0.1, duration: ViewAnimatorConfig.duration, completion: nil)
        expenditureCollectionView.reloadData()
    }
    func animateIncomeCollectionView(){
        let animations = [AnimationType.from(direction: .left, offset: 10.0)]
        UIView.animate(views: incomeCollectionView.visibleCells, animations: animations, reversed: false, initialAlpha: 0.0, finalAlpha: 1.0, delay: 0, animationInterval: 0.1, duration: ViewAnimatorConfig.duration, completion: nil)
        incomeCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAccount"{
            let addAccountVC = segue.destination as! AddAccountViewController
            addAccountVC.selectDateText = selectDateText
        }
    }
    @IBAction func unwindSegueBackToAccount(segue: UIStoryboardSegue){
    }
    
}

extension AccountViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == expenditureCollectionView{
            return selectDateExpenditure.count
        }
        else{
            return selectDateIncome.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == expenditureCollectionView{
            
//            let db = Firestore.firestore()
//            db.collection("accounts").document(self.selectDateText).collection("expenditure").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
//                if let querySnapshot = querySnapshot {
//                    let documentChange = querySnapshot.documentChanges[0]
//                    if documentChange.type == .added {
//                        if self.selectDateText == self.formatter.string(from: self.datePicker.date){
//                            self.selectDateExpenditure = querySnapshot.documents
//                            self.animateExpenditureCollectionView()
//                        }
//                    }
//
//                }
//            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expenditureCell", for: indexPath) as! DetailCollectionViewCell
            cell.typeLabel.text = selectDateExpenditure[indexPath.row].data()["type"] as? String
           
            if let expenditure = selectDateExpenditure[indexPath.row].data()["money"] as? String{
                 cell.moneyLabel.text = "$ \(expenditure)"
            }
            return cell
        }
        else{
            
//            let db = Firestore.firestore()
//            db.collection("accounts").document(self.selectDateText).collection("income").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
//                if let querySnapshot = querySnapshot {
//                    let documentChange = querySnapshot.documentChanges[0]
//                    if documentChange.type == .added {
//                        if self.selectDateText == self.formatter.string(from: self.datePicker.date){
//                            self.selectDateIncome = querySnapshot.documents
//                            self.animateIncomeCollectionView()
//
//                        }
//                    }
//                }
//            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "incomeCell", for: indexPath) as! DetailCollectionViewCell
            cell.typeLabel.text = selectDateIncome[indexPath.row].data()["type"] as? String
            if let income = selectDateIncome[indexPath.row].data()["money"] as? String{
                cell.moneyLabel.text = "$ \(income)"
            }
            return cell
        }
    }
}

extension AccountViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width/2, height: view.bounds.width/3)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: NSInteger) -> CGFloat {
        return -20
    }
}
