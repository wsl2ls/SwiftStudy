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
    
    //头像
    lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.kf.indicatorType = .activity
        imageView.framePreloadCount = 5
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: UI
    func setupUI() {
        self.contentView.addSubview(self.imageView)
    }
    // MARK: ReloadData
    func reloadData(picUrl:String) {
        //URL编码
        let encodingStr = picUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let imageUrl = URL(string:encodingStr!)
        let placeholderImage = UIImage(named: "placeholderImage")!
        imageView.kf.setImage(
            with: imageUrl!,
            placeholder: placeholderImage,
            options: [.transition(.fade(1)), .loadDiskFileSynchronously],
            progressBlock: { receivedSize, totalSize in
                
        },
            completionHandler: { result in
                //                 Resultl类型 https://www.jianshu.com/p/2e30f39d99da
                switch result {
                case .success(let response):
                    let image: Image = response.image
                    //                            ?.kf.imageFormat
                    print(image.size)
                    self.imageView.snp.remakeConstraints { (make) in
                        make.centerY.equalToSuperview()
                        make.centerX.equalToSuperview()
                        make.width.equalTo(UIScreen.main.bounds.size.width)
                        make.height.equalTo(self.contentView.snp.width).multipliedBy(image.size.height/image.size.width)
                    }
                case .failure(let response):
                    print(response)
                }
        }
        )
    }
    
}
