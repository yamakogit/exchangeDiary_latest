//
//  FinishVC.swift
//  exchangeDiary
//
//  Created by 山田航輝 on 2024/06/08.
//

import UIKit

class FinishVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont(name: "yosugara", size: 20)!
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: font
        ]
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

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
