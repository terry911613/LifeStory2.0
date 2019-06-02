//
//  AddDiaryViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/5/25.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import TTGEmojiRate
import Firebase
import FirebaseAuth
import SVProgressHUD

class AddDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var diaryTextView: UITextView!
    @IBOutlet weak var emojiView: EmojiRateView!
    @IBOutlet weak var titleTextField: UITextField!
    
    let dateFormatter = DateFormatter()
    var todayDateString = ""
    var rate: Float = 2.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy年M月dd日"
        dateFormatter.locale = Locale(identifier: "zh_TW")
        dateFormatter.timeZone = TimeZone(identifier: "zh_TW")
        todayDateString = dateFormatter.string(from: Date())
        dateLabel.text = todayDateString
        
        emojiView.rateValueChangeCallback = {(rateValue: Float) -> Void in
            self.rate = rateValue
        }
    }

    @IBAction func selectPhotoButton(_ sender: UIButton) {
        let imagepicker = UIImagePickerController()
        imagepicker.sourceType = .photoLibrary
        imagepicker.delegate = self
        present(imagepicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        photoButton.setImage(image, for: .normal)
        photoButton.imageView?.contentMode = .scaleAspectFill
        photoButton.setTitle(nil, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        upload()
    }
    func upload() {
        SVProgressHUD.show()
        let db = Firestore.firestore()
        let storageReference = Storage.storage().reference()
        let fileReference = storageReference.child(UUID().uuidString + ".jpg")
        if let image = self.photoButton.image(for: .normal){
            let size = CGSize(width: 640, height:
                image.size.height * 640 / image.size.width)
            UIGraphicsBeginImageContext(size)
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        else{
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "請增加照片", message: "", preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let data = resizeImage?.jpegData(compressionQuality: 0.8) {
            fileReference.putData(data, metadata: nil) { (metadata, error) in
                guard let _ = metadata, error == nil else {
                    SVProgressHUD.dismiss()
                    return
                }
                fileReference.downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else {
                        SVProgressHUD.dismiss()
                        return
                    }
                    let timeStamp = String(Date().timeIntervalSince1970)
                    let data: [String: Any] = ["documentID": timeStamp, "date": Date(), "dateString": self.todayDateString, "photoUrl": downloadURL.absoluteString, "title": self.titleTextField.text!, "mood": self.rate, "diaryText": self.diaryTextView.text!]
                    let userID = Auth.auth().currentUser!.uid
                    db.collection(userID).document("LifeStory").collection("diaries").document(timeStamp).setData(data, completion: { (error) in
                        guard error == nil else {
                            SVProgressHUD.dismiss()
                            return
                        }
                        SVProgressHUD.dismiss()
                        self.navigationController?.popViewController(animated: true)
                    })
                })
            }
        }
    }
}
