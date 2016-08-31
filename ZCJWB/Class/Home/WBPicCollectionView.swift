//
//  WBPicCollectionView.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/19.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SDWebImage

class WBPicCollectionView: UICollectionView {
    let WBIdentifier = "WBIdentifier"
    //图片容器的宽度约束
    var picCollectionViewWidthConstraint: Constraint?
    //图片容器的高度约束
    var picCollectionViewHeightConstraint: Constraint?
    //collection布局
    var collectionlayout = UICollectionViewFlowLayout()

    var viewModel: StatusViewModel?{
        didSet{
            //TODO 显示图片
            reloadData()
            let (itemSize, clSize) = calculateSize()
            //更新cell尺寸
            if itemSize != CGSizeZero{
                collectionlayout.itemSize = itemSize
            }
            //更新collectionView的尺寸
            picCollectionViewWidthConstraint?.updateOffset(clSize.width)
            picCollectionViewHeightConstraint?.updateOffset(clSize.height)
            layoutIfNeeded()
        }
    }
    
    init(){
        collectionlayout.minimumLineSpacing = 3
        collectionlayout.minimumInteritemSpacing = 3
        super.init(frame: CGRectZero, collectionViewLayout: collectionlayout)
        registerClass(WBPicCollectionViewCell.self, forCellWithReuseIdentifier: WBIdentifier)
        dataSource = self
        delegate = self
        self.snp_makeConstraints { (make) -> Void in
            picCollectionViewWidthConstraint = make.width.equalTo(290).constraint
            picCollectionViewHeightConstraint =  make.height.equalTo(290).constraint
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - 计算cell高度和collectionView的尺寸
    private func calculateSize() -> (CGSize, CGSize){
        /*
        没有配图: cell = CGSizeZero,  collectionView = CGSizeZero
        一张图片: cell = image.size,  collectionView = image.size
        四张配图: cell = (90,90), collectionView = 2*x + 10, 2*y + 10
        其他张: cell = (90,90)), collectionView = 2*x + 10, 2*y + 10
        */
        let count = viewModel?.thumbpics?.count ?? 0
        if count == 0 {
            return (CGSizeZero, CGSizeZero)
        }
        //一张图片
        if count == 1 {
            //从缓存中获取已经下载好的图片,其中key等于图片的url
            let key = viewModel!.thumbpics!.first!.absoluteString
            let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key)
            return (image.size, image.size)
        }
        let imageMargin = 3
        let imageWidth = Int((ScreenWidth - 26)/3)
        let imageHeight = imageWidth
        //四张图片
        if count == 4 {
            let col = 2   //列
            let row = col //行
            //宽度 = 图片的宽度 * 列数 + (列数 - 1 ) * 间隙
            //高度 = 图片的高度 * 行书 + (行数 - 1 ) * 间隙
            let _width = imageWidth * col + (col - 1 ) * imageMargin

            let _height = imageHeight * row + (row - 1) * imageMargin
            return (CGSize(width: imageWidth, height: imageHeight), CGSize(width: _width, height: _height))
        }
        //其他张图片
        let col = 3
        let row = (count - 1)/3 + 1
        let _width = imageWidth * col + (col - 1 ) * imageMargin
        let _height = imageHeight * row + (row - 1) * imageMargin
        return (CGSize(width: imageWidth, height: imageHeight), CGSize(width: _width, height: _height))
    }

}
//MARK: - UICollectionViewDataSource代理
extension WBPicCollectionView: UICollectionViewDataSource{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView:UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.thumbpics?.count ?? 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(WBIdentifier, forIndexPath: indexPath) as! WBPicCollectionViewCell
        cell.url = viewModel!.thumbpics![indexPath.item]
        return cell
    }
}
//MARK: - UICollectionViewDelegate代理
extension WBPicCollectionView: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! WBPicCollectionViewCell
        //用collectionView转换cell的位置
        let cellRect = collectionView.convertRect(cell.frame, toView: nil)
        //获取点击的图片的url
        let url = viewModel!.bmiddle_urls![indexPath.item]
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: { (current, total) -> Void in
                cell.imageView.progress = CGFloat(current)/CGFloat(total)
            }) { (_, error, _, _, _) -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(BrowserPicViewController, object: self, userInfo: ["bmiddle_urls": self.viewModel!.bmiddle_urls! ,
                    "indexPath" : indexPath, "originFrame" : NSStringFromCGRect(cellRect), "wbPicClv": collectionView] )
        }


    }
}

class WBPicCollectionViewCell: UICollectionViewCell {
    var url : NSURL?{
        didSet{
            imageView.sd_setImageWithURL(url)
            //设置显示隐藏gif图标
            if let flag = url?.absoluteString.lowercaseString.hasSuffix("gif") {
                gifImageView.hidden = !flag
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        contentView.addSubview(imageView)
        contentView.addSubview(gifImageView)
    }
    override func layoutSubviews() {
        imageView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
        gifImageView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(imageView.snp_bottom)
            make.right.equalTo(imageView.snp_right)
        }
    }
    lazy var imageView: ProgressImageView = {
        let _imageView = ProgressImageView(frame: CGRectZero)
        _imageView.contentMode = .ScaleAspectFill
        _imageView.clipsToBounds = true
        return _imageView
    }()
    private lazy var gifImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.common_feed_image_gif
        imageView.sizeToFit()
        return imageView
    }()
}
