//
//  CoEditViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/6/2.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class CoEditViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        
        let db = Firestore.firestore()
                    
        if let coEditID = self.emailTextfield.text,
            let userID = Auth.auth().currentUser?.email{
            let data: [String: Any] = ["coEditID": coEditID,
                                       "coEditStatus": "已送出"]
            db.collection("LifeStory").document(userID).updateData(data)
            
            let data2: [String: Any] = ["coEditID": userID,
                                        "coEditStatus": "請審核"]
            db.collection("LifeStory").document(coEditID).updateData(data2)
            SVProgressHUD.dismiss()
            self.dismiss(animated: true, completion: nil)
        }
    }
    //  隨便按一個地方，彈出鍵盤就會收回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
