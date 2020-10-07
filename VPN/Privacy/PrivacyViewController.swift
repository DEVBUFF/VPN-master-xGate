//
//  PrivacyViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/24/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

final class PrivacyViewController: UIViewController {

    //MARK: - Variables private
    @IBOutlet private weak var holderView: UIView!
    @IBOutlet private weak var buttonHolderView: UIView!
    
    var showOnboarding: (()->())? = nil
    
    //MARK: - Actions
    @IBAction private func settingsButtonAction(_ sender: Any) {
    }
    
    @IBAction private func backButtonAction(_ sender: Any) {
        guard navigationController == nil else {
            navigationController?.popViewController(animated: true)
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func startTrialButtonAction(_ sender: Any) {
        guard let navigation = navigationController else {
            let alert = UIAlertController(title: "Are you sure ?", message: "xGate doesn't collect any online activity data. We only collect the email address you use too contact us through the contact form. We store your email address in encrypted form on fully encrypted servers. We use the collected personal data to notify you of changes in our services, to collect analysis or valuable infomation so that we can improve our services and to provide customer support. We do not request or store your name, IP address, physical address or any other personal information.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default) { (_) in
                settings.needAcceptTerms = false
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                self.showOnboarding?()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        if navigation.viewControllers[0] is SubscriptionViewController {
            navigation.popViewController(animated: true)
        }
    }
    
}

//MARK: - Lifecycle
extension PrivacyViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        holderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
        buttonHolderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
    }
    
}

//MARK: - Private methods
private extension PrivacyViewController {
    
    func showSubscriptionVC() {
        let subsVC = SubscriptionViewController(nibName: "SubscriptionViewController", bundle: nil)
        let nc = UINavigationController(rootViewController: subsVC)
        nc.modalPresentationStyle = .fullScreen
        self.present(nc, animated: true, completion: nil)
    }
    
}
