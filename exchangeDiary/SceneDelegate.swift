//
//  SceneDelegate.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/05/24.
//

import UIKit
import Firebase
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: Any!
    
    let db = Firestore.firestore()
    var userUid: String = ""


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        autoLogin()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    func autoLogin() {
        
        var date1 = ""
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour], from: now)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if let hour = components.hour, hour >= 18 {
            //18時以降
            date1 = dateFormatter.string(from: Date())
            
        } else {
            //18時以前 -> -1日する
            let calendar = Calendar.current
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
                date1 = dateFormatter.string(from: yesterday)
            }
        }
        
        
        authListener = Auth.auth().addStateDidChangeListener({ auth, user in
            //その後呼ばれないようにデタッチする
            Auth.auth().removeStateDidChangeListener(self.authListener! as! NSObjectProtocol)
            if user != nil {
                DispatchQueue.main.async {
                    print("loginされています")
                    //ログインされているのでメインのViewへ
                    Task {
                        do { //これに対するもの try await FirebaseClient.shared.getUserData()
                            
                            let groupData = try await FirebaseClient.shared.getGroupData()
                            let userData = try await FirebaseClient.shared.getUserData()
                            
                            print("-----データ-----")
                            print("date1",date1)
                            print("groupData.latestDate",groupData.latestDate ?? "なし")
                            print("userData.id",userData.id ?? "なし")
                            print("groupData.latestOpenedUUID",groupData.latestOpenedUUID ?? "なし")
                            
                            if date1 != groupData.latestDate {
                             print("date1一致していません")
                            }
                            
                            if userData.id != groupData.latestOpenedUUID {
                                print("userData.id一致していません")
                            }
                            
                            if date1 != groupData.latestDate && userData.id != groupData.latestOpenedUUID {
                                //記入画面へ
                                print("記入なし")
                                self.gotoDiary()
                                
                            } else {
                                //ホーム画面へ
                                print("記入あり")
                                self.gotoHome()
                                
                            }
                            
                        } catch {
                            print("Error fetching spot data: \(error)")
                            //getUserData() - エラー
                            //ホーム画面へ
                            self.gotoHome()
                        }
                    }
                }
                
            } else {
                //認証されていなければ初期画面表示
                //ログインされていない
                print("loginされていません")
                self.gotoRegister()
            }
        })
    }
    
    
    
    
    func gotoHome() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as! UITabBarController
            window?.rootViewController = vc
    }
    
    func gotoRegister() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "register") as! UINavigationController
            window?.rootViewController = vc
    }
    
    func gotoDiary() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "diary") as! UINavigationController
            window?.rootViewController = vc
    }


}

