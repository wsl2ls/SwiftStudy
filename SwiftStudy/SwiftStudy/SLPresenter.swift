//
//  SLPresenter.swift
//  SwiftStudy
//
//  Created by wsl on 2019/6/5.
//  Copyright © 2019 wsl. All rights reserved.
//

import UIKit

// 数据模型
struct SLModel {
    var headPic: String = ""
    var nickName: String?
    var time: String?
    var source: String?
    var title: String?
}
// 布局信息
struct SLLayout {
    var attributedString: NSMutableAttributedString?
    var cellHeight: CGFloat = 0
    var expan: Bool = false //是否展开
}

//正则匹配规则
let KRegularMatcheHttpUrl = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" // 图标+描述 替换HTTP链接
let KRegularMatcheTopic = "#[^#]+#"    // 话题匹配 #话题#
let KRegularMatcheUser = "@[\\u4e00-\\u9fa5a-zA-Z0-9_-]*"  // @用户匹配
let KRegularMatcheEmotion = "\\[[^ \\[\\]]+?\\]"   //表情匹配 [爱心]

let KTitleLengthMax = 80  // 默认标题最多字符个数，但不固定，取决于高亮的字符是否会被截断
typealias SLGetDataCompleteBlock = (_ dataArray: NSMutableArray, _ layoutArray: NSMutableArray) ->Void

class SLPresenter: NSObject{
    
    var dataArray = NSMutableArray()
    var layoutArray = NSMutableArray()
    var completeBlock: SLGetDataCompleteBlock?
    
    // MARK: Data
    // @escaping 防止该参数在当前函数执行完成后释放，常用在异步操作中
    func getData(completeBlock: @escaping SLGetDataCompleteBlock) {
        self.completeBlock = completeBlock
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
                let model = SLModel(headPic: "http://b-ssl.duitang.com/uploads/item/201601/15/20160115140217_HeJAm.jpeg", nickName: "鸡汤", time: "05-28 15:51", source: "我的iPhone XS Max ", title: " @wsl2ls: 不要迷恋哥，哥只是一个传说 https://github.com/wsl2ls, 是终将要成为#海贼王#的男人！// @蜜桃君🏀: 🦆你真的太帅了[爱你] https://github.com/wsl2ls // @且行且珍惜_iOS: 发起了话题#我是一只帅哥#不信点我看看 https://www.jianshu.com/u/e15d1f644bea , 相信我，不会让你失望滴")
                self.dataArray.add(model)
                //元组
                let attStrAndHeight:(attributedString:NSMutableAttributedString, height:CGFloat) = self.matchesResultOfTitle(title: model.title!, expan: false)
                let layout:SLLayout = SLLayout(attributedString: attStrAndHeight.attributedString, cellHeight: (15 + 35 + 15 + attStrAndHeight.height + 15), expan: false)
                self.layoutArray.add(layout)
            }
            //操作完成，调用主线程来刷新界面
            DispatchQueue.main.async {
                completeBlock(self.dataArray, self.layoutArray)
            }
        }
    }
    
    //标题正则匹配结果
    func matchesResultOfTitle(title: String, expan: Bool) -> (attributedString : NSMutableAttributedString , height : CGFloat) {
        //段落
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 //行间距
        //原富文本标题
        var attributedString:NSMutableAttributedString = NSMutableAttributedString(string:title)
        //原富文本的范围
        let titleRange = NSRange(location: 0, length:attributedString.length)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: titleRange)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: titleRange)
        //最大字符 截取位置
        var cutoffLocation = KTitleLengthMax
        //        print("\(attributedString.length)")
        
        //图标+描述 替换HTTP链接
        let urlRanges:[NSRange] = getRangesFromResult(regexStr:KRegularMatcheHttpUrl, title: title)
        for range in urlRanges {
            let attchimage:NSTextAttachment = NSTextAttachment()
            attchimage.image = UIImage.init(named: "photo")
            attchimage.bounds = CGRect.init(x: 0, y: -2, width: 16, height: 16)
            let replaceStr : NSMutableAttributedString = NSMutableAttributedString(attachment: attchimage)
            replaceStr.append(NSAttributedString.init(string: "查看图片")) //添加描述
            replaceStr.addAttributes([NSAttributedString.Key.link :"http://b-ssl.duitang.com/uploads/item/201601/15/20160115140217_HeJAm.jpeg"], range: NSRange(location: 0, length:replaceStr.length ))
            replaceStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length:replaceStr.length))
            //注意：涉及到文本替换的 ，每替换一次，原有的富文本位置发生改变，下一轮替换的起点需要重新计算！
            let newLocation = range.location - (titleRange.length - attributedString.length)
            //图标+描述 替换HTTP链接字符
            attributedString.replaceCharacters(in: NSRange(location: newLocation, length: range.length), with: replaceStr)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            if cutoffLocation >= newLocation && cutoffLocation <= newLocation + range.length {
                cutoffLocation = newLocation
            }
            //             print("==== \(attributedString.length)")
        }
        //话题匹配
        let topicRanges:[NSRange] = getRangesFromResult(regexStr: KRegularMatcheTopic, title: attributedString.string)
        for range in topicRanges {
            attributedString.addAttributes([NSAttributedString.Key.link :"https://github.com/wsl2ls"], range: range)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            if cutoffLocation >= range.location && cutoffLocation <= range.location + range.length {
                cutoffLocation = range.location
            }
        }
        //@用户匹配
        let userRanges:[NSRange] = getRangesFromResult(regexStr: KRegularMatcheUser,title: attributedString.string)
        for range in userRanges {
            attributedString.addAttributes([NSAttributedString.Key.link :"https://www.jianshu.com/u/e15d1f644bea"], range: range)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            if cutoffLocation >= range.location && cutoffLocation <= range.location + range.length {
                cutoffLocation = range.location
            }
        }
        //表情匹配
        let emotionRanges:[NSRange] = getRangesFromResult(regexStr: KRegularMatcheEmotion,title: attributedString.string)
        //经过上述的匹配替换后，此时富文本的范围
        let currentTitleRange = NSRange(location: 0, length:attributedString.length)
        for range in emotionRanges {
            //表情附件
            let attchimage:NSTextAttachment = NSTextAttachment()
            attchimage.image = UIImage.init(named: "爱你")
            attchimage.bounds = CGRect.init(x: 0, y: -2, width: 16, height: 16)
            let stringImage : NSAttributedString = NSAttributedString(attachment: attchimage)
            //注意：每替换一次，原有的位置发生改变，下一轮替换的起点需要重新计算！
            let newLocation = range.location - (currentTitleRange.length - attributedString.length)
            //图片替换表情文字
            attributedString.replaceCharacters(in: NSRange(location: newLocation, length: range.length), with: stringImage)
            //如果最多字符个数会截断高亮字符，则舍去高亮字符
            //字符替换之后，截取位置也要更新
            cutoffLocation -= (currentTitleRange.length - attributedString.length)
            if cutoffLocation >= newLocation && cutoffLocation <= newLocation + range.length {
                cutoffLocation = newLocation
            }
        }
        //超出字符个数限制，显示全文
        if attributedString.length > cutoffLocation {
            var fullText: NSMutableAttributedString
            if expan {
                attributedString.append(NSAttributedString(string:"\n"))
                fullText = NSMutableAttributedString(string:"收起")
            }else {
                attributedString = attributedString.attributedSubstring(from: NSRange(location: 0, length: cutoffLocation)) as! NSMutableAttributedString
                attributedString.append(NSAttributedString(string:"..."))
                fullText = NSMutableAttributedString(string:"全文")
            }
            fullText.addAttributes([NSAttributedString.Key.link :"FullText", NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], range: NSRange(location:0, length:fullText.length))
            attributedString.append(fullText)
        }
        //元组
        let attributedStringHeight = (attributedString, heightOfAttributedString(attributedString))
        return attributedStringHeight
    }
    //根据匹配规则返回所有的匹配结果
    fileprivate func getRangesFromResult(regexStr : String, title: String) -> [NSRange] {
        // 0.匹配规则
        let regex = try? NSRegularExpression(pattern:regexStr, options: [])
        // 1.匹配结果
        let results = regex?.matches(in:title, options:[], range: NSRange(location: 0, length: NSAttributedString(string: title).length))
        // 2.遍历结果 数组
        var ranges = [NSRange]()
        for res in results! {
            ranges.append(res.range)
        }
        return ranges
    }
    //计算富文本的高度
    func heightOfAttributedString(_ attributedString: NSAttributedString) -> CGFloat {
        let height : CGFloat =  attributedString.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 15 * 2, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        return ceil(height)
    }
}

// MARK: SLTableViewCellDelegate
extension SLPresenter : SLTableViewCellDelegate {
    //全文展开、收起
    func fullTextAction(characterRange: NSRange, indexPath: IndexPath) {
        let model: SLModel = self.dataArray[indexPath.row] as! SLModel
        var layout: SLLayout = self.layoutArray[indexPath.row] as! SLLayout
        layout.expan = !layout.expan
        //元组
        let attStrAndHeight:(attributedString:NSMutableAttributedString, height:CGFloat) = self.matchesResultOfTitle(title: model.title!, expan: layout.expan)
        layout.attributedString = attStrAndHeight.attributedString
        layout.cellHeight = (15 + 35 + 15 + attStrAndHeight.height + 15)
        self.layoutArray.replaceObject(at: indexPath.row, with: layout)
        self.completeBlock!(self.dataArray, self.layoutArray)
    }
}

