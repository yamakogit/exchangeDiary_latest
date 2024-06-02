//
//  SetttingsViewController.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/06/02.
//

import UIKit
import Firebase
import FirebaseAuth

class SetttingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var groupIDLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    var iconURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true
        
        Task {
            do {
                let userData = try await FirebaseClient.shared.getUserData()
                let groupData = try await FirebaseClient.shared.getGroupData()
                
                userNameLabel.text = userData.name
                groupIDLabel.text = groupData.groupID
                
                
                let iconURL = userData.iconURL
                FirebaseClient().getSpotImage(url: iconURL) { [weak self] image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self!.imageView.image = image
                        }
                    }
                }
                
            } catch {
                print("Error fetching spot data5/6: \(error)")
            }
        }

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func changePhoto() {
        //写真の変更
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
    
    
    @IBAction func logout() {
        OtherHosts.alertDoubleDef(view: self, alertTitle: "ログアウトしますか？", alertMessage: "一度ログアウトすると、\n再ログインするまで使用できません。", b1Title: "ログアウト", b1Style: .destructive, b2Title: "キャンセル") { _ in
            
            OtherHosts.activityIndicatorView(view: self.view).startAnimating()
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
                OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                OtherHosts.alertDef(view: self, title: "ログアウト完了", message: "トップページへ戻ります") { _ in
                    
                    let appDomain = Bundle.main.bundleIdentifier
                    UserDefaults.standard.removePersistentDomain(forName: appDomain!)
                    
                    guard let window = UIApplication.shared.keyWindow else { return }
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if window.rootViewController?.presentedViewController != nil {
                        // モーダルを開いていたら閉じてから差し替え
                        window.rootViewController?.dismiss(animated: true) {
                            window.rootViewController = storyboard.instantiateViewController(withIdentifier: "register") as! UINavigationController
                        }
                    } else {
                        // モーダルを開いていなければそのまま差し替え
                        window.rootViewController = storyboard.instantiateViewController(withIdentifier: "register") as! UINavigationController
                    }
                }
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                OtherHosts.alertDef(view:self, title: "エラー", message: "ログアウトに失敗しました")
            }
        }
    }
    
    
    @IBAction func deleteAccount() {
        
        OtherHosts.alertDoubleDef(view: self, alertTitle: "アカウント削除しますか？", alertMessage: "アカウントを削除すると、再度ログインするまでアプリを利用できません。", b1Title: "アカウント削除", b1Style: .destructive, b2Title: "キャンセル") { _ in
            
            OtherHosts.activityIndicatorView(view: self.view).startAnimating()
            
            //UD ALL削除
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            
            let user = Auth.auth().currentUser
            user?.delete { error in
                if error != nil {
                    // An error happened.
                    OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                    OtherHosts.alertDef(view:self, title: "エラー", message: "アカウント削除に失敗しました")
                    
                } else {
                    // Account deleted.
                    OtherHosts.activityIndicatorView(view: self.view).stopAnimating()
                    OtherHosts.alertDef(view: self, title: "アカウント削除完了", message: "トップページへ戻ります") { _ in
                        guard let window = UIApplication.shared.keyWindow else { return }
                        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        if window.rootViewController?.presentedViewController != nil {
                            // モーダルを開いていたら閉じてから差し替え
                            window.rootViewController?.dismiss(animated: true) {
                                window.rootViewController = storyboard.instantiateInitialViewController()
                            }
                        } else {
                            // モーダルを開いていなければそのまま差し替え
                            window.rootViewController = storyboard.instantiateInitialViewController()
                        }
                    }
                }
            }
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
                    var userData = try await FirebaseClient.shared.getUserData()
                    userData.iconURL = self.iconURL
                    try await FirebaseClient.shared.saveNewData(userData: userData)
                    
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
