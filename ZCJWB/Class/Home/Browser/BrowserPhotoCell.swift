//
//  BrowserPhotoCell.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/20.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

protocol BrowserDelegate: NSObjectProtocol{
    func showActionSheetMenu()
}
//MARK: - 自定义cell
class BrowserPhotoCell: UICollectionViewCell, UIScrollViewDelegate{
    var delegate: BrowserDelegate?
    var imageUrl: NSURL?{
        didSet{
            indicatorView.startAnimating()
            //重置scrollView和imageView
            resetView()
            imageView.sd_setImageWithURL(imageUrl, placeholderImage: nil) { (image, error, _, _) -> Void in
                self.indicatorView.stopAnimating()
                //图片宽高比
                let scale = image.size.height/image.size.width
                //利用宽高比计算图片的高度
                let imageHeight = scale * ScreenWidth
                //设置图片的frame
                self.imageView.frame = CGRect(origin: CGPointZero, size: CGSize(width: ScreenWidth, height: imageHeight))
                //判断当前是长图还是短图
                if imageHeight < ScreenHeight{
                    // 短图
                    // 计算顶部和底部内边距
                    let offsetY = (ScreenHeight - imageHeight) * 0.5
                    // 设置内边距
                    self.scrollView.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
                }else{
                    self.scrollView.contentSize = CGSize(width: ScreenWidth, height: imageHeight)
                }
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 内部控制方法
    private func resetView(){
        scrollView.contentSize = CGSizeZero
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        imageView.transform = CGAffineTransformIdentity
    }
    private func setupUI(){
        //添加子控件
        contentView.backgroundColor = UIColor.blackColor()
        contentView.addSubview(scrollView)
        contentView.addSubview(indicatorView)
        scrollView.addSubview(imageView)
        scrollView.frame =  UIScreen.mainScreen().bounds //self.frame
        //给imageView和scrollView添加事件
        let gesture = UITapGestureRecognizer(target: self, action: Selector("close"))
        //scrollView同样要添加事件
        scrollView.userInteractionEnabled = true
        scrollView.addGestureRecognizer(gesture)
        let longGesture = UILongPressGestureRecognizer(target: self, action: Selector("savePhoto:"))
        longGesture.minimumPressDuration = 0.8
        //添加事件之前必须要设置启用事件
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
        imageView.addGestureRecognizer(longGesture)

        indicatorView.center = contentView.center
    }
    @objc private func close(){
        NSNotificationCenter.defaultCenter().postNotificationName(CloseWBPic, object: self)
    }
    //scrollView
    private lazy var scrollView : UIScrollView = {
        let sc = UIScrollView()
        sc.maximumZoomScale = 2.0
        sc.minimumZoomScale = 1
        sc.delegate = self
        return sc
    }()
    //图片
    lazy var imageView = UIImageView()

    //菊花
    private lazy var indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

    // MARK: - UIScrollViewDelegate
    // 告诉系统需要缩放哪一个控件
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    // 缩放的过程中会不断调用
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // 1.计算上下内边距
        var offsetY = (ScreenHeight - imageView.frame.height) * 0.5
        // 2.计算左右内边距
        var offsetX = (ScreenWidth - imageView.frame.width) * 0.5
        offsetY = (offsetY < 0) ? 0 : offsetY
        offsetX = (offsetX < 0) ? 0 : offsetX
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }

    @objc private func savePhoto(gesture: UILongPressGestureRecognizer){
        if gesture.state == .Began{

            delegate?.showActionSheetMenu()
        }
    }
}

