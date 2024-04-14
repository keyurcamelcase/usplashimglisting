//
//  DeviceManager.swift
//  unsplashImages
//
//  Created by Keyur barvaliya on 14/04/24.
//

import UIKit

class DeviceManager {
    static var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isiPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}
