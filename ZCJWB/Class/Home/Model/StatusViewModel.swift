//
//  StatusViewModel.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/12.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class StatusViewModel: NSObject {
    /// 模型对象
    var status: WBStatus
    /// 用户认证图片
    var verified_image: UIImage?
    /// 会员图片
    var mbrankImage: UIImage?
    /// 用户头像URL地址
    var icon_URL: NSURL?
    /// 微博格式化之后的创建时间
    var created_Time: String = ""
    /// 微博格式化之后的来源
    var source_Text: String = ""
    /// 每条微博的所有图片url地址
    var thumbpics:[NSURL]?

    init(status: WBStatus)
    {
        self.status = status

        // 处理头像
        icon_URL = NSURL(string: status.user?.profile_image_url ?? "")

        // 处理会员图标
        if status.user?.mbrank >= 1 && status.user?.mbrank <= 6  {
            mbrankImage = UIImage(named: "common_icon_membership_level\(status.user!.mbrank)")
        }
        // 处理认证图片
        switch status.user?.verified_type ?? -1{
            case 0:
                verified_image = R.image.avatar_vip
            case 2, 3, 5:
                verified_image = R.image.avatar_enterprise_vip
            case 220:
                verified_image = R.image.avatar_grassroot
            default:
                verified_image = nil
        }

        // 处理来源
        if let sourceStr: NSString = status.source where sourceStr != "" {
            // 6.1获取从什么地方开始截取
            let startIndex = sourceStr.rangeOfString(">").location + 1
            // 6.2获取截取多长的长度
            let length = sourceStr.rangeOfString("<", options: NSStringCompareOptions.BackwardsSearch).location - startIndex
            // 6.3截取字符串
            let rest = sourceStr.substringWithRange(NSMakeRange(startIndex, length))
            source_Text = "来自: " + rest
        }

        // 处理时间
        // "Sun Dec 06 11:10:41 +0800 2015"
        if let timeStr = status.created_at where timeStr != ""{
            // 1.将服务器返回的时间格式化为NSDate
            let createDate = NSDate.createDate(timeStr, formatterStr: "EE MM dd HH:mm:ss Z yyyy")

            // 2.生成发布微博时间对应的字符串
            created_Time = createDate.descriptionStr()
        }

        // 处理图片url
//        if let picurls = status.pic_urls {
        if let picurls = (status.retweeted_status != nil) ? status.retweeted_status?.pic_urls : status.pic_urls {
            thumbpics = [NSURL]()
            for picurl in picurls {
                guard let url = picurl["thumbnail_pic"] as? String else{
                    return
                }
                thumbpics?.append(NSURL(string: url)!)
            }
        }

    }

}
