//
//  EditPersonalViewController.swift
//  LifeStory2.0
//
//  Created by 李泰儀 on 2019/6/2.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import SVProgressHUD

class EditPersonalViewController: UIViewController {

    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    var name: String?
    var imageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = name,
            let imageUrl = imageUrl{
             nameTextfield.text = name
            image.kf.setImage(with: URL(string: imageUrl))
        }
    }
    @IBAction func tapImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController,animated: true)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButton(_ sender: UIButton) {
        upload()
    }
    
    func upload(){
        
        let db = Firestore.firestore()
        
        if let userID = Auth.auth().currentUser?.email,
            let userImage = image.image,
            let userName = nameTextfield.text, userName.isEmpty == false{
            //DocumentReference 指定位置
            //照片參照
            SVProgressHUD.show()
            let storageReference = Storage.storage().reference()
            let fileReference = storageReference.child(UUID().uuidString + ".jpg")
            let size = CGSize(width: 640, height: userImage.size.height * 640 / userImage.size.width)
            UIGraphicsBeginImageContext(size)
            userImage.draw(in: CGRect(origin: .zero, size: size))
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let data = resizeImage?.jpegData(compressionQuality: 0.8){
                fileReference.putData(data,metadata: nil) {[weak self](metadate, error) in
                    guard let _ = metadate, error == nil else {
                        SVProgressHUD.dismiss()
                        self!.errorAlert()
                        return
                    }
                    fileReference.downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else {
                            SVProgressHUD.dismiss()
                            self!.errorAlert()
                            return
                        }
                        let data: [String: Any] = ["userImage": downloadURL.absoluteString,
                                                   "userName": userName]
                        db.collection("LifeStory").document(userID).updateData(data, completion: { (error) in
                            guard error == nil else {
                                SVProgressHUD.dismiss()
                                self!.errorAlert()
                                return
                            }
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "上傳完成", message: nil, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "確定", style: .default, handler: { (ok) in
                                self!.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(ok)
                            self!.present(alert, animated: true, completion: nil)
                        })
                        SVProgressHUD.dismiss()
                    })
                }
            }
        }
        else{
            let alert = UIAlertController(title: "請填寫完整", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    func errorAlert(){
        let alert = UIAlertController(title: "上傳失敗", message: "請稍後再試一次", preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension EditPersonalViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let select = info[.originalImage] as? UIImage
        image.image = select
        picker.dismiss(animated: true, completion: nil)
    }
}
