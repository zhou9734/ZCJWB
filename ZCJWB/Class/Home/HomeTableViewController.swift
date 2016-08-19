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
    var statuesListModel = StatusListModel()
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

    //MARK: - 获取微博数据
    @objc private func loadWBData(){
        statuesListModel.loadWBData(lastWBStatus) { (models, error) -> () in
            //校验
            if error != nil{
                SVProgressHUD.showErrorWithStatus("获取微博数据失败")
                SVProgressHUD.setDefaultMaskType(.Black)
                return
            }
            // 2.关闭菊花
            self.refreshControl?.endRefreshing()
            // 3.显示刷新提醒
            self.showRefreshTipLbl(models!.count)
            // 4.刷新表格
            self.tableView.reloadData()
        }
    }
    //MARK: - 显示刷新提醒
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
        return self.statuesListModel.statues?.count ?? 0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(HomeIdentifier, forIndexPath: indexPath) as! HomeTableViewCell
        cell.viewModel = statuesListModel.statues![indexPath.row]
        if indexPath.row == (statuesListModel.statues!.count - 1) {
            lastWBStatus = true
            loadWBData()
        }else{
            lastWBStatus = false
        }
        return cell
    }
    /// 计算行高
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let viewModel = statuesListModel.statues![indexPath.row]
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