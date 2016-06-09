//
//  ViewController.swift
//  Discovery
//
//  Created by 会津慎弥 on 2016/06/09.
//  Copyright © 2016年 会津慎弥. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MSBClientManagerDelegate {
    
    var client: MSBClient?
    private var clientManager = MSBClientManager.sharedManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup Band
        clientManager.delegate = self
        if let band = clientManager.attachedClients().first as! MSBClient? {
            self.client = band
            clientManager.connectClient(client)
        } else {
            return
        }
        startHeartRateUpdates()
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
               /*     self.hrLabel.text = NSString(format: "Heart Rate: %3u %@",
                        heartRateData.heartRate,
                        heartRateData.quality == MSBSensorHeartRateQuality.Acquiring ? "Acquiring" : "Locked") as String*/
                    print(NSString(format: "Heart Rate: %3u %@",
                        heartRateData.heartRate,
                        heartRateData.quality == MSBSensorHeartRateQuality.Acquiring ? "Acquiring" : "Locked") as String)
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
        
    }
    
    func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        print(")Band <\(client.name)>disconnected.")
    }
    
    func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        print("Failed to connect to Band <\(client.name)>.")
        print(error.description)
    }
    
    
}

