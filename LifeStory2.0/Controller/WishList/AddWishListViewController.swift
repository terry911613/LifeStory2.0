//
//  AddWishListViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/24.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class AddWishListViewController: UIViewController {

    @IBOutlet weak var wishListTextField: UITextField!
    @IBOutlet weak var statusCollectionView: UICollectionView!
    
    let color: [UIColor] = [UIColor.flatMint(), UIColor.flatYellow(), UIColor.flatWatermelon()]
    let colorText = ["green", "yellow", "red"]
    var selectColor = ""
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: UIButton) {
        upload()
    }
    func upload() {
        if let wishText = self.wishListTextField.text, wishText.isEmpty == false, selectColor.isEmpty == false, let index = index{
            SVProgressHUD.show()
            let db = Firestore.firestore()
//            let data: [String: Any] = ["Date": Date(), "WishListText": wishText, "Color": selectColor]
            let userID = Auth.auth().currentUser!.uid
            let timeStampInt = String(Date().timeIntervalSince1970)
            db.collection(userID).document("LifeStory").collection("wishLists").document(timeStampInt).setData(
                ["documentID": timeStampInt,
                 "index": index,
                 "wishListText": wishText,
                 "color": selectColor
            ]) { (error) in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            }
//            db.collection(userID).document("LifeStory").collection("WishLists").addDocument(data: data) { (error) in
//                if let error = error {
//                    print(error)
//                }
//            }
//            let wishListData: [String: Any] = ["Date": Date()]
//            db.collection(userID).document("LifeStory").collection("WishLists").document("WishList").setData(wishListData)
            SVProgressHUD.dismiss()
            dismiss(animated: true, completion: nil)
        }

        else{
            let alert = UIAlertController(title: "請填寫完整", message: "", preferredStyle: .alert)
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

extension AddWishListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! StatusCollectionViewCell
        cell.statusView.backgroundColor = color[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! StatusCollectionViewCell
        cell.statusLabel.text = ""
        if indexPath.row == 0{
            cell.statusLabel.text = "小目標"
            cell.statusLabel.textColor = .white
        }
        else if indexPath.row == 1{
            cell.statusLabel.text = "中目標"
            cell.statusLabel.textColor = .white
        }
        else{
            cell.statusLabel.text = "大目標"
            cell.statusLabel.textColor = .white
        }
        selectColor = colorText[indexPath.row]
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! StatusCollectionViewCell
        if indexPath.row == 0{
            cell.statusLabel.text = ""
        }
        else if indexPath.row == 1{
            cell.statusLabel.text = ""
        }
        else{
            cell.statusLabel.text = ""
        }
    }
}

extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
