//
//  AppDelegate.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/3.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //一般情况下全局性的东西要在AppDelegate设置
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
//        let image = UIImage.imageWithColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.93))
//        UINavigationBar.appearance().setBackgroundImage(image, forBarMetrics: .Default)
        UINavigationBar.appearance().barStyle = .Default
        //注册监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("switchRootViewController:"), name: SwitchRootViewController, object: nil)

        // 创建窗口
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = defaultsVC()
        window?.makeKeyAndVisible()
        return true
    }

    //在销毁的时候移除监听
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension AppDelegate{

    func switchRootViewController(notice: NSNotification){
        if notice.object as! Bool{
            //切换到首页
            window?.rootViewController = MainViewController()
        }else{
            //写换到欢迎界面
            window?.rootViewController = WelcomeViewController()
        }
    }


    private func defaultsVC() -> UIViewController{
        //判断是否登录
        if UserAccount.isLogin() {
            //已经登录判断是否有新版本
            return isNewVersion() ? NewFeatureViewController() : WelcomeViewController()
        }
        //没有登录就去登录
        return MainViewController()
    }

    private func isNewVersion() -> Bool{
        //加载info.plist
        //获取当前版本号
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        //获取上一版本号
        let defaults = NSUserDefaults.standardUserDefaults()
        let sandboxVersion = (defaults.objectForKey("nversion") as? String) ?? "0.0"
        //比较
        if currentVersion.compare(sandboxVersion) == NSComparisonResult.OrderedDescending{
            NJLog("有新版本")
            defaults.setObject(currentVersion, forKey: "nversion")
            return true
        }
        return false
    }
}

