//
//  SignupViewController.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/05/29.
//

import UIKit
import Firebase
import FirebaseAuth

class signinVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    var mailAdress: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailTF.delegate = self
        mailTF.tag = 0
        mailTF.addTarget(self, action: #selector(signinVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        passTF.delegate = self
        passTF.tag = 1
        passTF.addTarget(self, action: #selector(signinVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        passTF.isSecureTextEntry = true
        
        mailTF.attributedPlaceholder = NSAttributedString(string: "Enter MailAdress...",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondarySystemBackground])
        passTF.attributedPlaceholder = NSAttributedString(string: "Enter Password...",
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondarySystemBackground])
        
        self.navigationItem.hidesBackButton = true
        
        // Do any additional setup after loading the view.
    }
    
    
    //TF
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //キーボードを閉じる
        return true //戻り値
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 0 {
            mailAdress = textField.text!
            print("mailAdress: \(mailAdress)")
            
        } else if textField.tag == 1 {
            password = textField.text!
            print("password: \(password)")
        }
    }
    
    
    @IBAction func login() {
        //入力項目の確認...
        var confirmBool = true
        let confirmDict = ["メールアドレス":mailAdress,"パスワード":password]
        for (key, value) in confirmDict {
            if value == "" {
                confirmBool = false
                OtherHosts.alertDef(view: self ,title: "\(key)が\n正しく入力されていません", message: "\(key)を\nもう一度入れ直してください。")
                print("error: \(key) is not found.")
            }
        }
        
        if confirmBool {
            OtherHosts.activityIndicatorView(view: view).startAnimating()
            
            Auth.auth().signIn (withEmail: mailAdress, password: password) {
                [weak self] authResult, error in
                
                guard self != nil else { return }
                if (authResult?.user) != nil {
                    //成功
                    print("succeed: login")
                    OtherHosts.activityIndicatorView(view: (self?.view)!).stopAnimating()
                    self?.performSegue(withIdentifier: "goHome", sender: self)
                    
                } else {
                    //失敗
                    OtherHosts.activityIndicatorView(view: (self?.view)!).stopAnimating()
                    OtherHosts.alertDef(view: self!,title: "エラー", message: "ログインに失敗しました。\n正しい情報を入力してください。")
                    print("error: password is worth.")
                    
                }
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
