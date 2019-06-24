//
//  RegisterViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/25.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "註冊失敗", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            else{
                //  success
                print("Registration Successful!")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "registerToMain", sender: self)
                
                let db = Firestore.firestore()
                if let userID = Auth.auth().currentUser?.email{
                    db.collection("LifeStory").document(userID).setData(["userID": userID,
                                                                         "isCoEdit": 0])
                }
            }
        }
    }
    //  隨便按一個地方，彈出鍵盤就會收回
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
