//
//  SLTableViewCell.swift
//  SwiftStudy
//
//  Created by wsl on 2019/5/29.
//  Copyright © 2019 https://github.com/wsl2ls All rights reserved.
//

import UIKit
import Kingfisher

//定义枚举 富文本链接类型
enum SLTextLinkType: Int {
    case Webpage
    case Picture
    case FullText
}

//代理方法
@objc protocol SLTableViewCellDelegate : NSObjectProtocol {
    func tableViewCell(_ tableViewCell: SLTableViewCell, tapImageAction indexOfImages:NSInteger, indexPath: IndexPath)  //点击图片
    func tableViewCell(_ tableViewCell: SLTableViewCell, clickedLinks url:String,  characterRange: NSRange, linkType: SLTextLinkType.RawValue, indexPath: IndexPath)  //点击文本链接
}

//标题富文本视图
class SLTextView: UITextView {
    //关闭高亮富文本的长按选中功能
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer is  UILongPressGestureRecognizer {
            gestureRecognizer.isEnabled = false;
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
    //打开或禁用复制，剪切，选择，全选等功能 UIMenuController
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 返回false为禁用，true为开启
        if action == #selector(copy(_ :)) || action == #selector(selectAll(_ :)) || action == #selector(select(_ :)) {
            return true
        }
        //        print("\(action)")
        return false
    }
}

class SLTableViewCell: UITableViewCell {
    //头像
    lazy var headImage: AnimatedImageView = {
        let headimage = AnimatedImageView()
        //                headimage.layer.cornerRadius = 15
        //                headimage.clipsToBounds = true
        return headimage
    }()
    //昵称
    lazy var nickLabel: UILabel = {
        let nickName = UILabel()
        nickName.textColor = UIColor.black;
        nickName.font = UIFont.systemFont(ofSize: 16)
        return nickName
    }()
    //时间和来源
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.textColor = UIColor.gray;
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        return timeLabel
    }()
    //关注
    lazy var followBtn: UIButton = {
        let followBtn = UIButton()
        followBtn.layer.borderColor = UIColor.init(red: 58/256.0, green: 164/256.0, blue: 240/256.0, alpha: 1.0).cgColor
        followBtn.layer.borderWidth = 0.5
        followBtn.layer.cornerRadius = 12
        followBtn.clipsToBounds = true
        followBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        followBtn.setTitleColor(UIColor.init(red: 58/256.0, green: 164/256.0, blue: 240/256.0, alpha: 1.0), for: UIControl.State.normal)
        followBtn.addTarget(self, action: #selector(followBtnClicked(followBtn:)), for: UIControl.Event.touchUpInside)
        followBtn.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        return followBtn
    }()
    //标题
    lazy var textView: SLTextView = {
        let textView = SLTextView()
        textView.textColor = UIColor.black;
        textView.isEditable = false;
        textView.isScrollEnabled = false;
        textView.delegate = self
        //        textView.backgroundColor = UIColor.green
        //内容距离行首和行尾的内边距
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        //        textView.max
        return textView
    }()
    //图片视图数组
    var picsArray: [AnimatedImageView] = []
    //当前cell索引
    var cellIndexPath: IndexPath?
    // 代理
    weak var delegate: SLTableViewCellDelegate?
    
    //初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    // MARK: UI
    private  func setupUI() {
        self.contentView.addSubview(self.headImage)
        self.contentView.addSubview(self.nickLabel)
        self.contentView.addSubview(self.timeLabel)
        self.contentView.addSubview(self.followBtn)
        self.contentView.addSubview(self.textView)
        for i in 0..<9 {
            let imageView = AnimatedImageView(frame: CGRect.zero)
            imageView.backgroundColor = UIColor.lightGray
            imageView.isHidden = true
            imageView.tag = i
            imageView.autoPlayAnimatedImage = false
            //            imageView.repeatCount = AnimatedImageView.RepeatCount.once
            imageView.framePreloadCount = 1
            imageView.isUserInteractionEnabled = true
            self.contentView.addSubview(imageView)
            let tap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapPicture(tap:)))
            imageView.addGestureRecognizer(tap)
            self.picsArray.append(imageView)
        }
        self.headImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.width.equalTo(35)
        }
        self.nickLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImage.snp.right).offset(5)
            make.top.equalTo(self.headImage.snp.top).offset(2)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(self.followBtn.snp.left).offset(-5)
        }
        self.timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImage.snp.right).offset(5)
            make.top.equalTo(self.nickLabel.snp.bottom).offset(2)
            make.height.equalTo(10)
            make.right.lessThanOrEqualTo(self.followBtn.snp.left).offset(-5)
        }
        self.followBtn.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(self.nickLabel.snp.right).offset(5)
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.headImage.snp.centerY)
            make.height.equalTo(24)
        }
        self.textView.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImage.snp.left)
            make.right.equalTo(self.followBtn.snp.right)
            make.top.equalTo(self.headImage.snp.bottom).offset(15)
            //            make.bottom.equalTo(self.picsArray[0].snp.top).offset(-15)
        }
        
    }
    
    // MARK: ReloadData
    func configureCell(model: SLModel, layout: SLLayout?) -> Void {
        let url = URL(string:model.headPic)
        let placeholderImage = UIImage(named: "placeholderImage")!
        let roundCornerProcessor = RoundCornerImageProcessor(cornerRadius: 350)
        self.headImage.kf.setImage(with: url!, placeholder:placeholderImage ,options: [.processor(roundCornerProcessor)])
        self.nickLabel.text = model.nickName
        self.timeLabel.text =  model.time! + " 来自 " + model.source!
        self.followBtn.setTitle("      关注     ", for: UIControl.State.normal)
        self.textView.attributedText = layout?.attributedString
        //图片宽、高
        let width: CGFloat = (UIScreen.main.bounds.size.width - 15 * 2 - 5 * 2)/3
        let height: CGFloat = width
        for (index, imageView) in self.picsArray.enumerated() {
            if model.images.count > index {
                imageView.isHidden = false
                if model.images.count < 5 {
                    imageView.snp.remakeConstraints { (make) in
                        make.top.equalTo(self.textView.snp.bottom).offset(15 + (index/2) * Int(height + 5))
                        make.left.equalTo(15 + (index%2) * Int(width + 5))
                        make.width.height.equalTo(height)
                    }
                }else {
                    imageView.snp.remakeConstraints { (make) in
                        make.top.equalTo(self.textView.snp.bottom).offset(15 + (index/3) * Int(height + 5))
                        make.left.equalTo(15 + (index%3) * Int(width + 5))
                        make.width.height.equalTo(height)
                    }
                }
                
                //URL编码
                let encodingStr = model.images[index].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let imageUrl = URL(string:encodingStr!)
                // 高分辨率的图片采取降采样的方法提高性能
                let processor = DownsamplingImageProcessor(size: CGSize(width: width, height: width))
                //性能优化 取消之前的下载任务
                imageView.kf.cancelDownloadTask()
                imageView.kf.setImage(with: imageUrl!, placeholder: nil, options: [.processor(processor), .scaleFactor(UIScreen.main.scale), .cacheOriginalImage, .onlyLoadFirstFrame] , progressBlock: { (receivedSize, totalSize) in
                    //下载进度
                }) { (result) in
                    switch result {
                    case .success(let value):
                        let image: Image = value.image
                        //                        var data  = Data(contentsOf: imageUrl!)
                        //                        let data = image.kf.gifRepresentation()?.kf.imageFormat
                        //                        print("===== \( value.source)")
                        imageView.image = image
                        if (image.size.height/image.size.width > 3) {
                            //大长图 仅展示顶部部分内容
                            let proportion: CGFloat = height/(width * image.size.height/image.size.width)
                            imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: proportion)
                        } else if image.size.width >= image.size.height {
                            // 宽>高
                            let proportion: CGFloat = width/(height * image.size.width/image.size.height)
                            imageView.layer.contentsRect = CGRect(x: (1 - proportion)/2, y: 0, width: proportion, height: 1)
                        }else if image.size.width < image.size.height {
                            //宽<高
                            let proportion: CGFloat = height/(width * image.size.height/image.size.width)
                            imageView.layer.contentsRect = CGRect(x: 0, y: (1 - proportion)/2, width: 1, height: proportion)
                        }
                        //淡出动画
                        if value.cacheType == CacheType.none {
                            let fadeTransition: CATransition = CATransition()
                            fadeTransition.duration = 0.15
                            fadeTransition.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
                            fadeTransition.type = CATransitionType.fade
                            imageView.layer.add(fadeTransition, forKey: "contents")
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                
            } else {
                imageView.isHidden = true
                imageView.snp.remakeConstraints { (make) in
                    make.top.left.width.height.equalTo(0)
                }
            }
        }
    }
    
    // MARK: Events
    @objc func followBtnClicked(followBtn: UIButton) {
        print("已关注")
    }
    @objc func tapPicture(tap: UITapGestureRecognizer) {
        let animationView: AnimatedImageView = tap.view as! AnimatedImageView
        if (self.delegate?.responds(to: #selector(SLTableViewCellDelegate.tableViewCell(_:tapImageAction:indexPath:))))! {
            self.delegate?.tableViewCell(self, tapImageAction: animationView.tag, indexPath: self.cellIndexPath!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

// MARK: UITextViewDelegate
extension SLTableViewCell : UITextViewDelegate {
    //点击链接
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let selectdText: String = textView.attributedText.attributedSubstring(from: characterRange).string
        print("点击了：\(selectdText) \n    链接值：\(URL.absoluteString) ")
        var linkType: SLTextLinkType = SLTextLinkType.Webpage
        if URL.absoluteString == "FullText" {
            linkType = SLTextLinkType.FullText
        }else if selectdText.hasSuffix("查看图片"){
            linkType = SLTextLinkType.Picture
        }else {
            linkType = SLTextLinkType.Webpage
        }
        self.delegate?.tableViewCell(self, clickedLinks: URL.absoluteString, characterRange: characterRange, linkType: linkType.rawValue, indexPath: self.cellIndexPath!)
        return false
    }
    //点击富文本附件 图片等
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("点击了附件\( NSAttributedString(attachment: textAttachment).string) ")
        return false
    }
}

