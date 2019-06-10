//
//  ViewController.swift
//  SwiftStudy
//
//  Created by wsl on 2019/5/16.
//  Copyright © 2019 https://github.com/wsl2ls All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import AlamofireImage
import Kingfisher
import HandyJSON
import GDPerformanceView_Swift

class ViewController: UIViewController {
    
    //懒加载
    lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        //        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 0
        //        tableView.estimatedSectionFooterHeight = 0
        //        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(SLTableViewCell.self, forCellReuseIdentifier: "cellId")
        return tableView
    }()
    //中介 负责处理数据和事件
    lazy var presenter : SLPresenter = {
        let presenter = SLPresenter()
        return presenter
    }()
    var dataArray = NSMutableArray()
    var layoutArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Swift Study"
        //性能监测工具
        PerformanceMonitor.shared().start()
        self.presenter.getData { (dataArray, layoutArray) in
            //            print("刷新")
            self.dataArray = dataArray
            self.layoutArray = layoutArray
            self.tableView.reloadData()
        }
        self.presenter.fullTextBlock = { (indexPath) in
            self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }
        setupUI()
    }
    
    // MARK: UI
    func setupUI() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row > self.layoutArray.count - 1 { return 0 }
        let layout : SLLayout = self.layoutArray[indexPath.row] as! SLLayout
        return layout.cellHeight
    }
    func tableView(_ tableVdiew: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        let cell:SLTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SLTableViewCell
        let model:SLModel = self.dataArray[indexPath.row] as! SLModel
        var layout:SLLayout?
        if indexPath.row <= self.layoutArray.count - 1 {
            layout = self.layoutArray[indexPath.row] as? SLLayout
        }
        cell.configureCell(model: model, layout: layout)
        cell.delegate = self.presenter
        cell.cellIndexPath = indexPath
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
