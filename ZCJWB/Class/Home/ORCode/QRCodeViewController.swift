//
//  QRCodeViewController.swift
//  ZCJWB
//
//  Created by zhoucj on 16/8/6.
//  Copyright © 2016年 zhoucj. All rights reserved.
//

import UIKit
import AVFoundation
import ZXingObjC

class QRCodeViewController: UIViewController {

    @IBOutlet weak var customContainerView: UIView!
    //容器视图
    @IBOutlet weak var contentView: UIView!
    //底部工具条
    @IBOutlet weak var tabBar: UITabBar!
    //容器高度约束
    @IBOutlet weak var contentHeightCons: NSLayoutConstraint!


    //冲击波顶部约束
    @IBOutlet weak var scanLineCons: NSLayoutConstraint!

    @IBOutlet weak var outputLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.selectedItem = self.tabBar.items?.first
        //添加tabBar监听
        tabBar.delegate = self
        setupNav()
        //开始扫描二维码
        startScanQRCode()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startScanAnimate()
    }

    //关闭
    @IBAction func closeBtnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    //打开相册
    @IBAction func photoBtnClick(sender: AnyObject) {
        //判断能否打开相册
        if !UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            return
        }
        //创建图片控制器
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        //打开相册控制器
        presentViewController(pickerController, animated: true, completion: nil)
    }

    //我的名片
    @IBAction func myCardClick(sender: AnyObject) {
        navigationController?.pushViewController(QRCodeCreateViewController(), animated: true)
    }

    private func setupNav(){
        let gradientImage44 = UIImage.imageWithColor(UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 0.2))
        // customize the appearance of UINavigationBar
        navigationController?.navigationBar.setBackgroundImage(gradientImage44, forBarMetrics: .Default)
        navigationController?.navigationBar.barStyle = .Default
    }

    private func startScanQRCode(){
        //判断输入对象能否添加到会话中
        if !session.canAddInput(input){
            return
        }
        //判断输出对象能否添加到会话中
        if !session.canAddOutput(output){
            return
        }
        //添加输入对象
        session.addInput(input)
        //添加输出对象
        session.addOutput(output)
        //设置输出能够解析的数据类型
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        //设置监听输出解析到的数据
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        //添加预览图层
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        previewLayer.frame = view.bounds
        //添加容器图层
        view.layer.addSublayer(containerLayer)
        containerLayer.frame = view.bounds
        //开始扫描
        session.startRunning()
    }

    private func startScanAnimate(){
        //设置冲击底部与容器顶部对其
        scanLineCons.constant = -contentHeightCons.constant
        //强制刷新
        view.layoutIfNeeded()

        UIView.animateWithDuration(2.0) { () -> Void in
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.scanLineCons.constant = self.contentHeightCons.constant
            self.view.layoutIfNeeded()
        }
    }
    //MARK: - 懒加载
    //输入对象
    private lazy var input: AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        return try? AVCaptureDeviceInput(device: device)
    }()

    //会话
    private lazy var session: AVCaptureSession = AVCaptureSession()

    //输出对象
    private lazy var output: AVCaptureMetadataOutput = {
        let out = AVCaptureMetadataOutput()
        //设置输出对象感兴趣的范围
        //默认范围是CGRectMake(0, 0, 1, 1) 这个设置的是比例
        //注意:参照物是已横屏的左上角而不是竖屏的左上角
//        out.rectOfInterest = CGRectMake(0, 0, 1, 1)
        let viewRect = self.view.frame
        let containerRect = self.customContainerView.frame
        let x = containerRect.origin.y / viewRect.height
        let y = containerRect.origin.x / viewRect.width
        let width = containerRect.height / viewRect.height
        let height = containerRect.width / viewRect.width
        out.rectOfInterest = CGRectMake(x, y, width, height)
        return out
    }()

    //预览图层
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)

    //二维码边框容器图层
    private lazy var containerLayer: CALayer = CALayer()
}
extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate{
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        outputLbl.text = metadataObjects.last?.stringValue
        clearContainerLayer()
        guard let metadata = metadataObjects.last as? AVMetadataObject else{
            return
        }
        // bounds { 0.2,0.7 0.1x0.1 }, corners { 0.3,0.9 0.3,0.9 0.3,0.7 0.2,0.7 }
        //bounds是把扫描到的二维码圈在里面,corners是二维码的真正边框
        let obj = previewLayer.transformedMetadataObjectForMetadataObject(metadata)
//        NJLog((obj as! AVMetadataMachineReadableCodeObject).corners)
        guard let _data = (obj as? AVMetadataMachineReadableCodeObject) else{
            return
        }
        drawLines(_data)
    }

    private func drawLines(objc: AVMetadataMachineReadableCodeObject){
        //安全校验
        guard let pointArray = objc.corners else {
            return
        }
        //创建图层
        let layer = CAShapeLayer()
        layer.lineWidth = 2
        layer.strokeColor = UIColor.orangeColor().CGColor
        layer.fillColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 241.0/255.0, alpha: 1).CGColor
        //创建UIBeziePath,回执矩形
        let path = UIBezierPath()
        var point = CGPointZero
        var index = 0
        CGPointMakeWithDictionaryRepresentation((pointArray[index++] as! CFDictionary),
            &point)
        //将其点移动连接某个点
        path.moveToPoint(point)
        //连接其他线段
        while index < pointArray.count {
            CGPointMakeWithDictionaryRepresentation((pointArray[index++] as! CFDictionary), &point)
            path.addLineToPoint(point)
        }
        path.closePath()

        layer.path = path.CGPath
        //把图层添加到界面上
        containerLayer.addSublayer(layer)
    }

    private func clearContainerLayer(){
        guard let layers = containerLayer.sublayers else{
            return
        }
        for layer in layers{
            layer.removeFromSuperlayer()
        }
    }
}

extension QRCodeViewController: UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        contentHeightCons.constant = (item.tag == 1) ? 100 : 200
        view.layoutIfNeeded()

        //移除所有动画
        contentView.layer.removeAllAnimations()
        //重新开启动画
        startScanAnimate()
    }
}

extension QRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //1.取出选中的图片
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            return
        }
        /*
        SDK自带支持iOS8.0以上
        //2.从图片中读取二维码
        //2.1 创建一个探测器
        guard let ciImage = CIImage(image: image) else{
            return
        }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])
        //2.2 利用探测器探测数据
        let results = detector.featuresInImage(ciImage)
        //2.3 取出探测到的数据
        for result in results {
            let value = (result as! CIQRCodeFeature).messageString
            alert(value)
        }
        */

        //第三方库ZXingObjC(https://github.com/TheLevelUp/ZXingObjC)进行识别
        let source = ZXCGImageLuminanceSource(CGImage: image.CGImage)
        let bitmap = ZXBinaryBitmap.binaryBitmapWithBinarizer(ZXHybridBinarizer.binarizerWithSource(source) as! ZXBinarizer) as! ZXBinaryBitmap

        do{
            let reader = ZXMultiFormatReader()
            let result = try reader.decode(bitmap, hints: ZXDecodeHints())
            guard let contents = result.text else{
                alert("解析失败!")
                return
            }
            alert(contents)
        }catch let error as NSError {
            NJLog(error)
        }

        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
