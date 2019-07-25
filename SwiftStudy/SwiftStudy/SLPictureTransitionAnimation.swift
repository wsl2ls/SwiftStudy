//
//  SLPictureTransitionAnimation.swift
//  SwiftStudy
//
//  Created by wsl on 2019/7/19.
//  Copyright © 2019 https://github.com/wsl2ls/WKWebView All rights reserved.
//

import UIKit

//定义枚举 转场类型
enum SLTransitionType: Int {
    case Push
    case Pop
    case Present
    case Dissmiss
}
let duration: TimeInterval = 0.3 //动画时长

class SLPictureTransitionAnimation: NSObject {
    var transitionType:SLTransitionType = SLTransitionType.Push
    var toAnimatonView: UIView?   //动画前的视图
    var fromAnimatonView: UIView? //动画后的视图
}

// MARK: UIViewControllerAnimatedTransitioning
extension SLPictureTransitionAnimation : UIViewControllerAnimatedTransitioning {
    //返回动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration;
    }
    //所有的过渡动画事务都在这个代理方法里面完成
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch (transitionType) {
        case .Push:
            pushAnimation(transitionContext)
            break
        case .Pop:
            popAnimation(transitionContext)
            break
        case .Present:
            presentAnimation(transitionContext)
            break
        case .Dissmiss:
            dissmissAnimation(transitionContext)
            break
        }
    }
    func pushAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(true)
    }
    func popAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(true)
    }
    func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        //转场后视图控制器上的视图view
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        toView.isHidden = true
        //这里有个重要的概念containerView，如果要对视图做转场动画，视图就必须要加入containerView中才能进行，可以理解containerView管理着所有做转场动画的视图
        let containerView: UIView = transitionContext.containerView;
        //黑色背景视图
        let bgView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height));
        bgView.backgroundColor = UIColor.black
        containerView.addSubview(toView)
        containerView.addSubview(bgView)
        containerView.addSubview(fromAnimatonView!)
        //动画
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            if(self.toAnimatonView!.frame != CGRect.zero) {
                self.fromAnimatonView?.frame = self.toAnimatonView!.frame
                self.fromAnimatonView?.layer.contentsRect = self.toAnimatonView!.layer.contentsRect
            }else {
                
            }
        }) { (finished) in
            toView.isHidden = false
            bgView.removeFromSuperview()
            self.fromAnimatonView?.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    func dissmissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        //转场前视图控制器上的视图view
        let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        fromView.isHidden = true
        let containerView: UIView = transitionContext.containerView;
        //黑色背景视图
        let bgView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height));
        bgView.backgroundColor = fromView.backgroundColor
        containerView.addSubview(bgView)
        containerView.addSubview(fromAnimatonView!)
        //动画
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            self.fromAnimatonView?.frame = self.toAnimatonView!.frame
            self.fromAnimatonView?.layer.contentsRect = self.toAnimatonView!.layer.contentsRect
            bgView.alpha = 0;
        }) { (finished) in
            bgView.removeFromSuperview()
            self.fromAnimatonView?.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
}
