//
//  UIImage+Extension.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/8.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

extension UIImage{
    class func imageWithColor(colour: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        colour.setFill()
        UIRectFill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
