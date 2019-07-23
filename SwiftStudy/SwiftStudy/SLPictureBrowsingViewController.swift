//
//  SLPictureBrowsingViewController.swift
//  SwiftStudy
//
//  Created by wsl on 2019/6/24.
//  Copyright © 2019 wsl. All rights reserved.
//

import UIKit
import Kingfisher

let KPictureSpace:CGFloat = 8  // 图片间隔

//图集浏览控制器
class SLPictureBrowsingViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal;
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(SLPictureBrowsingCell.self, forCellWithReuseIdentifier: "ImageCellId")
        return collectionView
    }()
    lazy var pageControl: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.pageIndicatorTintColor = UIColor.gray
        pageControll.currentPageIndicatorTintColor = UIColor.white
        return pageControll
    }()
    lazy var transitionAnimation: SLPictureTransitionAnimation = {
        var transitionAnimation:SLPictureTransitionAnimation = SLPictureTransitionAnimation()
        self.transitioningDelegate = self as UIViewControllerTransitioningDelegate
        return transitionAnimation
    }()
    var imagesArray: [String]  = []
    var currentPage: Int = 0   //当前图片页码
    var fromViewController: ViewController? //界面来源
    var currentIndexPath: IndexPath?  //当前数据来源
    
    // MARK: Override
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitionAnimation.transitionType = SLTransitionType.Present
        //设置了这个属性之后，在present转场动画处理时，转场前的视图fromVC的view一直都在管理转场动画视图的容器containerView中，会被转场后,后加入到containerView中视图toVC的View遮住，类似于入栈出栈的原理；如果没有设置的话，present转场时，fromVC.view就会先出栈从containerView移除，然后toVC.View入栈，那之后再进行disMiss转场返回时，需要重新把fromVC.view加入containerView中。
        //在push转场动画处理时,设置这个属性是没有效果的，也就是没用的。
        self.modalPresentationStyle = UIModalPresentationStyle.custom
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //普通机型此方法有效 IPhoneX系列上无效？
        let vc: ViewController = self.fromViewController!
        vc.isStatusBarHidden = true
        //IPhoneX系列此方法有效 普通机型上无效？
        let naVC:SLNavigationController = self.fromViewController?.navigationController as! SLNavigationController
        naVC.isStatusBarHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let vc: ViewController = self.fromViewController!
        vc.isStatusBarHidden = false
        let naVC:SLNavigationController = self.fromViewController?.navigationController as! SLNavigationController
        naVC.isStatusBarHidden = false
    }
    
    // MARK: UI
    func setupUI() {
        self.view.backgroundColor = UIColor.black
        self.view.clipsToBounds = true;
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(-KPictureSpace)
            make.right.equalToSuperview().offset(KPictureSpace)
            make.top.equalToSuperview()
            make.height.equalToSuperview()
        }
        self.collectionView.contentSize = CGSize(width: imagesArray.count * Int(self.view.frame.size.width + 2 * KPictureSpace), height: 0)
        self.collectionView.contentOffset = CGPoint(x: self.currentPage * Int(self.view.frame.size.width + 2 * KPictureSpace), y: 0)
        self.view.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-49)
        }
        self.pageControl.numberOfPages = imagesArray.count
        self.pageControl.currentPage = currentPage
        //添加拖拽动画手势
        self.view.isUserInteractionEnabled = true;
        let pan:UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panPicture(pan:)))
        self.view.addGestureRecognizer(pan)
    }
    
    //MARK: Events Handle
    //拖拽动画
    @objc func panPicture(pan: UIPanGestureRecognizer) {
        let cell:SLPictureBrowsingCell = (collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? SLPictureBrowsingCell)!
        let zoomView: SLPictureZoomView = cell.pictureZoomView
        let translation = pan.translation(in: zoomView)
        zoomView.center = CGPoint(x: zoomView.center.x + translation.x, y: zoomView.center.y + translation.y)
        pan.setTranslation(CGPoint.zero, in: cell)
        //滑动的百分比
        var percentComplete:CGFloat = 0.0
        percentComplete = (zoomView.center.y - UIScreen.main.bounds.size.height/2.0)/(UIScreen.main.bounds.size.height/2.0)
        percentComplete = abs(percentComplete);
        
        switch (pan.state) {
        case .began:
            self.fromViewController?.isStatusBarHidden = false
            break
        case .changed:
            if  zoomView.center.y > UIScreen.main.bounds.size.height/2.0 && percentComplete > 0.01 && percentComplete < 1.0 {
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1 - percentComplete)
                zoomView.transform = CGAffineTransform.init(scaleX: 1 - percentComplete/2.0, y: 1 - percentComplete/2.0)
            }
            break
        case .ended:
            if percentComplete >= 0.5 && zoomView.center.y > UIScreen.main.bounds.size.height/2.0 {
                self.dismiss(animated: true, completion: nil)
            }else {
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                UIView.animate(withDuration: 0.3, animations: {
                    zoomView.center = CGPoint(x: (UIScreen.main.bounds.size.width+KPictureSpace * 2)/2.0, y: UIScreen.main.bounds.size.height/2.0)
                    zoomView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }) { (finished) in
                    self.fromViewController?.isStatusBarHidden = true
                }
            }
            break
        case .cancelled:
            break
        default:
            break
        }
//        print("拖拽来了")
    }
    
    // MARK: HelpMethods
    //返回上一级页面用于转场动画的视图
    func previousAnimatonView() -> UIView {
        if fromViewController!.isKind(of: ViewController.self) {
            let tableViewCell: SLTableViewCell = fromViewController!.tableView.cellForRow(at: currentIndexPath!) as! SLTableViewCell
            let imageView: AnimatedImageView = tableViewCell.picsArray[currentPage]
            let tempView: AnimatedImageView = AnimatedImageView()
            tempView.image = imageView.image
            tempView.layer.contentsRect = imageView.layer.contentsRect
            tempView.frame = imageView.convert(imageView.bounds, to: self.view)
            return tempView
        }
        return UIView()
    }
    //返回当前页面用于转场动画的视图
    func currentAnimatonView() -> UIView {
        var cell:SLPictureBrowsingCell?
        cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? SLPictureBrowsingCell
        if cell == nil {
            //如果为nil
            cell = SLPictureBrowsingCell.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            cell?.reloadData(picUrl: self.imagesArray[currentPage])
            let tempView: UIView = cell!.pictureZoomView.imageView as UIView
            return tempView
        }else {
            let imageView: UIView = cell!.pictureZoomView.imageView as UIView
            //snapshotViewAfterScreenUpdates 对cell的imageView截图保存成另一个视图用于过渡，并将视图转换到当前控制器的坐标
            let tempView: UIView = imageView.snapshotView(afterScreenUpdates: false)!
            tempView.frame = imageView.convert(imageView.bounds, to: self.view)
            return tempView
        }
    }
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SLPictureBrowsingViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:SLPictureBrowsingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellId", for: indexPath) as! SLPictureBrowsingCell
        cell.backgroundColor = UIColor.clear
        cell.reloadData(picUrl: self.imagesArray[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width + 2 * KPictureSpace, height: UIScreen.main.bounds.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //四舍五入
        currentPage = lroundf(Float(scrollView.contentOffset.x/(self.view.frame.size.width + 2 * KPictureSpace)))
        self.pageControl.currentPage = currentPage
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x) / Int(collectionView.frame.size.width)
        self.pageControl.currentPage = currentPage
    }
}

// MARK: UIViewControllerTransitioningDelegate
// 自定义转场动画
extension SLPictureBrowsingViewController : UIViewControllerTransitioningDelegate {
    //返回一个处理presente动画过渡的对象
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        fromViewController = source as? ViewController
        transitionAnimation.fromAnimatonView = self.previousAnimatonView()
        transitionAnimation.toAnimatonView = self.currentAnimatonView()
        return transitionAnimation
    }
    //返回一个处理dismiss动画过渡的对象
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimation.transitionType = SLTransitionType.Dissmiss
        transitionAnimation.fromAnimatonView = self.currentAnimatonView()
        transitionAnimation.toAnimatonView = self.previousAnimatonView()
        return transitionAnimation
    }
}

