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
    //隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal;
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(SLPictureBrowsingCell.self, forCellWithReuseIdentifier: "ImageCellId")
        return collectionView
    }()
    lazy var pageControl: UIPageControl = {
        let pageControll = UIPageControl()
        pageControll.pageIndicatorTintColor = UIColor.gray
        pageControll.currentPageIndicatorTintColor = UIColor.white
        return pageControll
    }()
    var imagesArray: [String]  = []
    var currentPage: Int = 0
    
    // MARK: Override
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        let navigationController:SLNavigationController = self.navigationController as! SLNavigationController
        navigationController.isStatusBarHidden = true
    }
    
    // MARK: UI
    func setupUI() {
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
        let cell:SLPictureBrowsingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellId", for: indexPath) as! SLPictureBrowsingCell;
        cell.reloadData(picUrl: self.imagesArray[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width + 2 * KPictureSpace, height: self.view.frame.size.height)
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

