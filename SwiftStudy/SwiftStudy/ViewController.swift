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
import AlamofireImage
import Kingfisher

class ViewController: UIViewController {
    
    //懒加载
    lazy var tableView : UITableView = {
        return getTableView()
    }()
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Swift Study"
        setupUI()
        getData()
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
    
    // MARK: Data
    func getData() {
        //        let parameters: [String:String] = ["iid": "17769976909","device_id": "41312231473","count": "15","category": "weitoutiao"]
        //        AF.request("https://is.snssdk.com/api/news/feed/v54/?", method: .get, parameters: parameters, encoder: JSONEncoding.default as! ParameterEncoder, headers: HTTPHeaders(), interceptor: nil).responseJSON { (response) in
        //            //            print("Request: \(String(describing: response.request))")   // original url request
        //            print("Response: \(String(describing: response.response))") // http url response
        //            print("Result: \(response.result)")                         // response serialization result
        
        //            if let json = response.result {
        //                print("JSON: \(json)") // serialized json response
        //            }
        
        //            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
        //                print("Data: \(utf8Text)") // original server data as UTF8 string
        //            }
        //        }
        
        
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
    
}

    // MARK: UITableViewDelegate, UITableViewDataSource
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 26
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath);
        cell.textLabel?.text = "hahah"
        let url = URL(string: "https://httpbin.org/image/png")!
        let placeholderImage = UIImage(named: "placeholderImage")!
        let processor = DownsamplingImageProcessor(size: CGSize.init(width: 44, height: 44))
            >> RoundCornerImageProcessor(cornerRadius: 20)
        cell.imageView?.af_setImage(withURL: url, placeholderImage: placeholderImage)
//        cell.imageView?.kf.setImage(with: url, placeholder: placeholderImage, options: [
//            .processor(processor),
//            .scaleFactor(UIScreen.main.scale),
//            .transition(.fade(1)),
//            .cacheOriginalImage
//            ], progressBlock: { (p, k) in
//
//        }, completionHandler: { (Result<RetrieveImageResult1, KingfisherError>) in
//
//        })
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


