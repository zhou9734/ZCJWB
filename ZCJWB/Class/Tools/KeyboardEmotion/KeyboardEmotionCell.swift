//
//  EmotionCell.swift
//  Emotion
//
//  Created by zhoucj on 16/8/23.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class KeyboardEmotionCell: UICollectionViewCell {
    /// 当前行对应的表情模型
    var emoticon: KeyboardEmoticon?
        {
        didSet{
            // 1.显示emoji表情
            iconButton.setTitle(emoticon?.emoticonStr ?? "", forState: UIControlState.Normal)

            // 2.设置图片表情
            iconButton.setImage(nil, forState: UIControlState.Normal)
            if emoticon?.chs != nil{
                iconButton.setImage(UIImage(contentsOfFile: emoticon!.pngPath!), forState: .Normal)
            }
            // 3.设置删除按钮
            if emoticon!.isRemoveButton{
                iconButton.setImage(UIImage(named: "compose_emotion_delete"), forState: .Normal)
                iconButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: .Highlighted)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    // MARK: - 内部控制方法
    private func setupUI(){
        // 1.添加子控件
        contentView.addSubview(iconButton)
        // 2.布局子控件
        iconButton.frame = CGRectInset(bounds, 2,2)
    }
    // MARK: - 懒加载
    private lazy var iconButton: UIButton = {
        let btn = UIButton()
        btn.userInteractionEnabled = false
        btn.titleLabel?.font = UIFont.systemFontOfSize(30)
        return btn
    }()
}
