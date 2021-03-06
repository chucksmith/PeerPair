//
//  ViewController.swift
//  PeerPair
//
//  Created by Chuck Smith on 05.12.19.
//  Copyright © 2019 Chuck Smith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logTextView: UITextView!

    var log = ""
    private let gameService = GameService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameService.delegate = self
        nameLabel.text = UIDevice.current.name
    }

    @IBAction func connectTapped(_ sender: Any) {
        if isOldDeviceNotOnWifi() {
            displayUnsupportedDialog()
            return
        }
        
        gameService.startSearchingForPlayers()
    }
    
    @IBAction func pingTapped(_ sender: Any) {
        gameService.ping()
    }
    
    @IBAction func disconnectTapped(_ sender: Any) {
        gameService.disconnect()
    }
    
    @IBAction func turtleTapped(_ sender: Any) {
        let link = URL(string: "https://wts.ludisto.com/")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(link)
        }
        else {
            UIApplication.shared.openURL(link)
        }
    }
    
    func updateView() {
        logTextView.text = log
        scrollToBottom()
    }
    
    func scrollToBottom() {
        let bottom = NSMakeRange(logTextView.text.count - 1, 1)
        logTextView.scrollRangeToVisible(bottom)
    }
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss.SSS"
        return formatter
    }()
    
    var timestampPrefix: String {
        return "\(currentTime): "
    }
    
    var currentTime: String {
        return formatter.string(from: Date())
    }
    
    func isOldDeviceNotOnWifi() -> Bool {
        if SYSTEM_VERSION_LESS_THAN(version: "12.0") {
            let reachability = try! Reachability()
        
            return reachability.connection != .wifi
        }
        
        return false
    }
    
    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedAscending
    }
    
    func displayUnsupportedDialog() {
        let alertController = UIAlertController(title: "Bluetooth not supported",
                                                message: "iOS 12 or later is needed to play over Bluetooth. Please connect to WiFi.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: GameServiceDelegate {
    func networkLog(_ logText: String) {
        log += "\(timestampPrefix)\(logText)\n"
        DispatchQueue.main.async {
            self.updateView()
        }
    }
}
