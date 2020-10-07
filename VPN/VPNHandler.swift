//
//  VPNHandler.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/24/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//
import NetworkExtension

final class VPNHandler {

    let vpnManager = NEVPNManager.shared()
    

    func initVPNTunnelProviderManager(server: ServerVpn) {

        print("CALL LOAD TO PREFERENCES...")
        self.vpnManager.loadFromPreferences { (error) -> Void in

            if((error) != nil) {

                print("VPN Preferences error: 1")
            } else {

                let IKEv2Protocol = NEVPNProtocolIKEv2()
                
                IKEv2Protocol.serverAddress = server.RemoteAddress

                IKEv2Protocol.authenticationMethod = .sharedSecret
                IKEv2Protocol.useExtendedAuthentication = false //if you are using sharedSecret method then make it false
                IKEv2Protocol.disconnectOnSleep = false

                //Set IKE SA (Security Association) Params...
                IKEv2Protocol.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
                IKEv2Protocol.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA256
                IKEv2Protocol.ikeSecurityAssociationParameters.diffieHellmanGroup = .group14
                IKEv2Protocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440

                let kcs = KeychainService()
                //Save password in keychain...
                kcs.save(key: "SharedSecret", value: server.SharedSecret)
                //Load password from keychain...
                IKEv2Protocol.sharedSecretReference = kcs.load(key: "SharedSecret")

                self.vpnManager.protocolConfiguration = IKEv2Protocol
                self.vpnManager.localizedDescription = "VPN"
                self.vpnManager.isEnabled = true

                self.vpnManager.isOnDemandEnabled = true
                print(IKEv2Protocol)

                //Set rules
                var rules = [NEOnDemandRule]()
                let rule = NEOnDemandRuleConnect()
                rule.interfaceTypeMatch = .any
                rules.append(rule)

                print("SAVE TO PREFERENCES...")
                
                 //SAVE TO PREFERENCES...
                self.vpnManager.saveToPreferences(completionHandler: { (error) -> Void in
                    if((error) != nil) {

                        print("VPN Preferences error: 2 \(error?.localizedDescription ?? "")")
                    } else {

                        print("CALL LOAD TO PREFERENCES AGAIN...")
                        //CALL LOAD TO PREFERENCES AGAIN...
                        self.vpnManager.loadFromPreferences(completionHandler: { (error) in
                            if ((error) != nil) {
                                print("VPN Preferences error: 2 \(error?.localizedDescription ?? "")")
                            } else {
                                var startError: NSError?
                                do {
                                    //START THE CONNECTION...
                                    try self.vpnManager.connection.startVPNTunnel()
                                } catch let error as NSError {

                                    startError = error
                                    print(startError.debugDescription)
                                } catch {

                                    print("Fatal Error")
                                    fatalError()
                                }
                                if ((startError) != nil) {
                                    print("VPN Preferences error: 3")

                                    //Show alert here
                                    print("title: Oops.., message: Something went wrong while connecting to the VPN. Please try again.")

                                    print(startError.debugDescription)
                                } else {
                                    //self.VPNStatusDidChange(nil)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        VPNHandler.checkStatus()
                                    }
                                    print("Starting VPN...")
                                }
                            }
                        })
                    }
                })
            }
        } //END OF .loadFromPreferences //

    }

    //MARK:- Connect VPN
    static func connectVPN(with server: ServerVpn) {
        VPNHandler().initVPNTunnelProviderManager(server: server)
    }

    //MARK:- Disconnect VPN
    static func disconnectVPN() {
        VPNHandler().vpnManager.connection.stopVPNTunnel()
    }
    
    static func getConnectionTimeSeconds() -> Float {
        return Float(VPNHandler().vpnManager.connection.connectedDate?.timeIntervalSince(Date()) ?? 0)
    }

    //MARK:- check connection staatus
    static func checkStatus() {
        let status = VPNHandler().vpnManager.connection.status
        print("VPN connection status = \(status.rawValue)")
        NotificationCenter.default.post(name: NSNotification.Name("kUpdateUIWithStatus"), object: status)
        switch status {
        case NEVPNStatus.connected:

            print("Connected")

        case NEVPNStatus.invalid, NEVPNStatus.disconnected :

            print("Disconnected")

        case NEVPNStatus.connecting , NEVPNStatus.reasserting:
            print("Connecting")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.checkStatus()
            }
            
        case NEVPNStatus.disconnecting:

            print("Disconnecting")

        default:
            print("Unknown VPN connection status")
        }
    }
}
