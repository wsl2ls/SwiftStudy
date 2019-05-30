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
import HandyJSON

// Model
struct SLModel {
    var headPic:String = ""
    var nickName:String?
    var time:String?
    var source:String?
    var title:NSMutableAttributedString?
}

class ViewController: UIViewController {
    
    //懒加载
    lazy var tableView : UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        //        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(SLTableViewCell.self, forCellReuseIdentifier: "cellId")
        return tableView
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
        
        //async异步追加Block块（async函数不做任何等待）
        DispatchQueue.global(qos: .default).async {
            //处理耗时操作的代码块...
            for _ in 1...20 {
                let model = SLModel.init(headPic: "http://b-ssl.duitang.com/uploads/item/201601/15/20160115140217_HeJAm.jpeg", nickName: "鸡汤", time: "05-28 15:51", source: "我的iPhone XS Max ", title: self.matchesResultOfTitle(title: " @蜜桃君🏀: 🦆你真的太帅了[爱你] https://github.com/wsl2ls // @且行且珍惜_iOS: 发起了话题#我是一只帅哥[爱你]#不信点我看看 https://www.jianshu.com/u/e15d1f644bea"))
                self.dataArray.add(model)
            }
            //操作完成，调用主线程来刷新界面
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    //
    func matchesResultOfTitle(title:String) -> NSMutableAttributedString {
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string:title)
        //        print("\(attributedString.length)")
        //最初富文本的范围
        let titleRange = NSRange(location: 0, length:attributedString.length)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: titleRange)
        //图标+描述 替换HTTP链接
        let urlRanges:[NSRange] = getRangesFromResult(regexStr: "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)", title: title)
        for range in urlRanges {
            let attchimage:NSTextAttachment = NSTextAttachment()
            attchimage.image = UIImage.init(named: "photo")
            attchimage.bounds = CGRect.init(x: 0, y: -2, width: 16, height: 16)
            let replaceStr : NSMutableAttributedString = NSMutableAttributedString.init(attachment: attchimage)
            replaceStr.append(NSAttributedString.init(string: "查看图片")) //添加描述
            replaceStr.addAttributes([NSAttributedString.Key.link :"http://b-ssl.duitang.com/uploads/item/201601/15/20160115140217_HeJAm.jpeg"], range: NSRange(location: 0, length:replaceStr.length))
            replaceStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length:replaceStr.length))
            //注意：涉及到文本替换的 ，每替换一次，原有的富文本位置发生改变，下一轮替换的起点需要重新计算！
            let newLocation = range.location - (titleRange.length - attributedString.length)
            //图标+描述 替换HTTP链接
            attributedString.replaceCharacters(in: NSRange(location: newLocation, length: range.length), with: replaceStr)
            //             print("==== \(attributedString.length)")
        }
        //话题
        let topicRanges:[NSRange] = getRangesFromResult(regexStr: "#[^#]+#", title: attributedString.string)
        for range in topicRanges {
            attributedString.addAttributes([NSAttributedString.Key.link :"https://github.com/wsl2ls"], range: range)
        }
        //用户
        let userRanges:[NSRange] = getRangesFromResult(regexStr: "@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*",title: attributedString.string)
        for range in userRanges {
            attributedString.addAttributes([NSAttributedString.Key.link :"https://www.jianshu.com/u/e15d1f644bea"], range: range)
        }
        //表情
        let emotionRanges:[NSRange] = getRangesFromResult(regexStr: "\\[[^ \\[\\]]+?\\]",title: attributedString.string)
        //经过上述的处理，此时富文本的范围
        let currentTitleRange = NSRange(location: 0, length:attributedString.length)
        for range in emotionRanges {
            let attchimage:NSTextAttachment = NSTextAttachment()
            attchimage.image = UIImage.init(named: "爱你")
            attchimage.bounds = CGRect.init(x: 0, y: 0, width: 16, height: 16)
            let stringImage : NSAttributedString = NSAttributedString.init(attachment: attchimage)
            //注意：每替换一次，原有的位置发生改变，下一轮替换的起点需要重新计算！
            let newLocation = range.location - (currentTitleRange.length - attributedString.length)
            //图片替换表情文字
            attributedString.replaceCharacters(in: NSRange(location: newLocation, length: range.length), with: stringImage)
        }
        
        return attributedString
    }
    //根据匹配规则返回所有的匹配结果
    fileprivate func getRangesFromResult(regexStr : String, title:String) -> [NSRange] {
        // 0.匹配规则
        let regex = try? NSRegularExpression(pattern:regexStr, options: [])
        // 1.匹配结果
        let results = regex?.matches(in:title, options:[], range: NSRange(location: 0, length: NSAttributedString.init(string: title).length))
        // 2.遍历结果 数组
        var ranges = [NSRange]()
        for res in results! {
            ranges.append(res.range)
        }
        return ranges
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
        return 15 + 35 + 15 + 100
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
        cell.configureCell(model: model)
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


