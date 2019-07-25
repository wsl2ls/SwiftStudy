//
//  SLPictureZoomView.swift
//  SwiftStudy
//
//  Created by wsl on 2019/7/16.
//  Copyright © 2019 https://github.com/wsl2ls/WKWebView All rights reserved.
//

import UIKit
import Kingfisher

//struct MyIndicator: Indicator {
//    let view: UIView = UIView()
//    func startAnimatingView() { view.isHidden = false }
//    func stopAnimatingView() { view.isHidden = true }
//    init() {
//        view.backgroundColor = .red
//    }
//}

class SLPictureZoomView: UIScrollView {
    lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.isUserInteractionEnabled = true
        imageView.framePreloadCount = 5
        return imageView
    }()
    var indicatorView: UIActivityIndicatorView?
    //图片正常尺寸 默认
    var imageNormalSize:CGSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
    
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
        self.maximumZoomScale = 2.0
        self.clipsToBounds = false
        self.addSubview(self.imageView)
    }
    func setImage(picUrl:String) {
        //重置
        imageView.image = nil
        imageView.frame = CGRect.zero
        //URL编码
        let encodingStr = picUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let imageUrl = URL(string:encodingStr!)
        weak var weakSelf:SLPictureZoomView? = self
        //是否有缓存
        let cached = ImageCache.default.isCached(forKey: imageUrl!.absoluteString)
        if !cached {
            indicatorView = UIActivityIndicatorView()
            indicatorView!.color = UIColor.white
            self.addSubview(self.indicatorView!)
            indicatorView?.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            indicatorView?.startAnimating()
        }
        //性能优化 取消之前的下载任务
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(with: imageUrl!, placeholder: nil, options: [.loadDiskFileSynchronously], progressBlock: { (receivedSize, totalSize) in
            //下载进度
        }) { (result) in
            if weakSelf == nil {
                return
            }
            switch result {
            case .success(let value):
                //                        print(value.cacheType)
                let image: Image = value.image
                weakSelf?.imageNormalSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width*image.size.height/image.size.width)
                weakSelf?.imageView.frame = CGRect(x: 0, y: 0, width: (weakSelf?.imageNormalSize.width)!, height: (weakSelf?.imageNormalSize.height)!);
                weakSelf?.contentSize =  weakSelf!.imageNormalSize
                if((weakSelf?.imageNormalSize.height)! <= UIScreen.main.bounds.size.height) {
                    weakSelf?.imageView.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height/2.0)
                }
                weakSelf?.imageView.image = image
                //淡出动画
                if value.cacheType == CacheType.none {
                    let fadeTransition: CATransition = CATransition()
                    fadeTransition.duration = 0.15
                    fadeTransition.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
                    fadeTransition.type = CATransitionType.fade
                    weakSelf?.imageView.layer.add(fadeTransition, forKey: "contents")
                }
            case .failure(let error):
                 weakSelf?.imageView.frame = CGRect(x: 0, y: 0, width: (weakSelf?.imageNormalSize.width)!, height: (weakSelf?.imageNormalSize.height)!);
                 weakSelf?.imageView.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height/2.0)
                let failImage = UIImage(named: "placeholderImage")!
                weakSelf?.imageView.image = failImage
                print(error)
            }
            weakSelf?.indicatorView?.stopAnimating()
            weakSelf?.indicatorView?.removeFromSuperview()
            weakSelf?.indicatorView = nil
        }
    }
    
}

// MARK: UIScrollViewDelegate
extension SLPictureZoomView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    //返回缩放视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView;
    }
//    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
//        print("开始缩放")
//    }
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//         print("缩放结束")
//    }
    //缩放过程中
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // 延中心点缩放
        let imageScaleWidth: CGFloat = scrollView.zoomScale * self.imageNormalSize.width;
        let imageScaleHeight: CGFloat = scrollView.zoomScale * self.imageNormalSize.height;
        var imageX:CGFloat = 0;
        var imageY:CGFloat = 0;
        if (imageScaleWidth < self.frame.size.width) {
            imageX = (self.frame.size.width - imageScaleWidth)/2.0;
        }
        if (imageScaleHeight < self.frame.size.height) {
            imageY = (self.frame.size.height - imageScaleHeight)/2.0;
        }
        self.imageView.frame = CGRect(x: imageX, y: imageY, width: imageScaleWidth, height: imageScaleHeight);
    }
    
}

//extension SLPictureZoomView: UIGestureRecognizerDelegate {
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
//                        if (otherGestureRecognizer.view?.isKind(of: UIScrollView.self))! {
//                            if self.contentOffset.y < 0 {
//                               return true
//                            }
//                        }
//        }
//        return false
//    }
//}
