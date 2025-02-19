//
//  ViewController.swift
//  spotify
//
//  Created by Purv Sinojiya on 14/02/25.
//

import UIKit

class ViewController: UIViewController {
 
    @IBAction func settingbutton(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(
            identifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(
            vc, animated: true)
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

