//
//  Settings.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/24/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import Foundation

final class Settings {
    
    enum FunnelType: String {
        case malware3 = "malware3"
        case malware2 = "malware2"
        case malware1 = "malware1"
    }
    
    //MARK: - AppSettings
    private struct Keys {
        static let kDidFirstLoad = "kFirstLoad"
        static let kProtectionIsOn = "kProtectionIsOn"
        static let kAutocennectIsOn = "kAutocennectIsOn"
        static let kSelectedVPN = "kSelectedVPN"
        static let kNeedAcceptTerms = "kNeedAcceptTerms"
        static let kFunnelType = "kFunnelType"
        static let kWasFunnel = "kWasFunnel"
        static let kSUBID = "kSUBID"
        static let kMalwareDone = "kMalwareDone"

    }
    
    //MARK: - Private methods
    fileprivate static func set(value: Any?, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    fileprivate static func value<T>(for key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
    
}

extension Settings {
    
    var malwareDone: Bool {
        get {
            return Settings.value(for: Settings.Keys.kMalwareDone) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kMalwareDone)
        }
    }
    
    var funnelSUBID: String? {
        get {
            return Settings.value(for: Settings.Keys.kSUBID) ?? nil
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kSUBID)
        }
    }
    
    var wasFunnel: Bool {
        get {
            return Settings.value(for: Settings.Keys.kWasFunnel) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kWasFunnel)
        }
    }
    
    var funnelType: FunnelType {
        get {
            return FunnelType(rawValue: Settings.value(for: Settings.Keys.kFunnelType) ?? "malware1")  ?? .malware1
        }
        set {
            Settings.set(value: newValue.rawValue, for: Settings.Keys.kFunnelType)
        }
    }
    
    var needAcceptTerms: Bool {
        get {
            return Settings.value(for: Settings.Keys.kNeedAcceptTerms) ?? true
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kNeedAcceptTerms)
        }
    }
    
    var selectedVPN: String? {
        get {
            return Settings.value(for: Settings.Keys.kSelectedVPN)
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kSelectedVPN)
        }
    }
    
    var didFirstLoad: Bool {
        get {
            return Settings.value(for: Settings.Keys.kDidFirstLoad) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kDidFirstLoad)
        }
    }
    
    var protectionIsOn: Bool {
        get {
            return Settings.value(for: Settings.Keys.kProtectionIsOn) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kProtectionIsOn)
        }
    }
    
    var autocennectIsOn: Bool {
        get {
            return Settings.value(for: Settings.Keys.kAutocennectIsOn) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kAutocennectIsOn)
        }
    }
    
}
