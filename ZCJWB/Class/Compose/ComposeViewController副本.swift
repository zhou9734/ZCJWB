//
//  ComposeViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/22.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SVProgressHUD
let SelectedPhotoDone = "SelectedPhotoDone"
class ComposeViewController: UIViewController {
    var toolbarBottomConstraint: Constraint?
    //键盘表情
    //避免循环引用上[unowned self]或[weak self]
    private lazy var keyboardEmotion: KeyboardController = KeyboardController {[unowned self] (emoticon) -> () in
        self.textView.insertEmoticon(emoticon)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        addChildViewController(keyboardEmotion)
        view.backgroundColor = UIColor.whiteColor()
        setupUI()
        setFrameConstant()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChange:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    //MARK: - 方法
    @objc private func keyboardWillChange(notice: NSNotification){
        //弹出 UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 465}, {414, 271}}";
        let rect = notice.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        let height = ScreenHeight - rect.origin.y
        // 获取动画当前节奏,节奏是7, 连续执行两次动画会直接忽略上一下进入下一次而
        //普通节奏会等待上一次做完才会执行下一次
        let curve = notice.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber

        toolbarBottomConstraint?.updateOffset(-height)
        UIView.animateWithDuration(0.25) { () -> Void in
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve.integerValue)!)
            self.view.layoutIfNeeded()
        }
    }
    //添加UI组件
    private func setupUI(){
//        let iamge = UIImage.imageWithColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.7))
//        navigationController?.navigationBar
//        navigationController?.navigationBar.setBackgroundImage(iamge, forBarMetrics: .Default)
//        navigationController?.navigationBar.barStyle = .Default
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButton)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.orangeColor()
        navigationItem.titleView = titleView
        rightButton.enabled = false
//        view.addSubview(titleView)
        view.addSubview(textView)
        view.addSubview(placeholderLbl)
        view.addSubview(toolbar)
        view.addSubview(locationBtn)
        view.addSubview(publicBtn)
        subtitleLbl.text = UserAccount.account?.screen_name
    }
    //布局
    private func setFrameConstant(){
//        titleView.snp_makeConstraints { (make) -> Void in
//            make.centerX.equalTo(view.snp_centerX)
//            make.top.equalTo(view.snp_top).offset(24)
//            make.width.equalTo(180)
//        }
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(titleView.snp_centerX)
            make.top.equalTo(titleView.snp_top)
        }
        subtitleLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(titleView.snp_centerX)
            make.top.equalTo(titleLbl.snp_bottom)
        }
        textView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp_top)
            make.left.right.bottom.equalTo(view)
            make.bottom.equalTo(view.snp_bottom)
        }
        placeholderLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(textView.snp_top).offset(8)
            make.left.equalTo(textView.snp_left).offset(4)
            make.width.equalTo(150)
        }
        toolbar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            toolbarBottomConstraint = make.bottom.equalTo(view.snp_bottom).constraint
        }
        locationBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left).offset(5)
            make.bottom.equalTo(toolbar.snp_top).offset(-5)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        publicBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(view.snp_right).offset(-5)
            make.bottom.equalTo(toolbar.snp_top).offset(-5)
            make.size.equalTo(CGSize(width: 70, height: 30))
        }
    }
    //MARK: - 初始化组件
    //取消按钮
    private lazy var leftButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", forState: .Normal)
        btn.addTarget(self, action: Selector("cancelBtnClick"), forControlEvents: .TouchUpInside)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(16)
        btn.frame.size = CGSize(width: 60, height: 40)
        btn.sizeToFit()
        return btn
    }()
    //发送按钮
    private lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("发送", forState: .Normal)
        btn.addTarget(self, action: Selector("sendBtnClick"), forControlEvents: .TouchUpInside)
        btn.setBackgroundImage(R.image.tabbar_compose_left_button, forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.frame.size = CGSize(width: 45, height: 30)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        return btn
    }()
    //标题
    private lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "发微博"
        lbl.textAlignment = .Center
        lbl.font = UIFont.systemFontOfSize(16)
        return lbl
    }()
    //副标题
    private lazy var subtitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.grayColor()
        lbl.textAlignment = .Center
        lbl.font = UIFont.systemFontOfSize(14)
        return lbl
    }()
    private lazy var titleView: UIView = {
        let _titleView = UIView()
        _titleView.addSubview(self.titleLbl)
        _titleView.addSubview(self.subtitleLbl)
        _titleView.backgroundColor = UIColor.greenColor()
        return _titleView
    }()
    //文本框
    private lazy var textView: UITextView = {
        let txtView = UITextView()
        txtView.font = UIFont.systemFontOfSize(18)
        txtView.alwaysBounceVertical = true
        txtView.delegate = self
        return txtView
    }()
    //提示标签
    private lazy var placeholderLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "分享新鲜事..."
        lbl.textColor = UIColor.grayColor()
        lbl.textAlignment = .Left
        lbl.font = UIFont.systemFontOfSize(16)
        return lbl
    }()
    //toolbar
    private lazy var toolbar: UIToolbar = {
        let tbar = UIToolbar()
        var items = [UIBarButtonItem]()
        let flexible = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        items.append(UIBarButtonItem(imageName: "compose_toolbar_picture", target: self, action: Selector("pictureBtnClick")))
        items.append(flexible)
        items.append(UIBarButtonItem(imageName: "compose_mentionbutton_background", target: self, action: Selector("mentionBtnClick")))
        items.append(flexible)
        items.append(UIBarButtonItem(imageName: "compose_trendbutton_background", target: self, action: Selector("trendBtnClick")))
        items.append(flexible)
        items.append(UIBarButtonItem(imageName: "compose_emoticonbutton_background", target: self, action: Selector("emoticonBtnClick")))
        items.append(flexible)
        items.append(UIBarButtonItem(imageName: "compose_toolbar_more", target: self, action: Selector("toolMoreBtnClick")))
        tbar.items = items
        return tbar
    }()
    //显示位置
    private lazy var locationBtn: UIButton = {
        let btn = UIButton(imageName: "compose_locatebutton_ready", backgroundImage: "tabbar_compose_below_button")
        btn.setTitle(" 显示位置", forState: .Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.setBackgroundImage(R.image.tabbar_compose_below_button_highlighted, forState: .Highlighted)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        return btn
    }()
    //是否公开
    private lazy var publicBtn: UIButton = {
        let btn = UIButton(imageName: "compose_publicbutton", backgroundImage: "tabbar_compose_below_button")
        btn.setTitle(" 公开", forState: .Normal)
        btn.setTitleColor(UIColor(red: 64.0/255.0, green: 104.0/255.0, blue: 164.0/255.0, alpha: 1), forState: .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        btn.layer.cornerRadius = 15
        btn.clipsToBounds = true
        return btn
    }()
    @objc private func cancelBtnClick(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - 发送微博
    @objc private func sendBtnClick(){
        //准备微博数据
        let status = textView.emoticonAttributedText()
        NetworkTools.sharedInstance.sendStatus(status, visible: 0) { (data, error) -> () in
            SVProgressHUD.setDefaultMaskType(.Black)
            if error != nil{
                SVProgressHUD.showErrorWithStatus("发送微博失败")
                return
            }
            SVProgressHUD.showSuccessWithStatus("发送微博成功")
            self.cancelBtnClick()
        }
    }
    //MARK: - 打开图片库
    @objc private func pictureBtnClick(){
        presentViewController(UINavigationController(rootViewController: PhotoViewController()), animated: true, completion: nil)
    }
    @objc private func mentionBtnClick(){}
    @objc private func trendBtnClick(){}
    //MARK: - 表情键盘
    @objc private func emoticonBtnClick(){
        //如果是默认键盘textView.inputView为nil
        //如果不是系统键盘textView.inputView不是nil
        //如果想要切换键盘必须先关闭键盘,切换之后再重新打开键盘
        textView.resignFirstResponder()
        if textView.inputView != nil {
            //切换键盘
            textView.inputView = nil
        }else{
            textView.inputView = keyboardEmotion.view
        }
        textView.becomeFirstResponder()
    }
    @objc private func toolMoreBtnClick(){}
}
//MARK: - UITextViewDelegate代理
extension ComposeViewController: UITextViewDelegate{
    //文本改变
    func textViewDidChange(textView: UITextView) {
        //注意: 如果输入的是表情则不会触发事件
        placeholderLbl.hidden = textView.hasText()
        rightButton.enabled = textView.hasText()
        if textView.hasText() {
            rightButton.setBackgroundImage(R.image.common_button_big_orange, forState: .Normal)
            rightButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }else{
            rightButton.setBackgroundImage(R.image.tabbar_compose_below_button, forState: .Normal)
            rightButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
    }
    //即将拖拽
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
}
