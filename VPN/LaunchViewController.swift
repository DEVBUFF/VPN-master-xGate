//
//  LaunchViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/23/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var animateImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var images: [UIImage] = []
        for n in 0...45 {
            if n < 10 {
                let image = UIImage(named: "Icon_0000\(n)") ?? UIImage()
                images.append(image)
            } else {
                let image = UIImage(named: "Icon_000\(n)") ?? UIImage()
                images.append(image)
            }
        }
        
        let animatedImage = UIImage.animatedImage(with: images, duration: 1.5)
        animateImageView.image = animatedImage
        
        
        if let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? ViewController {
            let nc = UINavigationController(rootViewController: mainVC)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard !settings.wasFunnel else {
//                    DispatchQueue.main.async { [weak self] in
//                        guard let `self` = self else { return }
//                        self.openFunnel()
//                    }
                   
                    return
                }
                 UIApplication.shared.keyWindow?.rootViewController = nc
            }
        }
        
    }

    func openFunnel() {
        switch settings.funnelType {
        case .malware1:
            let mainScreenVC = CheckConnectionViewController(nibName: "CheckConnectionViewController", bundle: nil)
            let nc = UINavigationController(rootViewController: mainScreenVC)
            UIApplication.shared.keyWindow?.rootViewController = nc
            
        case .malware2:
            let mainScreenVC = CheckConnectionLocationViewController(nibName: "CheckConnectionLocationViewController", bundle: nil)
            let nc = UINavigationController(rootViewController: mainScreenVC)
            UIApplication.shared.keyWindow?.rootViewController = nc
            
        default:
            print("nothing")
            
        }
        
    }

}
