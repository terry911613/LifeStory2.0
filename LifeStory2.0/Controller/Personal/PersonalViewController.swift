//
//  PersonalViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/25.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PersonalViewController: UIViewController {
    
    @IBOutlet weak var personalTableView: UITableView!
    
    var personalArray = ["送出共同編輯", "查看共同編輯請求", "修改個人資料"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
