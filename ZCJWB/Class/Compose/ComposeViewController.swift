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
let SelectedPhotoIdentifier = "SelectedPhotoIdentifier"
class ComposeViewController: UIViewController {
    var alassetModels = [ALAssentModel]()
    var toolbarBottomConstraint: Constraint?
    //TextView高度
    var textViewHeightConstraint: Constraint?
    //键盘表情
    //避免循环引用上[unowned self]或[weak self]
    private lazy var keyboardEmotion: KeyboardController = KeyboardController {[unowned self] (emoticon) -> () in
        self.textView.insertEmoticon(emoticon)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        setupUI()
        setFrameConstant()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChange:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("selectedPhotoDown:"), name: SelectedPhotoDone, object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    //MARK: - 键盘改变方法
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
        view.addSubview(navigationBar)
        rightButton.enabled = false
        view.addSubview(titleView)
        view.addSubview(textView)
        view.addSubview(placeholderLbl)
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        view.addSubview(locationBtn)
        view.addSubview(publicBtn)
        view.addSubview(countTextLbl)
        subtitleLbl.text = UserAccount.account?.screen_name

    }
    //布局
    private func setFrameConstant(){
        navigationBar.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.left.right.equalTo(0)
            make.height.equalTo(64)
            make.top.equalTo(view)
        }
        titleView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(view.snp_top).offset(24)
            make.width.equalTo(180)
        }
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(titleView.snp_centerX)
            make.top.equalTo(titleView.snp_top)
        }
        subtitleLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(titleView.snp_centerX)
            make.top.equalTo(titleLbl.snp_bottom)
        }
        textView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(navigationBar.snp_bottom)
            make.left.right.equalTo(view)
            textViewHeightConstraint = make.height.equalTo(120).constraint
        }
        placeholderLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(textView.snp_top).offset(8)
            make.left.equalTo(textView.snp_left).offset(4)
            make.width.equalTo(150)
        }
        let _width = (UIScreen.mainScreen().bounds.size.width - 12) / 3
        collectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(textView.snp_bottom)
            make.left.equalTo(view.snp_left).offset(4)
            make.right.equalTo(view.snp_right).offset(-4)
            make.height.equalTo(_width*3)
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
        countTextLbl.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(toolbar.snp_top).offset(-9)
            make.right.equalTo(publicBtn.snp_left).offset(-10)
        }
    }
    //MARK: - 初始化组件
    //添加导航栏
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        let iamge = UIImage.imageWithColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.7))
        navBar.setBackgroundImage(iamge, forBarMetrics: .Default)
        navBar.barStyle = .Default

        let naviItem = UINavigationItem()
        naviItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftButton)
        naviItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButton)
        naviItem.rightBarButtonItem?.tintColor = UIColor.orangeColor()
        navBar.items = [naviItem]
        return navBar
    }()
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
    //图片
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.mainScreen().bounds.size.width - 12) / 3
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2

        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        clv.registerClass(SelectedPhotoCell.self, forCellWithReuseIdentifier: SelectedPhotoIdentifier)
        clv.backgroundColor = UIColor.whiteColor()
        clv.dataSource = self
        clv.delegate = self
        clv.alwaysBounceVertical = true
        return clv
    }()
    //提醒当前输入多少文字
    private lazy var countTextLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.grayColor()
        lbl.sizeToFit()
        return lbl
    }()
    //取消
    @objc private func cancelBtnClick(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - 发送微博
    @objc private func sendBtnClick(){
        //准备微博数据
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.showInfoWithStatus("正在发送中...")
        var status = textView.emoticonAttributedText()
        var image: UIImage?
        if alassetModels.count > 0{
            let cgImage = alassetModels.first!.alsseet!.defaultRepresentation().fullScreenImage().takeUnretainedValue()
            image = UIImage(CGImage: cgImage).imageWithScale(ScreenWidth)
            status = status == "" ? "分享图片" : status
        }
        NetworkTools.sharedInstance.sendStatus(status,image: image,visible: 0) { (data, error) -> () in
            SVProgressHUD.dismiss()
            SVProgressHUD.setDefaultMaskType(.Black)
            if error != nil{
                NJLog(error)
                SVProgressHUD.showErrorWithStatus("发送微博失败")
                return
            }
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                SVProgressHUD.showSuccessWithStatus("发送微博成功")
            })
        }
    }
    //MARK: - 打开图片库
    @objc private func pictureBtnClick(){
        presentViewController(UINavigationController(rootViewController: PhotoViewController(selectedAlassennt: alassetModels)), animated: true, completion: nil)
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
    //MARK: - 选好图片
    @objc private func selectedPhotoDown(notice: NSNotification){
        guard let models = notice.userInfo!["alassentModels"] as? [ALAssentModel] else{
            return
        }
        alassetModels = models
        let aModel = ALAssentModel(alsseet: nil)
        alassetModels.append(aModel)
        collectionView.reloadData()
        textViewDidChange(textView)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
//MARK: - UITextViewDelegate代理
extension ComposeViewController: UITextViewDelegate{
    //文本改变
    func textViewDidChange(textView: UITextView) {
        //注意: 如果输入的是表情则不会触发事件
        placeholderLbl.hidden = textView.hasText()
        rightButton.enabled = textView.hasText()
        if textView.hasText() ||  alassetModels.count > 0{
            rightButton.enabled = true
            rightButton.setBackgroundImage(R.image.common_button_big_orange, forState: .Normal)
            rightButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            let nsStr = NSString(string: textView.emoticonAttributedText())
            let len = nsStr.length
            countTextLbl.text = "\(len)"
            if len >= 140{
                countTextLbl.textColor = UIColor.orangeColor()
            }else{
                countTextLbl.textColor = UIColor.grayColor()
            }
            let height = textView.contentSize.height
            if len > 34{
                if height < 120{
                    textViewHeightConstraint?.updateOffset(120)
                }else{
                    textViewHeightConstraint?.updateOffset(height + 30)
                }
            }
        }else{
            rightButton.setBackgroundImage(R.image.tabbar_compose_below_button, forState: .Normal)
            rightButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
            textViewHeightConstraint?.updateOffset(120)
            countTextLbl.text = ""
        }
    }
    //即将拖拽
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        textView.resignFirstResponder()
    }
    //限制输出
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "" && range.length > 0{
            return true
        }
        let nsStr = NSString(string: textView.emoticonAttributedText())
        let len = nsStr.length
        if (len - range.length + NSString(string: text).length > MAX_TEXT_LENGTH) {
            SVProgressHUD.showInfoWithStatus("微博最多输入140字")
            return false
        }
        return true
    }
}
//MARK: - UICollectionViewDataSource
extension ComposeViewController: UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alassetModels.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SelectedPhotoIdentifier, forIndexPath: indexPath) as! SelectedPhotoCell
        if let assent = alassetModels[indexPath.item].alsseet{
            cell.alsseet = assent
            cell.isLast = false
        }else{
            cell.isLast = true
        }
        if let image = alassetModels[indexPath.item].takePhtoto{
            cell.image = image
        }
        cell.delegate = self
        return cell
    }
}
//MARK: - UICollectionViewDelegate
extension ComposeViewController: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SelectedPhotoCell
        if cell.isLast{
            pictureBtnClick()
        }
    }
}
extension ComposeViewController: SelectedPhotoCellDelegate{
    func deletePhoto(cell: SelectedPhotoCell) {
        let indexPath = collectionView.indexPathForCell(cell)
        alassetModels.removeAtIndex(indexPath!.item)
        if alassetModels.count == 1{
            alassetModels = [ALAssentModel]()
        }
        collectionView.reloadData()
    }
}