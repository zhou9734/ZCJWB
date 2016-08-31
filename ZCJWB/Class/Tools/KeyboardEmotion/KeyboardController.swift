//
//  KeyboardController.swift
//  Emotion
//
//  Created by zhoucj on 16/8/23.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
let EmotionIdentifier = "EmotionIdentifier"
class KeyboardController: UIViewController {
    /// 保存所有组数据
    var packages: [KeyboardModel] = KeyboardModel.packageList
    var toolView: ToolView = ToolView.toolView()
    /// 定义一个闭包属性, 用于传递选中的表情模型
    var emoticonDidSelectedCallBack: (emoticon: KeyboardEmoticon)->()
    init(callBack: (emoticon: KeyboardEmoticon)->()){
        self.emoticonDidSelectedCallBack = callBack
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        toolView.delegate = self
        super.viewDidLoad()
        view.addSubview(emotionClv)
        view.addSubview(toolView)
        emotionClv.translatesAutoresizingMaskIntoConstraints = false
        toolView.translatesAutoresizingMaskIntoConstraints = false

        // 2.布局子控件
        let dict = ["emotionClv": emotionClv, "toolView": toolView]
        var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[emotionClv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[emotionClv]-0-[toolView(40)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    private lazy var emotionClv: UICollectionView = {
        let clv = UICollectionView(frame: CGRectZero, collectionViewLayout: EmotionLayout())
        clv.registerClass(KeyboardEmotionCell.self, forCellWithReuseIdentifier: EmotionIdentifier)
        clv.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1)
        clv.dataSource = self
        clv.delegate = self
        return clv
    }()
}
extension KeyboardController: UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return packages.count
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 1.取出cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EmotionIdentifier, forIndexPath: indexPath) as! KeyboardEmotionCell
        // 2.设置数据
        cell.emoticon = packages[indexPath.section].emoticons![indexPath.item]

        return cell
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        let indexPath = emotionClv.indexPathsForVisibleItems().first!
        switchSelectBtn(indexPath.section)

    }
}
extension KeyboardController: UICollectionViewDelegate{
    /// 监听表情点击
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let package = packages[indexPath.section]
        let emoticon = package.emoticons![indexPath.item]
        // 每使用一次就+1
        emoticon.count += 1
        // 判断是否是删除按钮
        if !emoticon.isRemoveButton{
            // 将当前点击的表情添加到最近组中
            packages[0].addFavoriteEmoticon(emoticon)
        }
        emoticonDidSelectedCallBack(emoticon: emoticon)
    }
}
class EmotionLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        let width = UIScreen.mainScreen().bounds.size.width / 7
        let height = collectionView!.frame.size.height / 3
        //设置每个cell尺寸
        itemSize = CGSize(width: width, height: height)
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
        //设置间隙
        let offsetY = (collectionView!.frame.height -  height*3)*0.5
        collectionView?.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
    }
}
extension KeyboardController: ToolViewDelegate{
    func itemBtnClick(btn: UIButton) {
        // 1.创建indexPath
        let indexPath = NSIndexPath(forItem: 0, inSection: btn.tag)
        // 2.滚动到指定的indexPath
        emotionClv.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
        switchSelectBtn(btn.tag)
    }
    //切换按钮选中
    private func switchSelectBtn(section: Int){
        let items = toolView.subviews
        for item in items {
            if !item.isKindOfClass(UIButton){
                continue
            }
            let btn = item as? UIButton
            if btn?.tag ==  section{
                btn?.backgroundColor = UIColor.lightGrayColor()
                btn?.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)

            }else{
                btn?.backgroundColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1)
                btn?.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            }
        }
    }
}
