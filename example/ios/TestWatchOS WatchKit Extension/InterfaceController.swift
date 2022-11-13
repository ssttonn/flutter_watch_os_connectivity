//
//  InterfaceController.swift
//  TestWatchOS WatchKit Extension
//
//  Created by sstonn on 01/10/2022.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
   
    @IBOutlet weak var image: WKInterfaceImage!
    var watchSession: WCSession?
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    @IBOutlet weak var contextLabel: WKInterfaceLabel!
    
    @IBOutlet weak var userInfoLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        watchSession = WCSession.default
        watchSession?.delegate = self
        watchSession?.activate()
    }
    @IBOutlet weak var replyLabel: WKInterfaceLabel!
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func sendMessagePressed() {
        self.watchSession?.sendMessage(["message": "This is a message send from WatchOS app at \(Date().timeIntervalSince1970)"]){replyMessage in
            if let message = replyMessage["message"] as? String{
                self.replyLabel.setText(message)
            }
           
        }
    }
    
    
    @IBAction func updateApplicationContextPressed() {
        do{
            try self.watchSession?.updateApplicationContext(["message": "Application context updated by WatchOS app at \(Date().timeIntervalSince1970)"])
        }catch{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func transferUserInfoPressed() {
        watchSession!.transferUserInfo(["message": "User info sended by WatchOS app at \(Date().timeIntervalSince1970)"])
    }
    
    @IBAction func transferImagePressed() {
        guard let path = Bundle.main.path(forResource: "sampleimage", ofType: "jpg") else{
            return
        }
        let fileUrl = URL(fileURLWithPath: path)
        self.watchSession?.transferFile(fileUrl, metadata: ["message": "This is an image send from WatchOS at \(Date().timeIntervalSince1970)"])
    }
}

extension InterfaceController: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["message"] as? String{
            self.messageLabel.setText(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let message = message["message"] as? String{
            self.messageLabel.setText(message)
        }
        replyHandler(["message": "Message received on WatchOS at \(Date().timeIntervalSince1970)"])
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let message = applicationContext["message"] as? String{
            self.contextLabel.setText(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let message = userInfo["message"] as? String{
            self.userInfoLabel.setText(message)
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
//        try! watchSession?.updateApplicationContext(fileTransfer.file.metadata!)
       
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
        tempURL.appendPathComponent(file.fileURL.lastPathComponent)
        do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(atPath: tempURL.path)
            }
            try FileManager.default.moveItem(atPath: file.fileURL.path, toPath: tempURL.path)
            if let data = try? Data(contentsOf: tempURL){
                image.setImage(UIImage(data: data))
            }
        } catch {
            
        }
    }
    
}
