//
//  SignupViewController.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/05/29.
//

import UIKit
import Firebase
import FirebaseFirestore

class groupManagerxVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textFieldx: UITextField!
    
    var groupID: String = ""
    var userName: String = ""
    var iconURL: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldx.delegate = self
        textFieldx.addTarget(self, action: #selector(groupManagerxVC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        userName = UserDefaults.standard.string(forKey: "userName") ?? "名前なし"
        iconURL = UserDefaults.standard.string(forKey: "iconURL") ?? "iconURLなし"
        
        // Do any additional setup after loading the view.
    }
    
    
    //該当groupData取得・gUIDの取り出し・
    @IBAction func register() {
        
        if groupID == "" {
            OtherHosts.alertDef(view: self, title: "エラー", message: "groupIDが入力されていません")
        } else {
            
            
            Task {
                do {
                    let groupData = try await FirebaseClient.shared.searchGroup(groupID: self.groupID)
                    
                    if groupData == nil {
                        //該当データなし
                        OtherHosts.alertDef(view: self, title: "エラー", message: "入力されたグループは存在しないか、すでに満員です")
                    } else {
                        //該当データあり
                        //UserData取得・gUIDの書き込み・userData保存
                        var userData = try await FirebaseClient.shared.getUserData()
                        userData.groupUID = groupData?.id ?? ""
                        userData.name = userName
                        userData.iconURL = iconURL
                        try await FirebaseClient.shared.saveNewData(userData: userData)
                        performSegue(withIdentifier: "goNext", sender: self)
                    }
                } catch {
                    print("Error: ")
                }
            }
            
        }
        
    }
    
    
    @IBAction func createNewGroup() {
        
        let groupIDNumber: Int = Int.random(in: 100000...999999)
        
        let groupIDLetterArray = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        let groupIDLetter1 = groupIDLetterArray [Int.random(in: 0...51)]
        let groupIDLetter2 = groupIDLetterArray [Int.random(in: 0...51)]
        
        let groupID = "\(groupIDLetter1)\(groupIDLetter2)\(groupIDNumber)"
     
        let groupData = FirebaseClient.GroupDataset(groupID: groupID, latestDate: "", latestOpenedUUID: "")
        let userData = FirebaseClient.UserDataSet(name: userName, iconURL: iconURL, groupUID: "", latestDate: "", diary: [])
        
        Task {
            do {
                try await FirebaseClient.shared.saveNewData(userData: userData, groupData: groupData)
                //完了後
                performSegue(withIdentifier: "goNext", sender: self)
            } catch {
                print("Error: ")
            }
        }
        
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldx.resignFirstResponder() //キーボードを閉じる
        return true
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        groupID = textFieldx.text!
        print("groupID: \(groupID)")
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
