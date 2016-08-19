//
//  WBCollectionViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/19.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit

private let reuseIdentifier = "WBIdentifier"

class WBCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(WBPicCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
}
