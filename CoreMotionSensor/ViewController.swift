//
//  ViewController.swift
//  CoreMotionSensor
//
//  Created by Ruoxi Lu on 10/23/15.
//  Copyright © 2015 Ruoxi Lu. All rights reserved.
//

import UIKit
import CoreMotion
import Darwin


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var connectButton:UIButton?
    @IBOutlet weak var disconnectButton:UIButton?
    @IBOutlet weak var launchButton:UIButton!
    @IBOutlet weak var upButton:UIButton!
    @IBOutlet weak var downButton:UIButton!
    @IBOutlet weak var leftButton:UIButton!
    @IBOutlet weak var rightButton:UIButton!
    
    @IBOutlet weak var ipTextField:UITextField!
    @IBOutlet weak var portTextField:UITextField!
    
    
    @IBOutlet weak var yawLabel:UILabel!
    @IBOutlet weak var pitchLabel:UILabel!
    
    
    let motionManager: CMMotionManager = CMMotionManager()
    var inputStream: NSInputStream!
    var outputStream: NSOutputStream!
    
    var yawCurrent: Int!
    var pitchCurrent: Int!
    var rollCurrent: Int!
    
    var upPressed:    Int = 0
    var downPressed:  Int = 0
    var leftPressed:  Int = 0
    var rightPressed: Int = 0
    var launch:       Int = 0
    
    var connected:Bool = false

    let pi = M_PI

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ipTextField?.delegate = self
        portTextField?.delegate = self
        
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.gyroUpdateInterval = 0.1
        
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryZVertical, toQueue: NSOperationQueue.mainQueue()) {
            (motion: CMDeviceMotion?, _) in
            
            // Attitude -----------------------------------------------------------
            if let attitude: CMAttitude = motion?.attitude {

                self.rollCurrent = Int(attitude.roll * 180/self.pi)
                self.pitchCurrent = Int(attitude.pitch * 180/self.pi)
                self.yawCurrent = Int(attitude.yaw * 180/self.pi)
                self.yawLabel.text = "Yaw: " + String(self.yawCurrent)
                self.pitchLabel.text = "Picth: " + String(self.pitchCurrent)
                
                print(self.upPressed)
                
                if self.connected {
                    self.sendOrientationData()
                }

            
            }
        }
    }
    



//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        // Hide the keyboard
//        textField.resignFirstResponder()
//        return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//        self.ipTextField.text = textField.text
//    }
    
    @IBAction func buttonAction(sender:NSObject) {
        if sender == connectButton! {
            self.connected = true
            let ip:CFString = (self.ipTextField?.text)!
            let port:UInt32? = UInt32(self.portTextField!.text!)
            
            var readStream: Unmanaged<CFReadStream>?
            var writeStream: Unmanaged<CFWriteStream>?
            
            
            CFStreamCreatePairWithSocketToHost(nil, ip, port!, &readStream, &writeStream)
            
            self.inputStream = readStream!.takeRetainedValue()
            self.outputStream = writeStream!.takeRetainedValue()

            self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            

            
            self.inputStream.open()
            self.outputStream.open()
            

        }
        else if sender == launchButton {
            print("Button Action")
            launch = 1;
        }
        else if sender == upButton {
            print("up action")
            upPressed = 1;
        }
        else if sender == downButton {
            print("down action")
            downPressed = 1;
        }
        else if sender == leftButton {
            print("left action")
            leftPressed = 1;
        }
        else if sender == rightButton {
            print("right action")
            rightPressed = 1;
        }
        else if sender == disconnectButton {
            
            self.inputStream.close()

            self.outputStream.close()
            self.connected = false

            
        }
        else if sender == ipTextField {
            ipTextField?.resignFirstResponder()
        }
        else if sender == portTextField {
            portTextField?.resignFirstResponder()
        }
    }
    
    @IBAction func buttonReleased(sender:NSObject) {
        if sender == upButton {
            upPressed = 0;
        }
        else if sender == downButton {
            downPressed = 0;
        }
        else if sender == leftButton {
            leftPressed = 0;
        }
        else if sender == rightButton {
            rightPressed = 0;
        }
        else if sender == launchButton {
            launch = 0;
        }
    }
    
    
    func sendOrientationData(){
        // yaw, pitch
        
        let data:NSData = (String(self.launch) + "," + String(self.upPressed) + "," + String(self.downPressed) + "," + String(self.leftPressed) + "," + String(self.rightPressed) + "," + String(self.yawCurrent) + "," +  String(self.pitchCurrent) + ";").dataUsingEncoding(NSUTF8StringEncoding)!
        self.outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength:  data.length)

        
    }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }


}

