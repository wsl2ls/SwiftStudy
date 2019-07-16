//
//  SLPictureZoomView.swift
//  SwiftStudy
//
//  Created by wsl on 2019/7/16.
//  Copyright © 2019 wsl. All rights reserved.
//

import UIKit
import Kingfisher

class SLPictureZoomView: UIScrollView {
    
    lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
//        imageView.isUserInteractionEnabled = true
        imageView.kf.indicatorType = .activity
        imageView.framePreloadCount = 5
        return imageView
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
        self.delegate = self;
        self.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 3.0
        self.addSubview(self.imageView)
    }
    func setImage(picUrl:String) {
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
                        make.width.equalToSuperview()
                        make.height.equalTo(self.snp.width).multipliedBy(image.size.height/image.size.width)
                    }
                case .failure(let response):
                    print(response)
                }
        }
        )
    }
    
}

// MARK: UIScrollViewDelegate
extension SLPictureZoomView: UIScrollViewDelegate {
    //返回缩放视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView;
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print("开始缩放")
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("结束缩放")
    }
    //缩放过程中
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.imageView.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.height.equalTo(self.snp.width)
        }
    }
    
}
