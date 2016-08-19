//
//  VisitorView.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/4.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
/*
protocol VisitorViewDelegate: NSObjectProtocol{
    func visitorViewRegisterBtnClick(visitorView: VisitorView)
    func visitorViewLoginBtnClick(visitorView: VisitorView)
}
*/

class VisitorView: UIView {

    @IBOutlet weak var rorationImageView: UIImageView!

    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var titleLbl: UILabel!

    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var loginBtn: UIButton!

//    weak var delegate: VisitorViewDelegate?

    func setupVisitorInfo(imageName: String?, title: String){
        titleLbl.text = title
        guard let ivName = imageName else{
            startAnimation()
            return
        }
        rorationImageView.hidden = true
        iconImageView.image = UIImage(named: ivName)
    }

    private func startAnimation(){
        //1.创建动画
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        //2.设置动画属性

        animation.toValue = 2 * M_PI
        animation.duration = 5.0
        animation.repeatCount = MAXFLOAT

        //注意:默认情况下只要视图消失,系统就会自动移除动画
        //只要设置removedOnCompletion属性,系统就不会移除动画
        animation.removedOnCompletion = false
        //3.将动画添加到layer上
        rorationImageView.layer.addAnimation(animation, forKey: nil)
    }

    class func visitorView() -> VisitorView{
        return NSBundle.mainBundle().loadNibNamed("VisitorView", owner: nil, options: nil).last as! VisitorView
    }
    /*
    @IBAction func registerBtnClick(sender: AnyObject) {
        delegate?.visitorViewRegisterBtnClick(self)
    }
    
    @IBAction func loginBtnClick(sender: AnyObject) {
        delegate?.visitorViewLoginBtnClick(self)
    }
    */
}
