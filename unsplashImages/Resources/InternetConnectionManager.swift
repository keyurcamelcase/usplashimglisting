//
//  InternetConnectionManager.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 14/04/24.
//

import Foundation
import Network
import SystemConfiguration

class NetworkManager {
    static let shared = NetworkManager()
    
    private var reachability: SCNetworkReachability?
    
    private init() {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        self.reachability = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress)
    }
    
    func startMonitoring() {
        guard let reachability = self.reachability else { return }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            let isConnected = flags.contains(.reachable)
            NotificationCenter.default.post(name: .internetStatusChanged, object: nil, userInfo: ["isConnected": isConnected])
        }, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
    
    func stopMonitoring() {
        guard let reachability = self.reachability else { return }
        SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
}
