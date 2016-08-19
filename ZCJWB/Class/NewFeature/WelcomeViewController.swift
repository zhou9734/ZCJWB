//
//  WelcomeViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/10.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFrame()
        loadHeadImage()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        headImageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(160)
        }
        UIView.animateWithDuration(2.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                UIView.animateWithDuration(2.0, animations: { () -> Void in
                    self.msgLbl.alpha = 1.0
                    }, completion: { (_) -> Void in
                        //跳转到主页面
                         NSNotificationCenter.defaultCenter().postNotificationName(SwitchRootViewController, object: true)
                })
        }

    }

    private func setupUI(){
        view.backgroundColor = UIColor.greenColor()
        view.addSubview(bgImageView)
        view.addSubview(headImageView)
        view.addSubview(msgLbl)
    }

    private func setupFrame(){
        bgImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.edges.equalTo(0)
        }
        headImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.size.equalTo(CGSize(width: 100, height: 100))
//            make.top.equalTo(ScreenHeight - 260)
        }
        msgLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.width.equalTo(100)
            make.top.equalTo(headImageView.snp_bottom).offset(20)
        }

    }

    private func loadHeadImage(){
        let _account = UserAccount.loadAccount()
        assert(_account != nil, "必须授权登录之后才能显示欢迎界面")
        //设置头像
        guard let url = NSURL(string: (_account?.avatar_large)!) else{
            return
        }
        headImageView.sd_setImageWithURL(url)
    }

    /// 背景
    private lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.ad_background
        return imageView
    }()

    /// 头像
    private lazy var headImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.sizeToFit()
        return imageView
    }()

    /// 欢迎回来
    private lazy var msgLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "欢迎回来"
        lbl.textAlignment = .Center
        lbl.textColor = UIColor.grayColor()
        lbl.alpha =  0.0
        return lbl
    }()
}
