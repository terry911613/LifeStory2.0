//
//  AddAccountViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/23.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase

class AddAccountViewController: UIViewController {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var accountSegmented: UISegmentedControl!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var typeCollectionView: UICollectionView!
    
    var expenditureType = ["飲食", "娛樂", "生活", "交通", "購物", "醫療", "教育", "其他"]
    var incomeType = ["薪水", "獎金", "投資", "補助", "其他"]
    var selectTypeArray = [String]()
    var selectAccount: String?
    var selectType: String?
    var selectDateText = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectTypeArray = expenditureType
        selectAccount = "expenditure"
    }
    @IBAction func selectAccountSegmented(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            selectTypeArray = expenditureType
            typeCollectionView.reloadData()
            selectType = ""
            selectAccount = "expenditure"
        }
        else{
            selectTypeArray = incomeType
            typeCollectionView.reloadData()
            selectType = ""
            selectAccount = "income"
        }
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: UIButton) {
        upload()
    }
    func upload() {
        if let money = Int(self.moneyTextField.text!), let selectType = selectType, let selectAccount = selectAccount, selectType.isEmpty == false{
            let db = Firestore.firestore()
            let data: [String: Any] = ["date": Date(), "money": String(money), "type": selectType]
            db.collection("accounts").document(selectDateText).collection(selectAccount).addDocument(data: data) { (error) in
                if let error = error {
                    print(error)
                }
            }
            let statusData: [String: String] = ["date": selectDateText]
            db.collection("accounts").document(selectDateText).setData(statusData)
            performSegue(withIdentifier: "unwindToAccount", sender: self)
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
        return selectTypeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as! TypeCollectionViewCell
        cell.typeLabel.backgroundColor = UIColor(red: 168/255.0, green: 221/255.0, blue: 248/255.0, alpha: 1)
        cell.typeLabel.text = selectTypeArray[indexPath.row]
        selectType = ""
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.typeLabel.backgroundColor = UIColor(red: 100/255.0, green: 190/255.0, blue: 250/255.0, alpha: 1)
        selectType = selectTypeArray[indexPath.row]
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        cell.typeLabel.backgroundColor = UIColor(red: 168/255.0, green: 221/255.0, blue: 248/255.0, alpha: 1)
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
