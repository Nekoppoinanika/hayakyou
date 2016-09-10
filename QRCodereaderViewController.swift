//
//  QRCodereaderViewController.swift
//  QRcode
//
//  Created by リボルバー　オセロット on 2016/08/05.
//  Copyright © 2016年 ocelot. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodereaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak private var preview: UIView!
    @IBOutlet weak var QRcodeview: UIView!
    @IBOutlet weak var sampleImageView1: UIImageView!
    @IBOutlet weak var sampleImageView2: UIImageView!
    
    var urlStr: String!
    
    var button = [UIButton]()
    private var myButton: UIButton!
    
    private let targetTypes = [AVMetadataObjectTypeQRCode]
    
    // キャプチャセッションを作成
    private let session = AVCaptureSession()
    // 専用のキューを作成
    private let sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // プレビュー用のレイヤーを作成
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.layer.addSublayer(layer)
        previewLayer = layer
        
        dispatch_async(sessionQueue) {
            // カメラの取得と設定
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).flatMap {
                ($0.position == .Back) ? $0 : nil
            }
            guard let device = devices.first as? AVCaptureDevice else {
                assertionFailure("Not Found Camera")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                self.session.addInput(input)
            } catch let error as NSError {
                assertionFailure(error.debugDescription)
                return
            }
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: dispatch_queue_create("meta queue", DISPATCH_QUEUE_SERIAL))
            self.session.addOutput(output)
            output.metadataObjectTypes = self.targetTypes
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // キャプチャセッションを開始
        dispatch_async(sessionQueue) {
            self.session.startRunning()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // プレビューのサイズを合わせる
        
        previewLayer.frame = QRcodeview.bounds
    }
    
    // MARK: -
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        typealias code = (value: String, rect: CGRect)
        button = []
        
        let items: [code] = metadataObjects.flatMap {
            guard let obj = $0 as? AVMetadataMachineReadableCodeObject where obj.stringValue != nil else { return nil }
            // ターゲットとするタイプのコードか確認
            guard let _ = targetTypes.indexOf(obj.type) else { return nil }
            
            // コードのタイプとデータを取得
            let value = (obj.type.componentsSeparatedByString(".").last ?? "") + "\n" + obj.stringValue
            urlStr = obj.stringValue
            let rect = previewLayer.transformedMetadataObjectForMetadataObject(obj).bounds
            let btn = UIButton()
            btn.frame = rect
            btn.addTarget(self, action: "Button:", forControlEvents: .TouchUpInside)
            print("value\(value)")
            return (value: value, rect: rect)
            
        }
        
        
        /*func viewDidLoad() {
         super.viewDidLoad()
         
         func onClickMyButton(sender: UIButton){
         let URLString = String()
         let URL = NSURL(string: URLString)
         UIApplication.sharedApplication().openURL(URL!)
         }
         }*/
        
        
        
        
        
        
        //let URL = NSURL(string: )
        //UIApplication.sharedApplication().openURL(URL!)
        
        // マーカーの追加
        dispatch_async(dispatch_get_main_queue()) {
            self.preview.subviews.forEach { $0.removeFromSuperview() }
            items.forEach {
                
                self.preview.userInteractionEnabled = true
                self.preview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "vPush"))
                
                
                //                self.myButton = UIButton()
                let v = UIButton(frame: $0.rect)
                //                v.addTarget(self, action: "vPush:", forControlEvents: .TouchUpInside)
                v.backgroundColor = UIColor.clearColor()
                v.layer.borderColor = UIColor.greenColor().CGColor
                v.layer.borderWidth = 2
                //                v.addTarget(self, action: "Button:", forControlEvents: .TouchUpInside)
                
                let lb = UILabel(frame: v.bounds)
                lb.numberOfLines = -1
                lb.adjustsFontSizeToFitWidth = true
                lb.text = $0.value
                lb.textAlignment = .Center
                lb.center = CGPoint(x: v.bounds.width / 2, y: v.bounds.height / 2)
                lb.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.3)
                lb.textColor = UIColor.yellowColor()
                v.addSubview(lb)
                print(lb.text)
                print("lb.text")
                self.preview.addSubview(v)
                
            }
            
        }
    }
    
    
    
    
    internal func Button(sender: UIButton){
        print("buttonTapped")
        let URLString = String()
        let URL = NSURL(string: URLString)
        UIApplication.sharedApplication().openURL(URL!)
    }
    
    internal func vPush(){
        print("buttonTappedvvvvvvvvvvvvv")
        print("ーーーーーーーーー")
        let URL = NSURL(string: urlStr)
        print("ーーーーーーーーー")
        print(URL)
        
        if URL == nil {
            
            
        }
            
        else{
            UIApplication.sharedApplication().openURL(URL!)
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
}