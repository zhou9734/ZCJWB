//
//  BaseTableViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/4.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    //定义用户登录状态
    var isLogin = UserAccount.isLogin()
    var visitorView: VisitorView?

    override func loadView() {
        isLogin ? super.loadView(): addOtherView()
    }

    func addOtherView(){
        visitorView = VisitorView.visitorView()
        view = visitorView
//        visitorView?.delegate = self
        visitorView?.loginBtn.addTarget(self, action: Selector("loginBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        visitorView?.registerBtn.addTarget(self, action: Selector("registerBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("registerBtnClick:"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("loginBtnClick:"))
    }

    @objc private func registerBtnClick(btn: UIButton){
        alert("暂时实现不了登录,没有登录接口!")
    }

    @objc private func loginBtnClick(btn: UIButton){
        presentViewController(OAuthViewController(), animated: true, completion: nil)
    }
}

/*
extension BaseTableViewController: VisitorViewDelegate{
    func visitorViewRegisterBtnClick(visitorView: VisitorView){
        NJLog("a")
    }
    func visitorViewLoginBtnClick(visitorView: VisitorView){
        NJLog("b")
    }
}
*/
