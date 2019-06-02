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
    let goalArray = ["短期目標", "中期目標", "長期目標"]
    var selectGoal = ""
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
        if let wishText = self.wishListTextField.text, wishText.isEmpty == false, selectGoal.isEmpty == false, let index = index{
            SVProgressHUD.show()
            let db = Firestore.firestore()
            let userID = Auth.auth().currentUser!.uid
            let timeStamp = String(Date().timeIntervalSince1970)
            let data: [String: Any] = ["documentID": timeStamp, "index": index, "wishListText": wishText, "goal": selectGoal, "date": Date()]
            db.collection(userID).document("LifeStory").collection("wishLists").document(timeStamp).setData(data) { (error) in
                if let error = error {
                    print("Error writing document: \(error)")
                } else {
                    print("Document successfully written!")
                }
            }
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
        return goalArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goalCell", for: indexPath) as! StatusCollectionViewCell
        cell.statusView.backgroundColor = color[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! StatusCollectionViewCell
        cell.statusLabel.text = ""
        cell.statusLabel.text = goalArray[indexPath.row]
        cell.statusLabel.textColor = .white
        selectGoal = goalArray[indexPath.row]
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! StatusCollectionViewCell
        cell.statusLabel.text = ""
    }
}
