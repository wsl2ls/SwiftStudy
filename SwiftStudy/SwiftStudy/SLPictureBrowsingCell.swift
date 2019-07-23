//
//  SLPictureBrowsingCell.swift
//  SwiftStudy
//
//  Created by wsl on 2019/6/30.
//  Copyright © 2019 wsl. All rights reserved.
//

import UIKit
import Kingfisher

class SLPictureBrowsingCell: UICollectionViewCell {
    
    //缩放视图
    lazy var pictureZoomView: SLPictureZoomView = {
        let pictureZoomView = SLPictureZoomView()
        pictureZoomView.backgroundColor = UIColor.clear
        return pictureZoomView
    }()
    
    // MARK: UI
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        self.contentView.addSubview(self.pictureZoomView)
        self.pictureZoomView.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.height.equalTo(UIScreen.main.bounds.size.height)
        }
        //解决 UIScrollView 和UITableViewCell 冲突
        self.pictureZoomView.isUserInteractionEnabled = false;
        self.contentView.addGestureRecognizer(self.pictureZoomView.panGestureRecognizer)
        self.contentView.addGestureRecognizer(self.pictureZoomView.pinchGestureRecognizer!)
    }
    // MARK: ReloadData
    func reloadData(picUrl:String) {
        self.pictureZoomView.setImage(picUrl: picUrl)
    }
    
}
