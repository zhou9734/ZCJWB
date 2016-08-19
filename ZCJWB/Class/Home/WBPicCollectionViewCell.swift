//
//  WBPicCollectionViewCell.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/19.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

class WBPicCollectionViewCell: UICollectionViewCell {
    var url : NSURL?{
        didSet{
            imageView.sd_setImageWithURL(url)
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
        imageView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
    }
    private lazy var imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .ScaleAspectFill
        _imageView.clipsToBounds = true
        return _imageView
    }()
}
