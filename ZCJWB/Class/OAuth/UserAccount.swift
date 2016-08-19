//
//  UserAccount.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/10.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class UserAccount: NSObject, NSCoding {
    /// 令牌
    var access_token: String?
    /// 从授权那一刻开始,多少秒后过期时间
    var expires_in: Int = 0 {
        didSet{
            //生成真正过期时间
            expires_date = NSDate(timeIntervalSinceNow: NSTimeInterval(expires_in))
        }
    }
    /// 真正过期时间
    var expires_date: NSDate?
    /// 用户id
    var uid: String?
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    /// 用户昵称
    var screen_name: String?

    init(dict: [String: AnyObject]) {
        super.init()
        //如果想要初始化使用KVC必须先调用super.init()方法初始化对象
        //如果属性是基本数据类型,那么不建议使用可选类型,因为基本数据类型的可选类型在super.init()方法中不会分配存储空间
        self.setValuesForKeysWithDictionary(dict)
    }

    //当KVC发现没有对应的key是就会调用
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {

    }

    override var description: String {
        let keys = ["access_token", "expires_in", "expires_date", "uid"]
        let dict = dictionaryWithValuesForKeys(keys)
        return "\(dict)"
    }

    //MARK: - 外部控制方法
    //归档
    func saveAccount() -> Bool{
        //归档对象
        return NSKeyedArchiver.archiveRootObject(self, toFile: UserAccount.filePath)
    }

    /// 定义属性保存授权模型
    static var account: UserAccount?
    //解归档
    class func loadAccount() -> UserAccount? {
        if UserAccount.account != nil{
            return UserAccount.account
        }
        NJLog(UserAccount.filePath)
        guard let _account = NSKeyedUnarchiver.unarchiveObjectWithFile(UserAccount.filePath) as? UserAccount else{
            return nil
        }
        //校验是否过期
        guard let date = _account.expires_date where date.compare(NSDate()) != NSComparisonResult.OrderedAscending else{
            NJLog("过期了")
            return nil
        }
        UserAccount.account = _account
        return UserAccount.account
    }

    func loadUserInfo(finished: (account: UserAccount?, error: NSError?)->()){
        //断言
        //断定access_token一定不等于nil,如果运行是access_token等于nil,那么程序就会崩溃,就会报错
        assert(access_token != nil, "使用该方法必须先授权")
        let path = "2/users/show.json"
        //2.准备请求参数
        //redirect_uri最后一定不能有斜线
        let param = ["access_token": access_token!, "uid": uid!]
        NetworkTools.sharedInstance.GET(path, parameters: param, success: { (task, data) -> Void in
                let dict = data as! [String: AnyObject]
                self.avatar_large = dict["avatar_large"] as? String
                self.screen_name = dict["screen_name"] as? String
                finished(account: self, error: nil)
            }) { (task, error) -> Void in
                finished(account: nil, error: error)
        }

    }

    class func isLogin() -> Bool {
        return UserAccount.loadAccount() != nil
    }

    static let filePath = "useraccount.plist".cachesDir()
    //MARK: - NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(access_token, forKey: "access_token")
        aCoder.encodeInteger(expires_in, forKey: "expires_in")
        aCoder.encodeObject(uid, forKey: "uid")
        aCoder.encodeObject(expires_date, forKey: "expires_date")
        aCoder.encodeObject(avatar_large, forKey: "avatar_large")
        aCoder.encodeObject(screen_name, forKey: "screen_name")
    }

    required init?(coder aDecoder: NSCoder){
        self.access_token = aDecoder.decodeObjectForKey("access_token") as? String
        self.expires_in = aDecoder.decodeIntegerForKey("expires_in") as Int
        self.uid = aDecoder.decodeObjectForKey("uid") as? String
        self.expires_date = aDecoder.decodeObjectForKey("expires_date") as? NSDate
        self.avatar_large = aDecoder.decodeObjectForKey("avatar_large") as? String
        self.screen_name = aDecoder.decodeObjectForKey("screen_name") as? String
    }
}
