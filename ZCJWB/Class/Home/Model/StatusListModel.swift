//
//  StatusListModel.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/19.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SDWebImage

class StatusListModel: NSObject {
    var statues: [StatusViewModel]?
    //MARK: - 加载数据
    func loadWBData(lastWBStatus: Bool, finished:(models: [StatusViewModel]?, error: NSError?) -> ()){
        /*
        since_id	false	int64	若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
        max_id	false	int64	若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
        默认情况下, 新浪返回的数据是按照微博ID从大到小得返回给我们的
        也就意味着微博ID越大, 这条微博发布时间就越晚
        经过分析, 如果要实现下拉刷新需要, 指定since_id为第一条微博的id
        如果要实现上拉加载更多, 需要指定max_id为最后一条微博id -1
        */

        var since_id = statues?.first?.status.idstr ?? "0"
        var max_id = "0"
        if lastWBStatus {
            since_id = "0"
            max_id = statues?.last?.status.idstr ?? "0"
        }
        NetworkTools.sharedInstance.loadStatuses(since_id, max_id: max_id) { (data, error) -> () in
            // 1.安全校验
            if error != nil{
                finished(models: nil, error: error)
                return
            }
            //将字典转为模型数组
            var models = [StatusViewModel]()
            for arr in data!{
                let status = WBStatus(dict: arr)
                let viewModel = StatusViewModel(status: status)
                models.append(viewModel)
            }
            //加载数据
            if since_id != "0" {
                self.statues = models + self.statues!
            }else if max_id != "0"{
                self.statues = self.statues! + models
            }else{
                self.statues = models
            }
            //显示图片依赖配图,只有下载好图片才能显示
            //缓存微博图片
            self.cacheWBPic(models, finished: finished)
        }
    }
    //MARK: - 缓存微博配图
    private func cacheWBPic(viewModels: [StatusViewModel],finished:(models: [StatusViewModel]?, error: NSError?) -> ()){
        //1.创建一个组
        let group = dispatch_group_create()
        for viewModel in viewModels{
            //从模型中取出数据
            guard let thumbpic = viewModel.thumbpics else {
                continue
            }
            for url in thumbpic{
                //2将当前的下载添加到组中
                dispatch_group_enter(group)
                //利用SDWebImage下载图片
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, ErrorType, _, _, _) -> Void in
                    //将下载操作从组中移除
                    dispatch_group_leave(group)
                })
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            finished(models: viewModels, error: nil)
        }
    }
}
