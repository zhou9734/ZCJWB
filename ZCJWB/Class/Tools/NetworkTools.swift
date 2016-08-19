//
//  NetworkTools.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/10.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTools: AFHTTPSessionManager {
    //单例
    static let sharedInstance: NetworkTools = {
        //注意baseURL后面一定要写上斜线(/)
        let url = NSURL(string: "https://api.weibo.com/")!
        let instance = NetworkTools(baseURL: url, sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())

        instance.responseSerializer.acceptableContentTypes =  NSSet(objects: "application/json", "text/json", "text/javascript", "text/plain") as Set

        return instance
    }()


    //MARK: - 外部控制方法

    func loadStatuses(since_id: String, max_id: String, finished: (data: [[String: AnyObject]]?, error: NSError?)->()){
        //校验
        let _account = UserAccount.loadAccount()
        assert(_account != nil, "必须授权之后才能获取微博数据")
        //准备路径
        let path = "2/statuses/home_timeline.json"
        //参数
        let m_id = (max_id != "0") ? "\(Int64(max_id)! - 1)" : max_id
        let param = ["access_token": _account!.access_token!, "since_id": since_id, "max_id" : m_id]
        //GET请求
        GET(path, parameters: param, success: { (task, objc) -> Void in
                //返回数据给调用者
                guard let array = (objc as! [String: AnyObject])["statuses"] as? [[String: AnyObject]] else{
                    finished(data: nil, error: NSError(domain: "com.webo.www", code: 666, userInfo: ["message" : "没有获取到微博数据"]))
                    return
                }
                finished(data: array, error: nil)
            }) { (task, error) -> Void in
                finished(data: nil, error: error)
        }
    }
}
