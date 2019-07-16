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
//        pictureZoomView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
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
        self.pictureZoomView.isUserInteractionEnabled = false;
        self.contentView.addGestureRecognizer(self.pictureZoomView.panGestureRecognizer)
    }
    // MARK: ReloadData
    func reloadData(picUrl:String) {
        self.pictureZoomView.setImage(picUrl: picUrl)
        
//        self.pictureZoomView.contentSize = CGSize(width: 500, height: 500);
    }
    
}
