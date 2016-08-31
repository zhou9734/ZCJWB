//
//  XMGProgressImageView.swift
//  ProgressView
//
//  Created by xiaomage on 15/12/8.
//  Copyright © 2015年 xiaomage. All rights reserved.
//

import UIKit

class ProgressImageView: UIImageView {
    /// 记录当前进度, 0.0~1.0
    var progress: CGFloat = 0.0{
        didSet{
            progressView.progress = progress
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
        addSubview(progressView)
        progressView.backgroundColor = UIColor.clearColor()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = bounds
    }
    // MARK: - 懒加载
    private lazy var progressView: ProgressView = ProgressView()
}
