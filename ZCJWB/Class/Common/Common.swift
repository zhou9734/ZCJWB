
//
//  Common.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/3.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
// 全局背景
let Color_GlobalBackground = UIColor.whiteColor()
let Color_NavBackground = UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0)

let ScreenWidth = UIScreen.mainScreen().bounds.width
let ScreenHeight = UIScreen.mainScreen().bounds.height
//OAuth授权的key
let WB_APP_KEY = "1168605738"
//OAuth授权的app_secret
let WB_APP_SECRET = "968fb67661aa1e811e171a6937a699c0"
//重定向url
let REDIRECT_URL = "http://www.520it.com"
//切换RootViewController
let SwitchRootViewController = "SwitchRootViewController"


func NJLog<T>(message: T, fileName: String = __FILE__, methodName: String = __FUNCTION__, lineNumber: Int = __LINE__){

    //只有在DEBUG模式下才会打印. 需要在Build Settig中设置
    #if DEBUG
        var _fileName = (fileName as NSString).pathComponents.last!
        _fileName = _fileName.substringToIndex((_fileName.rangeOfString(".swift")?.startIndex)!)
        print("\(_fileName).\(methodName).[\(lineNumber)]: \(message)")
    #endif
}

func alert(msg: String){
    let alertView = UIAlertView(title: nil, message: msg, delegate: nil, cancelButtonTitle: "确定")
    alertView.show()
}
