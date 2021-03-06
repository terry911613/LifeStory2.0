//
//  AddEventViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/23.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class AddEventViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var selectDateText: String?
    var startDate: Date?
    var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFormatters()
        
        if let selectDateText = selectDateText{
            startDateLabel.text = selectDateText
            startTimeLabel.text = "選取時間"
            endDateLabel.text = selectDateText
            endTimeLabel.text = "選取時間"
        }

    }
    func setFormatters(){
        dateFormatter.dateFormat = "yyyy年M月d日"
        dateFormatter.locale = Locale(identifier: "zh_TW")
        dateFormatter.timeZone = TimeZone(identifier: "zh_TW")
        // 取上午或下午和小時跟分鐘（HH是24小時制，hh是12小時制）
        timeFormatter.dateFormat = "a hh:mm"
        timeFormatter.locale = Locale(identifier: "zh_TW")
        timeFormatter.timeZone = TimeZone(identifier: "zh_TW")
    }
    func getDatePicker(){
        //  顯示 datePicker 方式和大小
        datePicker.locale = Locale(identifier: "zh_TW")
        datePicker.datePickerMode = .time
        datePicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 250)
    }
    
    @IBAction func startSelectButton(_ sender: UIButton) {
        getDatePicker()
        //  建立警告控制器顯示 datePicker
        let dateAlert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        dateAlert.view.addSubview(datePicker)
        //  警告控制器裡的確定按鈕
        let okAction = UIAlertAction(title: "確定", style: .default) { (alert: UIAlertAction) in
            
            if sender.tag == 0{
                self.startTimeLabel.text = self.timeFormatter.string(from: self.datePicker.date)
                self.startDate = self.datePicker.date
//                if let statDate = self.startDate{
//                    self.startDateText = self.dateFormatter.string(from: statDate)
//                }
                print(self.datePicker.date)
            }
            else{
                self.endTimeLabel.text = self.timeFormatter.string(from: self.datePicker.date)
                self.endDate = self.datePicker.date
            }
        }
        dateAlert.addAction(okAction)
        //  警告控制器裡的取消按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        dateAlert.addAction(cancelAction)
        
        self.present(dateAlert, animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: UIButton) {
        upload()
    }
    
    func upload() {
        if let title = self.textField.text,
            let startDate = startDate,
            let endDate = endDate,
            let userID = Auth.auth().currentUser?.email,
            let selectDateText = selectDateText{
            
            SVProgressHUD.show()
            let db = Firestore.firestore()
            let documentID = String(Date().timeIntervalSince1970) + userID
            let data: [String: Any] = ["userID": userID,
                                       "documentID": documentID,
                                       "title": title,
                                       "startDate": startDate,
                                       "endDate": endDate,
                                       "date": selectDateText]
            db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).collection("events").document(documentID).setData(data)
        
            let statusData: [String: String] = ["date": selectDateText]
            db.collection("LifeStory").document(userID).collection("calendar").document(selectDateText).setData(statusData)
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
