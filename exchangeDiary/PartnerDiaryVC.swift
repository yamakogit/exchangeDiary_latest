//
//  PartnerDiaryVC.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/05/28.
//

import UIKit

class PartnerDiaryVC: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width / 2
        iconImageView.layer.masksToBounds = true
        
        Task {
            do {
                let partnerUID = try await FirebaseClient.shared.getPartnerUID()
                let userData = try await FirebaseClient.shared.getUserData(uid: partnerUID)
                let latestDiary = try await FirebaseClient.shared.getLatestDiary(userData: userData)
                
                print("パートナーID:",partnerUID)
                
                titleLabel.text = latestDiary.title
                userNameLabel.text = userData.name
                dateLabel.text = latestDiary.date
                messageLabel.text = latestDiary.message
                
                let spotPhotoURL = latestDiary.photoURL //写真の表示
                FirebaseClient().getSpotImage(url: spotPhotoURL) { [weak self] image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self!.imageView.image = image
                        }
                    }
                }
                
                let iconURL = userData.iconURL
                FirebaseClient().getSpotImage(url: iconURL) { [weak self] image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self!.iconImageView.image = image
                        }
                    }
                }
                
            } catch {
                print("Error fetching spot data5/6: \(error)")
            }
        }

        // Do any additional setup after loading the view.
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
