//
//  MainViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/3.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewControllers()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tabBar.addSubview(composeButton)
        //保持按钮的尺寸
        let rect = composeButton.frame
        //计算width值
        let width = tabBar.bounds.width/CGFloat(childViewControllers.count)
        composeButton.frame = CGRect(x: 2 * width, y: 0, width: width, height: rect.height)
    }

    //MARK: -创建子控制器
    private func addChildViewControllers(){
        //1.通过JSON文件创建控制器
        //1.1 读取JSON文件

        guard let filePath = NSBundle.mainBundle().pathForResource("MainVCSettings.json", ofType: nil) else{
            NJLog("文件不存在")
            return
        }
        guard let data = NSData(contentsOfFile: filePath) else{
            NJLog("加载二进制JSON文件出错")
            return
        }
        //1.2 将JSON数据转成对象(字典)
        do {
            // try 正常的异常处理, try  catch
            // try! 告诉系统有一个异常,不需要通过do try catch来处理异常,一旦发生异常就会崩溃,不发生异常通过
            // try? 告诉系统它可能有错也可能没错,如果没有系统会包装一个值给我们,如果出错系统会返回nil 也不需要使用do try catch来处理
            let obj = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! [[String : AnyObject]]
            //1.3 遍历数组字典取出每一个字典
            for dict in obj{
                let vcName = dict["vcName"] as? String
                let title = dict["title"] as? String
                let imageName = dict["imageName"] as? String
                //1.4 根据遍历到的字典创建控制器
                addChildViewController(vcName, title: title, imageName: imageName)
            }
        }catch let error as NSError{
            NJLog(error.code)
            NJLog(error.description)

            addChildViewController("HomeTableViewController", title: "首页", imageName: "tabbar_home")
            addChildViewController("MessageTableViewController", title: "消息", imageName: "tabbar_message_center")
            addChildViewController("NullViewController", title: "", imageName: "")
            addChildViewController("DiscoverTableViewController", title: "发现", imageName: "tabbar_discover")
            addChildViewController("ProfileTableViewController", title: "我", imageName: "tabbar_profile")
        }
    }

    private func addChildViewController(childControllerName: String?, title: String?, imageName: String?) {

        //获取命名空间
        guard let name = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] as? String else {
            NJLog("命名空间获取失败!")
            return
        }

        //获取类型
        var cls: AnyClass? = nil
        if let vcName = childControllerName {
            cls = NSClassFromString(name + "." + vcName)
        }

        guard let typeCls = cls as? UITableViewController.Type else{
            NJLog("类型转换错误")
            return
        }

        let childController = typeCls.init()

        childController.title = title
        if let imName = imageName where imName != ""{
            childController.tabBarItem.image = UIImage(named: imName)
            childController.tabBarItem.selectedImage = UIImage(named: imName + "_highlighted")
        }
        childController.view.backgroundColor = Color_GlobalBackground

        let nav = NavigationController()
        nav.addChildViewController(childController)
        addChildViewController(nav)
    }

    //MARK: -懒加载按钮
    private lazy var composeButton : UIButton = {
        let btn = UIButton(imageName: "tabbar_compose_icon_add", backgroundImage: "tabbar_compose_button")
        btn.addTarget(self, action: "composeBtnClick", forControlEvents: .TouchUpInside)
        return btn
    }()

    @objc private func composeBtnClick(){
        presentViewController(ComposeViewController(), animated: true, completion: nil)
    }
}
