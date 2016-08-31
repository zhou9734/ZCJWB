//
//  TitleButton.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/5.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class TitleButton: UIButton {

    //通过纯代码调用
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    //通过xib/storyboard调用
    required init?(coder aDecoder: NSCoder) {
        //系统对initWithCoder的默认实现是报一个致命错误
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI(){
        setImage(R.image.navigationbar_arrow_down, forState: .Normal)
        setImage(R.image.navigationbar_arrow_up, forState: .Selected)
        setTitleColor(UIColor.grayColor(), forState: .Normal)
        sizeToFit()

    }
    override func setTitle(title: String?, forState state: UIControlState) {
        super.setTitle((title ?? "") + "   ", forState: state)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        /*
        //offsetInPlace用于控制控件移位(有时候可能不对,系统肯能会调用多次layoutSubviews)
        titleLabel?.frame.offsetInPlace(dx: -imageView!.frame.width, dy: 0)
        imageView?.frame.offsetInPlace(dx: titleLabel!.frame.width, dy: 0)
        */
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.width
    }
}
