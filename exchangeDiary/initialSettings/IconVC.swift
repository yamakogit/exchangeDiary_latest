//
//  IconVC.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/06/02.
//

import UIKit

class IconVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var selectPhotoButton: UIButton!
    
    var iconURL = ""
    var iconTF = false

    override func viewDidLoad() {
        super.viewDidLoad()
        selectPhotoButton.isHidden = false
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        let picker = UIImagePickerController()  //IV
            picker.sourceType = .photoLibrary
            picker.delegate = self
            present(picker, animated: true)
        } else {
            
            print("PhotoLibrary is not available.")
            OtherHosts.alertDef(view: self, title: "エラー", message: "フォトライブラリへのアクセスを許可してください")
        }
    }
    
    @IBAction func setIcon() {
        if iconURL == "" {
            if iconTF {
                //url取得中
                OtherHosts.alertDef(view: self, title: "アイコンを設定中", message: "数秒後にもう一度押してください")
            } else {
                //選択なし
                OtherHosts.alertDef(view: self, title: "アイコンが未設定", message: "アイコンを選択してください")
            }
            
        } else {
            //iconOK!
            UserDefaults.standard.set(iconURL, forKey: "iconURL")
            self.performSegue(withIdentifier: "goNext", sender: self)
        }
    }
    
    
    // キャンセルボタン時
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //写真撮影終了時
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            
            Task {
                do {
                    let photoURL = try await FirebaseClient.shared.saveDiaryImage(diaryImage: imageView.image!)
                    self.iconURL = photoURL
                    print("PHOTOURL: \(photoURL)")
                    iconTF = true
                    selectPhotoButton.isHidden = true
                } catch {
                    print("Error: \(error)")
                }
                picker.dismiss(animated: true, completion: nil) // フォトライブラリを閉じる処理をここに追加
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
