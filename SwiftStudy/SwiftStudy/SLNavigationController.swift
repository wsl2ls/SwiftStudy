//
//  SLNavigationController.swift
//  SwiftStudy
//
//  Created by wsl on 2019/7/17.
//  Copyright © 2019 wsl. All rights reserved.
//

import UIKit

class SLNavigationController: UINavigationController {
    //隐藏状态栏
    var isStatusBarHidden = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return isStatusBarHidden
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
