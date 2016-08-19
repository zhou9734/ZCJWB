//
//  HomeTableViewCell.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/12.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import SDWebImage
class HomeTableViewCell: UITableViewCell {
    //图片容器的宽度约束
    var picCollectionViewWidthConstraint: Constraint?
    //图片容器的高度约束
    var picCollectionViewHeightConstraint: Constraint?

    let WBIdentifier = "WBIdentifier"
    var viewModel: StatusViewModel?{
        didSet{
            //设置头像
            iconImageView.sd_setImageWithURL(viewModel?.icon_URL)
            //设置认证
            verifiedImageView.image = viewModel?.verified_image
            //设置名称
            nameLbl.text = viewModel?.status.user?.screen_name
            nameLbl.textColor = UIColor.blackColor()
            vipImageView.image = UIImage.imageWithColor(UIColor.clearColor())
            if let image = viewModel!.mbrankImage {
                nameLbl.textColor = UIColor.orangeColor()
                //设置vip
                vipImageView.image = image
            }
            //设置时间
            timeLbl.text = viewModel?.created_Time
            //设置来源
            sourceLbl.text = viewModel!.source_Text
            //设置正文
            textLbl.text = viewModel?.status.text
            //TODO 显示图片
            picCollectionView.reloadData()
            let (itemSize, clSize) = calculateSize()
            //更新cell尺寸
            if itemSize != CGSizeZero{
                collectionlayout.itemSize = itemSize
            }
            //更新collectionView的尺寸
            picCollectionViewWidthConstraint?.updateOffset(clSize.width)
            picCollectionViewHeightConstraint?.updateOffset(clSize.height)
            if let retween_status = viewModel?.status.retweeted_status {
                let screen_name = retween_status.user?.screen_name ?? ""
                retweetedLbl.text = "@" + screen_name + ":" + (retween_status.text ?? "")
                retweetedView.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1)
            }else{
                retweetedView.backgroundColor = UIColor.whiteColor()
            }
            self.layoutIfNeeded()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupFrameCons()
        picCollectionView.registerClass(WBPicCollectionViewCell.self, forCellWithReuseIdentifier: WBIdentifier)
        picCollectionView.dataSource = self
        picCollectionView.delegate = self
    }

    override func awakeFromNib() {

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - 外部控制方法
    func calculateRowHeight(viewModel: StatusViewModel) -> CGFloat
    {
        self.viewModel = viewModel
        // 返回底部视图最大的Y
        return CGRectGetMaxY(btnContainerView.frame)

//        return _height
    }

    //MARK: - 内部方法
    // 这只UI
    private func setupUI(){
        //头像
        contentView.addSubview(iconImageView)
        contentView.addSubview(verifiedImageView)
        contentView.addSubview(nameLbl)
        contentView.addSubview(vipImageView)
        contentView.addSubview(timeLbl)
        contentView.addSubview(sourceLbl)
        //微博正文
        contentView.addSubview(textLbl)

        //转发微博
        contentView.addSubview(retweetedView)
        retweetedView.addSubview(retweetedLbl)
        //微博图片
        retweetedView.addSubview(picCollectionView)

        //底部按钮
        contentView.addSubview(btnContainerView)
        btnContainerView.addSubview(forwardBtn)
        btnContainerView.addSubview(commentBtn)
        btnContainerView.addSubview(likeBtn)
    }

    //设置组件约束
    private func setupFrameCons(){
        //头像
        iconImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        iconImageView.layer.cornerRadius = 30
        iconImageView.layer.masksToBounds = true
        verifiedImageView.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(18)
            make.right.equalTo(iconImageView.snp_right)
            make.bottom.equalTo(iconImageView.snp_bottom)
        }
        nameLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(iconImageView.snp_top)
            make.left.equalTo(iconImageView.snp_right).offset(10)
        }
        vipImageView.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(nameLbl.snp_centerY)
            make.left.equalTo(nameLbl.snp_right).offset(10)
            make.width.height.equalTo(20)
        }
        timeLbl.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(iconImageView.snp_bottom).offset(0)
            make.left.equalTo(iconImageView.snp_right).offset(10)
            make.height.equalTo(30)
        }
        timeLbl.textColor = UIColor.orangeColor()
        sourceLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(timeLbl.snp_right).offset(10)
            make.bottom.equalTo(timeLbl.snp_bottom)
            make.height.equalTo(30)
        }
        sourceLbl.textColor = UIColor.lightGrayColor()
        sourceLbl.font = UIFont.systemFontOfSize(15)

        //微博正文
        textLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(iconImageView.snp_left)
            make.top.equalTo(iconImageView.snp_bottom).offset(10)
            make.width.equalTo(ScreenWidth - 20)
        }
        //微博转发
        retweetedView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(textLbl.snp_bottom).offset(5)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
        }
        retweetedLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(retweetedView.snp_top).offset(5)
            make.left.equalTo(retweetedView.snp_left).offset(10)
            make.width.equalTo(ScreenWidth - 20)
        }
        //图片
        picCollectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(retweetedLbl.snp_bottom).offset(5)
            make.left.equalTo(retweetedView.snp_left).offset(10)
            make.bottom.equalTo(retweetedView.snp_bottom).offset(-2)
            picCollectionViewWidthConstraint = make.width.equalTo(290).constraint
            picCollectionViewHeightConstraint =  make.height.equalTo(290).constraint
        }

        //底部按钮容器
        btnContainerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(retweetedView.snp_bottom)
            make.left.right.equalTo(contentView)
            make.height.equalTo(44)
        }
        btnContainerView.backgroundColor = UIColor.grayColor()

        forwardBtn.snp_makeConstraints { (make) -> Void in
            make.left.top.bottom.equalTo(btnContainerView)
            make.width.equalTo(commentBtn.snp_width)
        }
        commentBtn.snp_makeConstraints { (make) -> Void in
            make.bottom.top.equalTo(btnContainerView)
            make.width.equalTo(likeBtn.snp_width)
            make.left.equalTo(forwardBtn.snp_right)
            make.right.equalTo(likeBtn.snp_left)
        }
        likeBtn.snp_makeConstraints { (make) -> Void in
            make.right.bottom.top.equalTo(btnContainerView)
        }
    }

    //计算cell高度和collectionView的尺寸
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
        let imageWidth = 90
        let imageHeight = 90
        let imageMargin = 10
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
    /// 图标
    private lazy var iconImageView = UIImageView()
    /// 认证
    private lazy var verifiedImageView = UIImageView()
    /// 昵称
    private lazy var nameLbl = UILabel()
    /// vip
    private lazy var vipImageView = UIImageView()
    /// 时间
    private lazy var timeLbl = UILabel()
    /// 来源
    private lazy var sourceLbl = UILabel()
    // 正文
    private lazy var textLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFontOfSize(16)
        return lbl
    }()
    /// 转发
    private lazy var retweetedView = UIView()
    /// 转发文字
    private lazy var retweetedLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFontOfSize(15)
        lbl.textColor = UIColor.grayColor()
        return lbl
    }()
    //微博图片
    //collection布局
    var collectionlayout = UICollectionViewFlowLayout()
    private lazy var picCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionlayout)
        collectionView.backgroundColor = UIColor.clearColor()
        return collectionView
    }()
    //底部按钮容器
    private lazy var btnContainerView = UIView()
    //转发
    private lazy var forwardBtn: UIButton = {
        let _btn = UIButton()
        _btn.setImage(R.image.timeline_icon_retweet, forState: .Normal)
        _btn.setBackgroundImage(R.image.timeline_card_bottom_background, forState: .Normal)
        _btn.sizeToFit()
        _btn.addTarget(self, action: Selector("forwardBtnClick"), forControlEvents: .TouchUpInside)
        _btn.setTitle("  转发", forState: .Normal)
        _btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        return _btn
    }()
    //评论
    private lazy var commentBtn: UIButton = {
        let _btn = UIButton()
        _btn.setImage(R.image.timeline_icon_comment, forState: .Normal)
        _btn.setBackgroundImage(R.image.timeline_card_bottom_background, forState: .Normal)
        _btn.sizeToFit()
        _btn.addTarget(self, action: Selector("commentBtnClick"), forControlEvents: .TouchUpInside)
        _btn.setTitle("  评论", forState: .Normal)
        _btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        return _btn
    }()
    //点赞
    private lazy var likeBtn: UIButton = {
        let _btn = UIButton()
        _btn.setImage(R.image.timeline_icon_unlike, forState: .Normal)
        _btn.setBackgroundImage(R.image.timeline_card_bottom_background, forState: .Normal)
        _btn.sizeToFit()
        _btn.addTarget(self, action: Selector("likeBtnClick"), forControlEvents: .TouchUpInside)
        _btn.setTitle("  点赞", forState: .Normal)
        _btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        return _btn
    }()

    //转发按钮点击事件
    @objc private func forwardBtnClick(){

    }
    //评论按钮点击事件
    @objc private func commentBtnClick(){

    }
    //点赞按钮点击事件
    @objc private func likeBtnClick(){

    }
}

extension HomeTableViewCell: UICollectionViewDataSource{

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
extension HomeTableViewCell: UICollectionViewDelegate{
    
}

