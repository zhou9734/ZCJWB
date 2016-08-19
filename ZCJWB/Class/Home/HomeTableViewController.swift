//
//  HomeTableViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/3.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

class HomeTableViewController: BaseTableViewController {
    var menuPopover: PopoverView?
    var menuItems: [String]?
    /// 缓存行高
    private var rowHeightCaches =  [String: CGFloat]()
    //所有微博
    var statues: [StatusViewModel]?
    let HomeIdentifier = "HomeIdentifier"
    var lastWBStatus = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //判断用户是否登录
        if !isLogin {
            super.visitorView?.setupVisitorInfo(nil, title: "关注一些人，回这里看看有什么惊喜")
            return
        }
        menuItems = ["菜单1", "菜单2", "菜单3", "菜单4"]
        //初始化导航条
        setupNav()
        //注册HomeTableViewCell
        tableView.registerClass(HomeTableViewCell.classForCoder(), forCellReuseIdentifier: HomeIdentifier)
        tableView.estimatedRowHeight = 300 //预估行高
        //分割线隐藏
        tableView.separatorStyle = .None
        refreshControl = ZCJRefreshControl()
        refreshControl?.addTarget(self, action: "loadWBData", forControlEvents: .ValueChanged)
        //开始加载
        refreshControl?.beginRefreshing()
        tableView.estimatedRowHeight = 320
        loadWBData()
        //插入提醒标签

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.insertSubview(tipTextLbl, atIndex: 0)
    }

    /**
     获取微博数据
     */
    @objc private func loadWBData(){
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
            if error != nil {
                SVProgressHUD.showErrorWithStatus("没有获取到微博数据")
                SVProgressHUD.setDefaultMaskType(.Black)
                return
            }
            guard let array = data else{
                return
            }
            //将字典转为模型数组
            var models = [StatusViewModel]()
            for arr in array{
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
            self.cacheWBPic(models)
            //关闭菊花
            self.refreshControl?.endRefreshing()
            self.showRefreshTipLbl(models.count)
        }
    }
    //MARL: - 显示刷新提醒
    private func showRefreshTipLbl(count: Int){
        // 1.设置提醒文本
        tipTextLbl.text = (count == 0) ? "没有更多数据" : "刷新到\(count)条数据"
        tipTextLbl.hidden = false
        // 2.执行动画
        UIView.animateWithDuration(1.5, animations: { () -> Void in
            self.tipTextLbl.transform = CGAffineTransformMakeTranslation(0, 44)
            }) { (_) -> Void in
                UIView.animateWithDuration(1.0, delay: 2.0, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.tipTextLbl.transform = CGAffineTransformIdentity
                    }, completion: { (_) -> Void in
                        self.tipTextLbl.hidden = true
                })
        }    }

    //MARK: - 缓存微博配图
    private func cacheWBPic(viewModels: [StatusViewModel]){
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
            self.tableView.reloadData()
        }
    }

    //设置导航
    private func setupNav(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop", target: self, action: Selector("popBtnClick:"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendattention", target: self, action: Selector("friendAttentioinBtnClick:"))
        navigationItem.titleView = titleButton
    }

    private lazy var titleButton: TitleButton = {
        let btn = TitleButton()
        let title = UserAccount.loadAccount()?.screen_name
        btn.setTitle(title, forState: .Normal)
        btn.addTarget(self, action: Selector("titleButtonClick:"), forControlEvents: .TouchUpInside)
        return btn
    }()

    //提醒标签
    private lazy var tipTextLbl: UILabel = {
        let lbl = UILabel()
        lbl.frame = CGRect(x: 0, y: 00, width: ScreenWidth, height: 44)
        lbl.text = "没有更多数据"
        lbl.textColor = UIColor.whiteColor()
        lbl.textAlignment = .Center
        lbl.backgroundColor = UIColor.orangeColor()
        lbl.hidden = true
        return lbl
    }()

    @objc private func titleButtonClick(btn: TitleButton){
        if !btn.selected {
            //menuPopover:弹出的菜单位置; menuPoint:菜单顶部的三角形位置
            menuPopover = PopoverView(menuPopover: CGRectMake(ScreenWidth*0.3, 70, 140, 170), menuItem: self.menuItems!, menuPoint:  CGRectMake(ScreenWidth*0.3 + 60, 70, 23, 11))
            menuPopover?.deleagte = self
            menuPopover?.showInView(view)
            btn.selected = true
        }else {
            menuPopover?.dismissMenuPopover()
        }
    }

    @objc private func friendAttentioinBtnClick(btn: UIButton){
        NJLog("aa")
    }

    @objc private func popBtnClick(btn: UIButton){
        presentViewController(R.storyboard.qRCode.initialViewController!, animated: true, completion: nil)
    }
}

extension HomeTableViewController : PopoverViewDelegate{
    func didSelectRowAtIndexPath(indexPath: NSIndexPath){
        alert("你选中了【\(menuItems![indexPath.row])】")
        menuPopover?.dismissMenuPopover()
    }

    func downBtnArrow() {
        titleButton.selected = false
    }
}

extension HomeTableViewController{

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statues?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(HomeIdentifier, forIndexPath: indexPath) as! HomeTableViewCell
        cell.viewModel = statues![indexPath.row]
        if indexPath.row == (statues!.count - 1) {
            lastWBStatus = true
            loadWBData()
        }
        return cell
    }

    /// 计算行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let viewModel = statues![indexPath.row]
        // 1.从缓存中获取行高
        let idstr = viewModel.status.idstr ?? "-1"
        guard let height = rowHeightCaches[idstr] else{
            // 缓存中没有行高
            // 2.计算行高
            // 2.1获取当前行对应的cell
            let cell = tableView.dequeueReusableCellWithIdentifier(HomeIdentifier) as! HomeTableViewCell
            // 2.1缓存行高
            let  temp = cell.calculateRowHeight(viewModel)
            rowHeightCaches[idstr] = temp
            // 3.返回行高
            return temp
        }
        // 缓存中有就直接返回缓存中的高度
        return height
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 释放缓存数据
        rowHeightCaches.removeAll()
    }
}