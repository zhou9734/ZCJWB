//
//  UIButton+Extension.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/4.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

extension UIButton{
    convenience init(imageName: String?, backgroundImage: String?) {
        self.init()
        if let name = imageName{
            setImage(UIImage(named: name), forState: .Normal)
            setImage(UIImage(named: name + "_highlighted" ), forState: .Highlighted)
        }
        if let bgName = backgroundImage{
            setBackgroundImage(UIImage(named: bgName), forState:
                .Normal)
            setBackgroundImage(UIImage(named: bgName + "_highlighted"), forState: .Highlighted)
        }
        //调整按钮尺寸
        sizeToFit()
    }


    // 导航栏返回按钮
    convenience init(backTarget: AnyObject?, action: Selector) {
        self.init()
        setTitle("返回", forState: .Normal)
        setImage(UIImage(named: "barbuttonicon_back"), forState: .Normal)
        contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        addTarget(self, action: action, forControlEvents: .TouchUpInside)
        sizeToFit()
    }
}
