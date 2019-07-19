//
//  SLPictureTransitionAnimation.swift
//  SwiftStudy
//
//  Created by wsl on 2019/7/19.
//  Copyright © 2019 wsl. All rights reserved.
//

import UIKit

//定义枚举 转场类型
enum SLTransitionType: Int {
    case Push
    case Pop
    case Present
    case Dissmiss
}

class SLPictureTransitionAnimation: NSObject {
    var transitionType:SLTransitionType = SLTransitionType.Push
}

// MARK: UIViewControllerAnimatedTransitioning
extension SLPictureTransitionAnimation : UIViewControllerAnimatedTransitioning {
    //返回动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3;
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
        transitionContext.completeTransition(true);
    }
    func popAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(true);
    }
    func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        //取出转场前后视图控制器上的视图view
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!;
    //这里有个重要的概念containerView，如果要对视图做转场动画，视图就必须要加入containerView中才能进行，可以理解containerView管理着所有做转场动画的视图
        let containerView: UIView = transitionContext.containerView;
        containerView.addSubview(toView)
        
        transitionContext.completeTransition(true);
    }
    func dissmissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        transitionContext.completeTransition(true);
    }
    
}
