//
//  String+Extension.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/10.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

extension String {
    func cachesDir() -> String{
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
        //生成缓存路径
        let name = (self as NSString).lastPathComponent
        let filePath = (path as NSString).stringByAppendingPathComponent(name)
        return filePath
    }

    func docDir() -> String{
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory , NSSearchPathDomainMask.UserDomainMask, true).last!
        //生成缓存路径
        let name = (self as NSString).lastPathComponent
        let filePath = (path as NSString).stringByAppendingPathComponent(name)
        return filePath

    }

    func tmpDir() -> String{
        let path = NSTemporaryDirectory()
        //生成缓存路径
        let name = (self as NSString).lastPathComponent
        let filePath = (path as NSString).stringByAppendingPathComponent(name)
        return filePath
    }
}
