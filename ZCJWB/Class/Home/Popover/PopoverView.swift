//
//  File.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/5.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

protocol PopoverViewDelegate: NSObjectProtocol {
    func didSelectRowAtIndexPath(indexPath: NSIndexPath)
    func downBtnArrow()
}

class PopoverView: UIView {
    let MENU_POINTER_TAG = 1101
    let MENU_TABLE_VIEW_TAG = 1102
    var menuItmes: [String]?
    var containButton: UIButton?
    var deleagte: PopoverViewDelegate?
    //初始化UIView
    convenience init(menuPopover: CGRect, menuItem: [String], menuPoint: CGRect) {
        self.init(frame: menuPopover)
        menuItmes = menuItem

        //创建按钮
        containButton = UIButton()
        containButton?.backgroundColor = UIColor(red: 0/225.0, green: 0/225.0, blue: 0/225.0, alpha: 0.0)
        containButton?.addTarget(self, action: Selector("dismissMenuPopover"), forControlEvents: UIControlEvents.TouchUpInside)
        //给按钮添加图片
        let menuPointerView = UIImageView(frame: menuPoint)
        menuPointerView.image = R.image.options_pointer
        menuPointerView.tag = MENU_POINTER_TAG
        containButton?.addSubview(menuPointerView)

        //创建tableView
        let menuItemTableView = UITableView(frame: CGRectMake(0, 11, frame.size.width, frame.size.height))
        menuItemTableView.dataSource = self
        menuItemTableView.delegate = self
        //设置分割符
        menuItemTableView.separatorStyle = .None
        //禁用滚动
        menuItemTableView.scrollEnabled = false
        menuItemTableView.backgroundColor = UIColor.clearColor()
        menuItemTableView.tag = MENU_TABLE_VIEW_TAG
        let bgView = UIImageView(frame:CGRectMake(0, 11, frame.size.width, frame.size.height))
        bgView.image = R.image.menu_PopOver_BG
        menuItemTableView.backgroundView = bgView
        addSubview(menuItemTableView)
        containButton?.addSubview(self)
    }

    //显示UIView
    func showInView(_view: UIView){
        containButton?.alpha = 0
        containButton?.frame = _view.bounds
        _view.addSubview(self.containButton!)
        UIView.animateWithDuration(0.5, animations: {
            self.containButton?.alpha = 1
        },completion: { (Bool) -> Void in
        })
    }

    func dismissMenuPopover(){
        hide()
        deleagte?.downBtnArrow()
    }

    func hide(){
        UIView.animateWithDuration(0.5, animations: {
            self.containButton?.alpha = 0
        }, completion: { (Bool) -> Void in
            self.containButton?.removeFromSuperview()
        })
    }
}

extension PopoverView: UITableViewDataSource, UITableViewDelegate{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItmes!.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell_identifier = "MenuPopoverCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cell_identifier)
        if cell == nil{
            //创建新的cell
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cell_identifier)
            //设置字体
            cell!.textLabel?.font = UIFont.systemFontOfSize(15)
            cell?.textLabel?.textColor = UIColor.whiteColor()
            //设置选中cell样式
            cell!.selectionStyle = .Gray
            //给cell赋值
            cell!.textLabel?.text = self.menuItmes![indexPath.row]
            cell?.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1)
            cell!.accessoryType = .None
        }

        let numberOfRows = tableView.numberOfSections
        if (numberOfRows > 1) && !(indexPath.row == numberOfRows - 1){
            addSeparatorImageToCell(cell!)
        }
        return cell!
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.deleagte?.didSelectRowAtIndexPath(indexPath)
    }

    func addSeparatorImageToCell(cell: UITableViewCell){
        let imageView = UIImageView(frame: CGRectMake(10, 43, self.frame.size.width - 20, 1))
        imageView.image = R.image.defaultLine
        imageView.opaque = true
        cell.contentView.addSubview(imageView)
    }

}