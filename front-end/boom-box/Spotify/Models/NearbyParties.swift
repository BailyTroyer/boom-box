//
//  NearbyParties.swift
//  BoomBox
//
//  Created by Darren Matthew on 12/1/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SwiftyJSON

class NearbyPartyManager: NSObject {

  var advertiser: MCNearbyServiceAdvertiser!
  var browser: MCNearbyServiceBrowser!


  static let shared = NearbyPartyManager()
  
  let localPeerID: MCPeerID
  let serviceType = "BoomBox"
  
  var currentNearbyParties: [[String : String]] = []
  var nearbyTable: UITableView!
  
  var devices: [Device] = []
  
  override init() {
    if let data = UserDefaults.standard.data(forKey: "peerID"), let id = NSKeyedUnarchiver.unarchiveObject(with: data) as? MCPeerID {
      self.localPeerID = id
    } else {
      let peerID = MCPeerID(displayName: UIDevice.current.name)
      let data = try? NSKeyedArchiver.archivedData(withRootObject: peerID)
      UserDefaults.standard.set(data, forKey: "peerID")
      self.localPeerID = peerID
    }
    
    super.init()

    self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: self.serviceType)
    self.browser.delegate = self
  }
  
  func device(for id: MCPeerID) -> Device {
    for device in self.devices {
      if device.peerID == id { return device }
    }
    
    let device = Device(peerID: id)
    
    self.devices.append(device)
    return device
  }
  
  func broadcastPartyCode() {
    self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: [ "BoomBox-Party" : Party.shared.code! ], serviceType: self.serviceType)
    self.advertiser.delegate = self
    self.advertiser.startAdvertisingPeer()
    print("started broadcasting")
  }
  
  func searchForNearbyParties(){
    self.browser.startBrowsingForPeers()
  }
  
  func stop() {
    if(self.advertiser != nil){
      self.advertiser.stopAdvertisingPeer()
    }
    
    if(self.browser != nil){
      self.browser.stopBrowsingForPeers()
    }
  }
}



extension NearbyPartyManager: MCNearbyServiceAdvertiserDelegate {
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
  }
}

extension NearbyPartyManager: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    print("lost peer")
    self.currentNearbyParties.removeAll(where: {dict in
      dict["peer"] == peerID.displayName
    })
    self.nearbyTable.reloadData()
  }
  
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    print("Found peer")
    if let i = info{
      if let partyCode = i["BoomBox-Party"]{
        print("FOUND A PARTY: \(partyCode)")
        self.currentNearbyParties.append([ "code": partyCode, "peer": peerID.displayName])
        self.nearbyTable.reloadData()
      }
    }
  }
}


class Device: NSObject {
  let peerID: MCPeerID
  var session: MCSession?
  var name: String
  var state = MCSessionState.notConnected
  
  init(peerID: MCPeerID) {
    self.name = peerID.displayName
    self.peerID = peerID
    super.init()
  }
  
  func invite(with browser: MCNearbyServiceBrowser) {
    //browser.invitePeer(self.peerID, to: self.session!, withContext: nil, timeout: 10)
  }
  
  func connect() {
    if self.session != nil { return }
    
    self.session = MCSession(peer: NearbyPartyManager.shared.localPeerID)
    self.session?.delegate = self
  }
}

extension Device: MCSessionDelegate {
  public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    self.state = state
    //NotificationCenter.default.post(name: Notifications.deviceDidChangeState, object: self)
  }
  
  public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) { }
  
  public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
  
  public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

  public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }

}


