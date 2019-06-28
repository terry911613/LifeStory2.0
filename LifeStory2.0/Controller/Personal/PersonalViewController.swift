//
//  PersonalViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/25.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PersonalViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var personalTableView: UITableView!
    
    var personalArray = ["送出共同編輯", "查看共同編輯請求", "編輯個人資訊"]
    var name: String?
    var image: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.email{
            db.collection("LifeStory").document(userID).addSnapshotListener { (user, error) in
                
                if let userData = user?.data(){
                    if let userName = userData["userName"] as? String,
                        let userImage = userData["userImage"] as? String{
                        
                        self.name = userName
                        self.image = userImage
                        
                        self.userNameLabel.text = userName
                        self.userImageView.kf.setImage(with: URL(string: userImage))
                    }
                }
            }
        }
    }
    
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "goLogin", sender: self)
        }
        catch{
            print("error, there was a problem logging out")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPeraonalSegue"{
            let editVC = segue.destination as! EditPersonalViewController
            if let name = name,
                let image = image{
                editVC.name = name
                editVC.imageUrl = image
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension PersonalViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell", for: indexPath)
        cell.textLabel?.text = personalArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            performSegue(withIdentifier: "requestCoEditSegue", sender: self)
        }
        else if indexPath.row == 1{
            performSegue(withIdentifier: "checkCoEditSegue", sender: self)
        }
        else if indexPath.row == 2{
            performSegue(withIdentifier: "editPeraonalSegue", sender: self)
        }
    }
}


