//
//  OtherHostsVC.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/05/29.
//

import UIKit

class OtherHosts {

    
    //activityIndicatorView
    static func activityIndicatorView(view:UIView) -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.center = view.center
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.color = .darkGray
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }
    
    
    //1ボタン
    static func alertDef(view: UIViewController, title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        view.present(alertVC, animated: true)
    }
    
    //2ボタン
    static func alertDoubleDef(view: UIViewController, alertTitle: String, alertMessage: String, b1Title: String, b1Style: UIAlertAction.Style, b2Title: String, b1Handler: ((UIAlertAction) -> Void)? = nil) {
        let alertVC = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: b1Title, style: b1Style, handler: b1Handler))
        alertVC.addAction(UIAlertAction(title: b2Title, style: .cancel, handler: nil))
        view.present(alertVC, animated: true)
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
