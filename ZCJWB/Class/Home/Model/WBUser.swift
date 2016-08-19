//
//  WBUser.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/12.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class WBUser: NSObject {
    /// 字符串型的用户UID
    var idstr: String?
    /// 用户昵称
    var screen_name: String?
    /// 用户头像地址（中图），50×50像素
    var profile_image_url: String?
    /// 微博用户认证: -1:没有认证, 0: 认证用户, 2,3,5:企业认证,220:微博达人
    var verified_type: Int = -1 {
        didSet{

            switch verified_type{
                case 0:
                    verifiedName = "avatar_vip"
                case 2,3,5:
                    verifiedName = "avatar_enterprise_vip"
                case 220:
                    verifiedName = "avatar_grassroot"
                default:
                    verifiedName = ""
            }

        }
    }
    /// 认证图片名称
    var verifiedName: String = ""

    /// 会员等级0:不是会员,1-6为会员等级
    var mbrank: Int = -1
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }

    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
    }

    override var description : String {
        let pops = ["idstr", "screen_name", "profile_image_url", "verified_type","mbrank"]
        let dict = dictionaryWithValuesForKeys(pops)
        return "\(dict)"
    }
}
