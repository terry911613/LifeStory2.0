//
//  AddAccountViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/23.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseAuth
import SVProgressHUD

class AddAccountViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var accountSegmented: UISegmentedControl!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var typeCollectionView: UICollectionView!
    
    var expenditureType = ["飲食", "娛樂", "生活", "交通", "購物", "醫療", "教育", "其他"]
    var incomeType = ["薪水", "獎金", "投資", "補助", "其他"]
    var selectTypeDetailArray = [String]()
    var selectType: String?
    var selectTypeDetail: String?
    var selectDateText = ""
    var selectDate = Date()
    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectTypeDetailArray = expenditureType
        selectType = "expenditure"
    }
    @IBAction func selectAccountSegmented(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            selectTypeDetailArray = expenditureType
            typeCollectionView.reloadData()
            selectTypeDetail = ""
            selectType = "expenditure"
        }
        else{
            selectTypeDetailArray = incomeType
            typeCollectionView.reloadData()
            selectTypeDetail = ""
            selectType = "income"
        }
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: UIButton) {
        upload()
    }
    func upload() {
        if let money = Int(self.moneyTextField.text!),
            let selectType = selectType,
            let selectTypeDetail = selectTypeDetail,
            selectTypeDetail.isEmpty == false,
            let index = index,
            let userID = Auth.auth().currentUser?.email,
            let uid = Auth.auth().currentUser?.uid{
            
            SVProgressHUD.show()
            
            let db = Firestore.firestore()
            let documentID = String(Date().timeIntervalSince1970) + userID
            let data: [String: Any] = ["userID": userID,
                                       "documentID": documentID,
                                       "index": index,
                                       "date": Date(),
                                       "money": String(money),
                                       "type": selectType,
                                       "typeDetail": selectTypeDetail]
            db.collection("LifeStory").document(userID).collection("accounting").document(selectDateText).collection("detail").document(documentID).setData(data) { (error) in
                if let error = error {
                    print(error)
                }
            }
            
            
            
            let statusData: [String: Any] = ["date": selectDate,
                                             "documentID": selectDateText]
            db.collection("LifeStory").document(userID).collection("accounting").document(selectDateText).setData(statusData)
            
            SVProgressHUD.dismiss()
            dismiss(animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "請填寫正確", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    //  隨便按一個地方，彈出鍵盤就會收回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension AddAccountViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectTypeDetailArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as! TypeCollectionViewCell
        cell.typeLabel.backgroundColor = UIColor.flatMint()
        cell.typeLabel.text = selectTypeDetailArray[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.typeLabel.backgroundColor = UIColor.flatMintColorDark()
        selectTypeDetail = selectTypeDetailArray[indexPath.row]
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.typeLabel.backgroundColor = UIColor.flatMint()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: typeCollectionView.bounds.width/4, height: typeCollectionView.bounds.width/4)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: NSInteger) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -5
    }
}
