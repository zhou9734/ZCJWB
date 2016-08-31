//
//  ToolView.swift
//  Emotion
//
//  Created by zhoucj on 16/8/24.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

protocol ToolViewDelegate: NSObjectProtocol {
    func itemBtnClick(btn : UIButton)
}

class ToolView: UIView {
    var delegate: ToolViewDelegate?
    @IBAction func itemBtnClick(sender: UIButton) {
        delegate?.itemBtnClick(sender)
    }
    class func toolView() -> ToolView{
        return NSBundle.mainBundle().loadNibNamed("ToolView", owner: nil, options: nil).last as! ToolView
    }
}
