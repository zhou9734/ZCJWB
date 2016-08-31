//
//  QRCodeCreateViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/7.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SDWebImage

class QRCodeCreateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFrameConstants()
        createQRCode()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    //设置UI界面
    private func setupUI(){
        navigationItem.title = "我的名片"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        let iamge = UIImage.imageWithColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.5))
        navigationController?.navigationBar.setBackgroundImage(iamge, forBarMetrics: .Default)
        navigationController?.navigationBar.barStyle = .Default
        view.backgroundColor = UIColor(white: 245.0/255.0, alpha: 1)
        view.addSubview(containerView)
        containerView.addSubview(fingerprintImageView)
        containerView.addSubview(qrcodeImageView)
        containerView.addSubview(underlineView)
        containerView.addSubview(headImageView)
        containerView.addSubview(userNameLbl)
        containerView.addSubview(messageLbl)
    }
    private func setupFrameConstants(){
        //容器约束
        let _width = (ScreenWidth/13)*11
        containerView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(view)
            make.width.equalTo(_width)
            make.height.equalTo(((ScreenHeight-67)/5)*4)
        }
        //指纹背景约束
        fingerprintImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(25)
        }
        //二维码约束
        qrcodeImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(87)
            make.width.height.equalTo(107)
        }
        //下划线约束
        underlineView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(underlineView.snp_centerX)
            make.height.equalTo(1)
            make.top.equalTo(fingerprintImageView.snp_bottom).offset(45)
            make.width.equalTo(_width - 60)
            make.left.equalTo(30)
        }
        //头像约束
        headImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(fingerprintImageView.snp_bottom).offset(15)
            make.size.equalTo(CGSize(width: 55, height: 55))
        }
        //用户名约束
        userNameLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(headImageView.snp_bottom).offset(10)
            make.width.equalTo(100)
        }
        //说明
        messageLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(userNameLbl.snp_bottom).offset(10)
            make.width.equalTo(200)
        }
    }

    //生成二维码
    private func createQRCode(){
        let _account = UserAccount.loadAccount()
        assert(_account != nil, "必须授权登录之后才能显示欢迎界面")
        //设置头像
        guard let url = NSURL(string: (_account?.avatar_large)!) else{
            return
        }
        headImageView.sd_setImageWithURL(url)
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        //还原默认滤镜属性
        filter?.setDefaults()
        //设置要生成的二维码数据到滤镜中 (需要设置二进制数据)
        filter?.setValue(_account?.uid!.dataUsingEncoding(NSUTF8StringEncoding), forKeyPath: "InputMessage")
        //从滤镜中取出生成好的二维码
        guard let ciImage = filter?.outputImage else{
            return
        }
        qrcodeImageView.image = createNonInterpolatedUIImageFormCIImage(ciImage, size: 300)
    }

    /**
     生成高清二维码

     - parameter image: 需要生成原始图片
     - parameter size:  生成的二维码的宽高
     */
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {

        let extent: CGRect = CGRectIntegral(image.extent)
        let scale: CGFloat = min(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent))

        // 1.创建bitmap;
        let width = CGRectGetWidth(extent) * scale
        let height = CGRectGetHeight(extent) * scale
        let cs: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()!
        let bitmapRef = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, cs, 0)!

        let context = CIContext(options: nil)
        let bitmapImage: CGImageRef = context.createCGImage(image, fromRect: extent)

        CGContextSetInterpolationQuality(bitmapRef,  CGInterpolationQuality.None)
        CGContextScaleCTM(bitmapRef, scale, scale);
        CGContextDrawImage(bitmapRef, extent, bitmapImage);

        // 2.保存bitmap到图片
        let scaledImage: CGImageRef = CGBitmapContextCreateImage(bitmapRef)!

        return UIImage(CGImage: scaledImage)
    }


    //左边返回按钮
    private lazy var leftButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("返回", forState: .Normal)
        btn.addTarget(self, action: Selector("backBtnClick:"), forControlEvents: .TouchUpInside)
        btn.setImage(R.image.back, forState: .Normal)

        btn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        btn.sizeToFit()
        return btn
    }()

    //右边更多 按钮
    private lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: Selector("moreBtnClick:"), forControlEvents: .TouchUpInside)
        btn.setImage(R.image.more, forState: .Normal)
        btn.sizeToFit()
        return btn
    }()

    //容器 UIView
    private lazy var containerView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.whiteColor()
        return _view
    }()

    //指纹背景
    private lazy var fingerprintImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = R.image.message_group_code
        _imageView.sizeToFit()
        return _imageView
    }()

    //需要生成的二维码
    private lazy var qrcodeImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.image = UIImage.imageWithColor(UIColor.whiteColor())
        return _imageView
    }()

    //下划线
    private lazy var underlineView: UIView = {
        let _view = UIView()
        _view.backgroundColor = UIColor.grayColor()
        return _view
    }()

    //头像 
    private lazy var headImageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.sizeToFit()
        _imageView.layer.cornerRadius = 30
        _imageView.layer.masksToBounds = true
        return _imageView
    }()

    //用户名
    private lazy var userNameLbl: UILabel = {
        let _lbl = UILabel()
        _lbl.text = "ZCJ"
        _lbl.textColor = UIColor.darkGrayColor()
        _lbl.textAlignment = .Center
        _lbl.font = UIFont.systemFontOfSize(17)
        return _lbl
    }()

    //其他label
    private lazy var messageLbl: UILabel = {
        let _lbl = UILabel()
        _lbl.text = "扫一扫二维码图案,关注我吧"
        _lbl.textColor = UIColor.grayColor()
        _lbl.textAlignment = .Center
        _lbl.font = UIFont.systemFontOfSize(13)
        return _lbl
    }()

    @objc private func backBtnClick(btn: UIButton){
        navigationController?.popViewControllerAnimated(true)
        let iamge = UIImage.imageWithColor(UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 0.2))
        navigationController?.navigationBar.setBackgroundImage(iamge, forBarMetrics: .Default)
        navigationController?.navigationBar.barStyle = .Default
        navigationController?.navigationBar.tintColor = UIColor.orangeColor()
    }

    @objc private func moreBtnClick(btn: UIButton){
        NJLog("more")
    }
}
