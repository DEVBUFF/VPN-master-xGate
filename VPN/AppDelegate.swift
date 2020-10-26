//
//  AppDelegate.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/23/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit
import Firebase
import FirebaseRemoteConfig
import FirebaseDynamicLinks

var settings = Settings()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        window?.rootViewController = LaunchViewController(nibName: "LaunchViewController", bundle: nil)
        
        //Firebase
        FirebaseApp.configure()
        
        if settings.wasFunnel == false {
            showLaunch()
            
        } else if settings.wasFunnel == true {
            fetchRemoteConfig {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.openFunnel()
                }
               
            }
            
        }
        if settings.didFirstLoad {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [unowned self] in
                self.sendPostBack()
            }
        }
        
        
        //IAP
        IAPManager.shared.loadProducts()
        
        
        
        return true
    }
    
    func showLaunch() {
        window?.rootViewController = LaunchViewController(nibName: "LaunchViewController", bundle: nil)
    }
    
    func openFunnel() {
        switch settings.funnelType {
        case .malware1:
            let mainScreenVC = CheckConnectionViewController(nibName: "CheckConnectionViewController", bundle: nil)
            let nc = UINavigationController(rootViewController: mainScreenVC)
            window?.rootViewController = nc
            
        case .malware2:
            let mainScreenVC = CheckConnectionLocationViewController(nibName: "CheckConnectionLocationViewController", bundle: nil)
            let nc = UINavigationController(rootViewController: mainScreenVC)
            window?.rootViewController = nc
            
        default:
            print("nothing")
            
        }
        
    }
    
    func fetchRemoteConfig(completion: @escaping ()->()) {
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { [unowned self] (status, error) in
            if error == nil {
                print("status  \(status.rawValue)")
                RemoteConfig.remoteConfig().activate { (error) in
                    print("aactivate error \(error?.localizedDescription ?? "")")
                    completion()
                }
            } else {
                completion()
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            
            let arrayStrings = dynamicLink.url?.absoluteString.split(separator: "/")
            let word = arrayStrings?.last
   
            handleDynamicLink(dynamicLink)
            
            return true
        } else {
            return false
        }
    }
    
    func handleDynamicLink(_ link: DynamicLink) {
        guard let url = link.url else {
            return
        }
        let arrayStrings = url.absoluteString.split(separator: "/")
        let word = arrayStrings.last
        if let index = word?.range(of: "?")?.lowerBound {
            let substring = word?[..<index]
            
            let string = String(substring ?? "")
            settings.funnelType = Settings.FunnelType(rawValue: string) ?? .malware1
            settings.wasFunnel = true
            
//            self.mainScreenVC = nil
//            self.instructionsVC = nil
            fetchRemoteConfig {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.openFunnel()
                }
            }
            
        }
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems {
            if let item = queryItems.first(where: {$0.name == "subid"}) {
                settings.funnelSUBID = item.value
            }
        }
        
       
    }
    
    func sendPostBack() {
        guard let subid = settings.funnelSUBID, subid != "{subid}" else { return }
        let postbackLink = RemoteConfig.remoteConfig().configValue(forKey: "postback_link").stringValue ?? ""
        
        let url = URL(string: postbackLink + "?subid=\(subid)")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
         guard let incomingURL = userActivity.webpageURL else { return false }
         let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL, completion: { link, _ in
             guard let link = link else { return }
            //if settings.wasFunnel == true {
                self.handleDynamicLink(link)
         //   }
             
         })
         return linkHandled
     }
}

