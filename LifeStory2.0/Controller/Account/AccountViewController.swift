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
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var now = Date()
    var selectDateText = ""
    var selectDate = Date()
    let formatter: DateFormatter = DateFormatter()
    var selectDateAccounting = [QueryDocumentSnapshot]()
    let datePicker = UIDatePicker()
//    var indexArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for i in selectDateAccounting{
//            let pk = i.data()["pk"] as! Int
//            indexArray.append(pk)
//        }
        
//        accountingCollectionView.addGestureRecognizer(longPress)
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        formatter.dateFormat = "yyyy年M月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone(identifier: "zh_TW")
        selectDateText = formatter.string(from: now)
        dateButton.setTitle(selectDateText, for: .normal)
        
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        db.collection(userID).document("LifeStory").collection("accounting").document(self.selectDateText).collection("list").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
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
                            let expenditureMoney = accounting.data()["Money"] as! String
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
//    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
//        switch sender.state {
//        case .began:
//            guard let selectedIndexPath = accountingCollectionView.indexPathForItem(at: sender.location(in: accountingCollectionView)) else {
//                break
//            }
//            accountingCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
//        case .changed:
//            accountingCollectionView.updateInteractiveMovementTargetPosition(sender.location(in: sender.view!))
//        case .ended:
//            accountingCollectionView.endInteractiveMovement()
//        default:
//            accountingCollectionView.cancelInteractiveMovement()
//        }
//    }
    @IBAction func dateButton(_ sender: UIButton) {
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
            self.dateButton.setTitle(self.selectDateText, for: .normal)
            self.selectDate = self.datePicker.date
            
            let db = Firestore.firestore()
            let userID = Auth.auth().currentUser!.uid
            db.collection(userID).document("LifeStory").collection("accounting").document(self.selectDateText).collection("list").order(by: "index", descending: true).addSnapshotListener { (querySnapshot, error) in
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
                                let expenditureMoney = accounting.data()["Money"] as! String
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
    
    @IBAction func trashButton(_ sender: UIBarButtonItem) {
        
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
    
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//
////        let db = Firestore.firestore()
////        for i in sourceIndexPath.item...destinationIndexPath.item{
////            let index = selectDateAccounting[i].data()["index"] as! Int
////            let frankDocRef = db.collection("users").document("\(indexArray[i])")
////            frankDocRef.updateData(["pk": index + 1])
////        }
//        let accounting = selectDateAccounting.remove(at: sourceIndexPath.item)
//        selectDateAccounting.insert(accounting, at: destinationIndexPath.item)
////        let a = indexArray.remove(at: sourceIndexPath.item)
////        indexArray.insert(a, at: destinationIndexPath.item)
//
//        print(sourceIndexPath.item)
//        print(destinationIndexPath.item)
//    }
    
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
