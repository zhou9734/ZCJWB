//
//  ZCJRefreshControl.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/16.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class ZCJRefreshControl: UIRefreshControl {

    override init() {
        super.init()
        addSubview(refreshView)
        refreshView.addSubview(arrowImageView)
        refreshView.addSubview(textlbl)
        refreshView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 150, height: 50))
            make.center.equalTo(self)
            make.top.equalTo(self.snp_top).offset(5)
        }
        refreshView.backgroundColor = UIColor.whiteColor()
        arrowImageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(refreshView.snp_top).offset(5)
            make.left.equalTo(refreshView.snp_left).offset(5)
        }
        textlbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(refreshView.snp_top).offset(10)
            make.left.equalTo(arrowImageView.snp_right).offset(5)
            make.width.equalTo(85)
        }


        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func endRefreshing() {
        super.endRefreshing()
        resetLoadingView()
    }

    var rotationFlag = false
    //MARK: - 监控frame改变
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //过滤垃圾数据
        if frame.origin.y == 0 || frame.origin.y == -64{
            return
        }
        // 判断是否触发下拉刷新事件
        if refreshing{
            // 隐藏提示视图, 显示加载视图, 并且让菊花转动
            startLoadingView()
            return
        }

        // 通过观察发现: 往下拉Y越小, 往上推Y越大
        if frame.origin.y < -40 && !rotationFlag {
            rotationFlag = true
            rotationArrow(rotationFlag)
        }else if frame.origin.y > -40 && rotationFlag{
            rotationFlag = false
            rotationArrow(rotationFlag)
        }
    }

    private func startLoadingView(){
        // 0.隐藏提示视图
        arrowImageView.image = R.image.tableview_loading
        textlbl.text = "正在刷新..."
        if let _ = arrowImageView.layer.animationForKey("zcjRoration"){
            // 如果已经添加过动画, 就直接返回
            return
        }
        // 1.创建动画
        let anim =  CABasicAnimation(keyPath: "transform.rotation")
        // 2.设置动画属性
        anim.toValue = 2 * M_PI
        anim.duration = 5.0
        anim.repeatCount = MAXFLOAT
        // 3.将动画添加到图层上
        arrowImageView.layer.addAnimation(anim, forKey: "zcjRoration")
    }

    private func resetLoadingView(){
        // 0.显示提示视图
        arrowImageView.image = R.image.tableview_pull_refresh
        textlbl.text = "下拉刷新"
        // 1.移除动画
        arrowImageView.layer.removeAllAnimations()
    }

    private func rotationArrow(flag: Bool){
        var angle: CGFloat = flag ? -0.01 : 0.01
        angle += CGFloat(M_PI)
        /*
        transform旋转动画默认是按照顺时针旋转的
        但是旋转时还有一个原则, 就近原则
        */
        UIView.animateWithDuration(1.0) { () -> Void in
            self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, angle)
        }
    }

    private lazy var refreshView = UIView()

    private lazy var arrowImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = R.image.tableview_pull_refresh
        _imageView.sizeToFit()
        return  _imageView
    }()

    private lazy var textlbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "下拉刷新"
        return lbl
    }()

}
