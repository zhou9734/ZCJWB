//
//  WBStatus.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/11.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class WBStatus: NSObject {
    /// 微博创建时间
    var created_at: String?
    /// 字符串型的微博ID
    var idstr: String?
    /// 微博信息内容
    var text: String?
    /// 微博来源
    var source: String?
    /// 用户
    var user: WBUser?
    /// 微博图片
    var pic_urls: [[String: AnyObject]]?
    /// 转发微博
    var retweeted_status: WBStatus?


    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }

    //使用KVC字典转模型时如果字典中的
    override func setValue(value: AnyObject?, forKey key: String) {
        if key == "user"{
            user = WBUser(dict: value as! [String: AnyObject])
            return
        }
        if key == "retweeted_status"{
            retweeted_status = WBStatus(dict: value as! [String: AnyObject])
            return
        }
        super.setValue(value, forKey: key)
    }

    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
    }

    override var description : String {
        let pops = ["created_at", "idstr", "text", "source"]
        let dict = dictionaryWithValuesForKeys(pops)
        return "\(dict)"
    }
}
