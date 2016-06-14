//
//  ViewController.swift
//  Discovery
//
//  Created by 会津慎弥 on 2016/06/09.
//  Copyright © 2016年 会津慎弥. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, MSBClientManagerDelegate,AVAudioPlayerDelegate  {
    var timer: NSTimer!
    var sampleView: UIView!
    private var label: UILabel!
    let img:UIImage = UIImage(named:"heart.png")!
    var im:UIImageView! = nil
    let backimg:UIImage = UIImage(named:"loom.jpg")!
    var backim:UIImageView! = nil
    var scale:CGFloat = 1.0
    var width:CGFloat = 0
    var height:CGFloat = 0
    var scale2:CGFloat = 1.0
    var width2:CGFloat = 0
    var height2:CGFloat = 0
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0
     var heart:CGFloat = 0
    var rate:UInt = 0
    
    var client: MSBClient?
    private var clientManager = MSBClientManager.sharedManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        width = img.size.width
        height = img.size.height
        width2 = img.size.width
        height2 = img.size.height
        screenWidth = self.view.bounds.width
        screenHeight = self.view.bounds.height
        
        scale = screenWidth / width
        scale2 = screenWidth / width2
        
        im = UIImageView(image:img)
        backim = UIImageView(image:backimg)
        let rect:CGRect = CGRectMake(0, 0,width*scale/2, height*scale/2)
        im!.frame = rect;
        let rect2:CGRect = CGRectMake(0, 0, width2*scale, height2*scale)
        backim!.frame = rect2;
        
        im!.center = CGPointMake(187.5, 333.5)
        
        backim!.center = CGPointMake(187.5, 333.5)
        
        
        self.view.addSubview(backim);
        self.view.addSubview(im!);
        
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("update:"), userInfo: nil, repeats: true)
            timer.fire()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup Band
        clientManager.delegate = self
        if let band = clientManager.attachedClients().first as! MSBClient? {
            self.client = band
            clientManager.connectClient(client)
            print("Please wait. Connecting to Band <\(client!.name)>")
        } else {
            print("Failed! No Bands attached.")
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startHeartRateUpdates() {
        print("Starting Heart Rate updates...")
        if let client = self.client {
            do {
                try client.sensorManager.startHeartRateUpdatesToQueue(nil, withHandler: { (heartRateData: MSBSensorHeartRateData!, error: NSError!) in
                    
                    print(NSString(format: "Heart Rate: %3u %@",
                        heartRateData.heartRate,
                        heartRateData.quality == MSBSensorHeartRateQuality.Acquiring ? "Acquiring" : "Locked") as String)
                    
                    self.rate =  heartRateData.heartRate
                    
                    if self.timer == nil {
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("update:"), userInfo: nil, repeats: true)
                        self.timer.fire()
                    }
                  
        
                
                    
                })
                
            } catch let error as NSError {
                print("startHeartRateUpdatesToQueue failed: \(error.description)")
            }
        } else {
            print("Client not connected, can not start heart rate updates")
        }
    }
    
    func stopHeartRateUpdates() {
        if let client = self.client {
            do {
                try client.sensorManager.stopHeartRateUpdatesErrorRef()
            } catch let error as NSError {
                print("stopHeartRateUpdatesErrorRef failed: \(error.description)")
            }
            print("Heart Rate updates stopped...")
        }
    }
    
    // MARK - MSBClientManagerDelegate
    func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        print("Band <\(client.name)>connected.")
        
        if let client = self.client {
            if client.sensorManager.heartRateUserConsent() == MSBUserConsent.Granted {
                startHeartRateUpdates()
            } else {
                print("Requesting user consent for accessing HeartRate...")
                client.sensorManager.requestHRUserConsentWithCompletion( { (userConsent: Bool, error: NSError!) -> Void in
                    if userConsent {
                        self.startHeartRateUpdates()
                    } else {
                        print("User consent declined.")
                    }
                })
            }
        }
        
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        print(")Band <\(client.name)>disconnected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        print("Failed to connect to Band <\(client.name)>.")
        print(error.description)
    }
    
    
    func playsound(){
        var soundIdRing:SystemSoundID = 0
        let soundUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("buzzer", ofType:"mp3")!)
        AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
    }
    
    
    func background(){
        
        
        self.view.backgroundColor = UIColor.redColor()
        
        let backimg2:UIImage = UIImage(named:"jail.jpg")!
        var backim2:UIImageView! = nil
        var scale3:CGFloat = 1.0
        var width3:CGFloat = 0
        var height3:CGFloat = 0
        scale3 = screenWidth / width3
        backim2 = UIImageView(image:backimg2)
        let rect3:CGRect = CGRectMake(0, 0, width2*scale, height2*scale)
        backim2.frame = rect3;
        backim2!.center = CGPointMake(187.5, 333.5)
        
        self.view.addSubview(backim2);
        
        playsound()
        
        
    }
  
 
    func update(timer: NSTimer) {
        if(rate<65){
            heart=0.008
        }
        if(rate>=65&&rate<80){
            heart=0.01
        }
        if(rate>=80){
            heart=0.4
        }
        
        im.alpha = im.alpha - heart
        if (im.alpha < 0) {
            im.alpha = 1.0
        }
    }
}


