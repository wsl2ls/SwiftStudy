//
//  ViewController.swift
//  SwiftStudy
//
//  Created by wsl on 2019/5/16.
//  Copyright © 2019 wsl. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    //懒加载
    lazy var tableView : UITableView = {
        return getTableView()
    }()
    var dataArray: NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Swift Study"
        setupUI()
        
    }
    
    // MARK: setupUI
    func setupUI() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    // MARK: Getter
    func getTableView() -> UITableView{
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        //        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        return tableView
    }
    
    // MARK: UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 26
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath);
        cell.textLabel?.text = "hahah"
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}

