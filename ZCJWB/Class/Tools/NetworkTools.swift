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
    /**
        加载数据
    - parameter since_id: 下拉刷新
    - parameter max_id:   上拉加载更多
    - parameter finished: 完成回调
    */
    //MARK: - 加载微博数据
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

    //MARK: - 发送一条微博
    func sendStatus(status: String?,image: UIImage?, visible: Int = 0, finished: (data: AnyObject?, error: NSError?) -> ()){
        //校验
        let _account = UserAccount.loadAccount()
        assert(_account != nil, "必须授权之后才能获取微博数据")
        var path = "2/statuses/update.json"
        let param = ["access_token": _account!.access_token!, "status": status ?? "", "visible" : visible]
        if let pic = image{
            path = "2/statuses/upload.json"
            POST(path, parameters: param, constructingBodyWithBlock: { (formData) -> Void in
                let picData = UIImagePNGRepresentation(pic)
                formData.appendPartWithFileData(picData!, name: "pic", fileName: "a.png", mimeType: "application/octet-stream")
                }, success: { (task, data) -> Void in
                    finished(data: data , error: nil)
                }, failure: { (task, error) -> Void in
                    finished(data: nil, error: error)
            })
        }else{
            POST(path, parameters: param, success: { (task, data) -> Void in
                    finished(data: data , error: nil)
                }) { (task, error) -> Void in
                    finished(data: nil, error: error)
            }
        }
    }
}
