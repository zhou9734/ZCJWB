//
//  NewFeatureViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/11.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class NewFeatureViewController: UIViewController {

    private var picCounts = 4
    private let identifier = "NewFeatureCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI(){
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view.snp_center)
            make.edges.equalTo(0)
        }
        //使用代码布局必须手动注册Cell,若使用的是nib必须注册nib
        collectionView.registerClass(ZCJCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
    }

    private lazy var collectionView: UICollectionView = {
        let layout = ZCJCollectionViewFlowLayout()
        //在初始化UICollectionView的时候必须指定它的布局,(这里的frame貌似没有什么用处,必须重新指定SIze)
        let _collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)

        return _collectionView
    }()
}

extension NewFeatureViewController: UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picCounts
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! ZCJCollectionViewCell
        cell.index = indexPath.item
        return cell
    }
}

extension NewFeatureViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //注意: 传入的cell和indexPath都是上一页的,不是当前页的

        //手动获取当前显示的cell对应的index
        let index = collectionView.indexPathsForVisibleItems().last!
        //根据指定的index获取当前显示的cell
        let currentCell = collectionView.cellForItemAtIndexPath(index) as! ZCJCollectionViewCell
        if index.item == (picCounts - 1){
            currentCell.startAnimation()
        }
    }
}

//MARK: - 自定义collectionView布局
class ZCJCollectionViewFlowLayout: UICollectionViewFlowLayout  {
    override func prepareLayout() {
        super.prepareLayout()
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

//MAKE: - 自定义Cell
class ZCJCollectionViewCell: UICollectionViewCell{

    var index: Int = 0 {
        didSet{
            //生成图片名称
            let name = "new_feature_\(index + 1)"
            iconView.image = UIImage(named: name)
            startBtn.hidden = true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - 外部调用方法
    func startAnimation(){
        startBtn.hidden = false
        startBtn.transform = CGAffineTransformMakeScale(0, 0)
        startBtn.userInteractionEnabled = false
        UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.startBtn.transform = CGAffineTransformIdentity
            }, completion: { (_) -> Void in
                self.startBtn.userInteractionEnabled = true
        })
    }


    private func setupUI(){
        //添加子控件
        contentView.addSubview(iconView)
        contentView.addSubview(startBtn)
        //布局
        iconView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(contentView.snp_center)
            make.edges.equalTo(0)
        }
        startBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(contentView.snp_bottom).offset(-160)
        }
    }
    //图片
    private lazy var iconView = UIImageView()

    //按钮
    private lazy var startBtn: UIButton = {
        let btn = UIButton(imageName: nil, backgroundImage: "new_feature_button")
        btn.addTarget(self, action: Selector("startBtnClick"), forControlEvents: .TouchUpInside)
        return btn
    }()

    @objc private func startBtnClick(){
        //跳转到主页面
        NSNotificationCenter.defaultCenter().postNotificationName(SwitchRootViewController, object: true)
    }
}
