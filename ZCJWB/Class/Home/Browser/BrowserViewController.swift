//
//  BrowserViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/19.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SVProgressHUD
let CloseWBPic = "CloseWBPic"
class BrowserViewController: UIViewController {
    private var bmiddle_urls: [NSURL]
    private var index: NSIndexPath
    private let BrowserReuseIdentifier = "BrowserReuseIdentifier"
    var _currentImageIndex: Int = -1
    init(bmiddle_urls: [NSURL], indexPath: NSIndexPath){
        self.bmiddle_urls = bmiddle_urls
        self.index = indexPath
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.frame = self.view.frame
        //转到点击到的图片
        collectionView.scrollToItemAtIndexPath(index, atScrollPosition: .Left, animated: true)
        countLbl.text =  "\(index.item + 1)" + "/" + "\(bmiddle_urls.count)"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("closeVC"), name: CloseWBPic, object: nil)
        view.addSubview(countLbl)
        view.addSubview(moreBtn)
        countLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(view.snp_top).offset(10)
            make.width.equalTo(80)
        }
        moreBtn.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp_top).offset(10)
            make.right.equalTo(view.snp_right).offset(-15)
        }
    }
    //关闭视图
    @objc private func closeVC(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    //图片浏览
    lazy var collectionView: UICollectionView = {
        let _collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: BrowserPhotoFlowLayout())
        _collectionView.registerClass(BrowserPhotoCell.self, forCellWithReuseIdentifier: self.BrowserReuseIdentifier)
        _collectionView.dataSource = self
        _collectionView.delegate = self
        _collectionView.backgroundColor = UIColor(white: 0.1, alpha: 0)
        return _collectionView
    }()

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private lazy var countLbl: UILabel  = {
        let lbl = UILabel()
        lbl.text = "0/0"
        lbl.textColor = UIColor.whiteColor()
        lbl.textAlignment = .Center
        lbl.font = UIFont.systemFontOfSize(20)
        lbl.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
        lbl.bounds = CGRectMake(0, 0, 100, 40)
        lbl.layer.cornerRadius = 15
        lbl.clipsToBounds = true
        return lbl
    }()

    private lazy var moreBtn: UIButton = {
        let btn = UIButton()
//        btn.setImage(R.image.barbuttonicon_more, forState: .Normal)
        btn.addTarget(self, action: Selector("moreBtnClick"), forControlEvents: .TouchUpInside)
        btn.sizeToFit()
        return btn
    }()

    @objc private func moreBtnClick(){
        let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheet.tag = 2
        actionSheet.addButtonWithTitle("保存图片")
        actionSheet.addButtonWithTitle("转发微博")
        actionSheet.addButtonWithTitle("赞")
        actionSheet.addButtonWithTitle("取消")
        actionSheet.cancelButtonIndex = 3
        actionSheet.delegate = self
        actionSheet.showInView(self.view)

    }
}
//MARK: - UICollectionViewDataSource代理
extension BrowserViewController: UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bmiddle_urls.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BrowserReuseIdentifier, forIndexPath: indexPath) as! BrowserPhotoCell
        cell.imageUrl = bmiddle_urls[indexPath.item]
        cell.delegate = self
        return cell
    }
}
//MARK: - UICollectionViewDelegate代理
extension BrowserViewController: UICollectionViewDelegate{

    func scrollViewDidScroll(scrollView: UIScrollView) {
        _currentImageIndex = Int((scrollView.contentOffset.x + scrollView.bounds.size.width) / scrollView.bounds.size.width)
        countLbl.text =  "\(_currentImageIndex)" + "/" + "\(bmiddle_urls.count)"
    }
}
//MARK: - 自定义布局
class BrowserPhotoFlowLayout: UICollectionViewFlowLayout{
    override func prepareLayout() {
        //设置每个cell尺寸
        itemSize = UIScreen.mainScreen().bounds.size
        // 最小的行距
        minimumLineSpacing = 0
        // 最小的列距
        minimumInteritemSpacing = 0
        // collectionView的滚动方向
        scrollDirection =  .Horizontal // default .Vertical
        //设置分页
        collectionView?.pagingEnabled = true
        //禁用回弹
        collectionView?.bounces = false
        //去除滚动条
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
    }
}
//MARK: - BrowserDelegate代理
extension BrowserViewController: BrowserDelegate{
    func showActionSheetMenu() {
        moreBtnClick()
    }
}
//MARK: - UIActionSheetDelegate代理
extension BrowserViewController: UIActionSheetDelegate{
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            //保存图片
            savePicture()
        case 1:
            print("转发微博")
            //TODO
        case 2:
            //TODO
            print("赞")
        case 3:
            //取消
            print("取消")
        default:
            print("default")
        }
    }
    private func savePicture(){
        // 1.获取当前显示图片的索引
        let indexPath = collectionView.indexPathsForVisibleItems().last!
        // 2.获取当前显示的cell
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! BrowserPhotoCell
        // 3.获取当前显示的图片
        let image = cell.imageView.image!
        // 4.保存图片
        // - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
        UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }

    @objc private func image(image:UIImage, didFinishSavingWithError:NSError?, contextInfo: AnyObject?){
        SVProgressHUD.setDefaultMaskType(.Black)
        if didFinishSavingWithError != nil{
            SVProgressHUD.showErrorWithStatus("保存图片失败")
            return
        }
        SVProgressHUD.showSuccessWithStatus("保存图片成功")
    }
}