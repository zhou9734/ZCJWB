//
//  OAuthViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/9.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SVProgressHUD

class OAuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    private func setupUI(){

        view.addSubview(naviBar)
        view.addSubview(webView)
        naviBar.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.left.right.equalTo(0)
            make.height.equalTo(60)
            make.top.equalTo(1)
        }

        webView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(naviBar.snp_bottom).offset(1)
        }
        webView.delegate = self
    }

    private func loadData(){
        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=" + WB_APP_KEY+"&redirect_uri=" + REDIRECT_URL
        guard let url = NSURL(string: urlStr) else {
            return
        }

        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

    private lazy var webView = UIWebView()

    //导航条
    private lazy var naviBar: UINavigationBar = {
        let _navigationBar = UINavigationBar()
        let leftBtn = UIButton()
        leftBtn.setTitle("关闭", forState: .Normal)
        leftBtn.addTarget(self, action: Selector("closeBtnClick"), forControlEvents: .TouchUpInside)
        leftBtn.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        leftBtn.sizeToFit()

        let rightBtn = UIButton()
        rightBtn.setTitle("填充", forState: .Normal)
        rightBtn.addTarget(self, action: Selector("fillBtnClick"), forControlEvents: .TouchUpInside)
        rightBtn.setTitleColor(UIColor.orangeColor(), forState: .Normal)
        rightBtn.sizeToFit()
        let naviItem = UINavigationItem()
        naviItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        naviItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        naviItem.title = "授权登录"
        _navigationBar.items = [naviItem]

        let iamge = UIImage.imageWithColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.89))
        _navigationBar.setBackgroundImage(iamge, forBarMetrics: .Default)
        _navigationBar.barStyle = .Default
        return _navigationBar
    }()

    @objc private func closeBtnClick(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func fillBtnClick(){
        let jsStr = "document.getElementById('userId').value = '18156856183';document.getElementById('passwd').focus();document.getElementById('passwd').value = 'zhou6036169ppy';"
        webView.stringByEvaluatingJavaScriptFromString(jsStr)
    }

}

extension OAuthViewController: UIWebViewDelegate{

    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.showInfoWithStatus("正在加载中...")
        SVProgressHUD.setDefaultMaskType(.Black)
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        /*
        登录界面: https://api.weibo.com/oauth2/authorize?client_id=1168605738&redirect_uri=http://www.520it.com
        输入账号密码之后: https://api.weibo.com/oauth2/authorize
        取消授权: http://www.520it.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330
        授权:http://www.520it.com/?code=c2796542e264da89367f993131e6c904
        通过观察
        1.如果是授权成功获取失败都会跳转到授权回调页面
        2.如果授权回调页面包含code=就代表授权成功, 需要截取code=后面字符串
        3.而且如果是授权回调页面不需要显示给用户看, 返回false
        */
        guard let urlStr = request.URL?.absoluteString else{
            return false
        }
        if !urlStr.hasPrefix(REDIRECT_URL) {
            //是授权回调页面
            return true
        }
        let key = "code="
        guard let str = request.URL?.query else{
            return false
        }
        if str.hasPrefix(key){
            let code = str.substringFromIndex(key.endIndex)
            loadAccessToken(code)
        }

        return false
    }

    //利用RequestToken换取AccessToken
    private func loadAccessToken(code: String){
        //1.准备请求路径
        let path = "oauth2/access_token"
        //2.准备请求参数
        //redirect_uri最后一定不能有斜线
        let param = ["client_id": WB_APP_KEY, "client_secret": WB_APP_SECRET, "grant_type": "authorization_code", "code": code, "redirect_uri": REDIRECT_URL]
        //3.发送POST请求
        /*
        同一个用户对一个应用程序授权返回的AccessToken是一样的,所以没必要多次登录
        {"access_token" = "2.00qXkkXGej2FRBfeb68137bb0Phjho";
        "expires_in" = 157679999;
        "remind_in" = 157679999;
        uid = 5995558090;}
        */
        NetworkTools.sharedInstance.POST(path, parameters: param, success: { (task, dictionary) -> Void in
            let account = UserAccount(dict: dictionary as! [String : AnyObject])
            //获取用户信息
            account.loadUserInfo({ (account, error) -> () in
                account?.saveAccount()
                self.closeBtnClick()
                //跳转到欢迎界面
                NSNotificationCenter.defaultCenter().postNotificationName(SwitchRootViewController, object: false)
            })
            }) { (task , error) -> Void in
                NJLog(error)
        }
    }
}
