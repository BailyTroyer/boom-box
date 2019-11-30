//
//  File.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import SpotifyLogin
import Lottie
import UIKit

class PartyView: UIViewController {
  
  @IBOutlet weak var newParty: UIView!
  @IBOutlet weak var joinPeople: UIView!
  
  var musicLoad: AnimationView = AnimationView(name: "music-load")
  var dancing: AnimationView = AnimationView(name: "dancing")
  var danceButton: UIButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let newPartyRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.newPartyAction))
    newParty.addGestureRecognizer(newPartyRecognizer)
    
    let joinPeopleRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.joinPeopleAction))
    joinPeople.addGestureRecognizer(joinPeopleRecognizer)
    
    musicLoad.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    dancing.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    
    musicLoad.center.x = self.view.center.x
    dancing.center.x = self.view.center.x
    
    musicLoad.center.y = self.view.center.y - self.view.frame.maxY/4
    dancing.center.y = self.view.center.y + self.view.frame.maxY/5
    
    musicLoad.contentMode = .scaleAspectFill
    dancing.contentMode = .scaleAspectFill
    
    newParty.addSubview(musicLoad)
  
    danceButton.addSubview(dancing)
    self.view.addSubview(danceButton)
    
    musicLoad.play()
    dancing.play()
    
    musicLoad.loopMode = .loop
    dancing.loopMode = .loop
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.dancing.stop()
    self.musicLoad.stop()
    Party.shared.createVC = self
  }
    
  override func viewWillAppear(_ animated: Bool) {
    
    musicLoad.play()
    dancing.play()
  }
  
  @objc func newPartyAction(sender:UITapGestureRecognizer) {
    self.performSegue(withIdentifier: "new_party", sender: self)
  }
  
  @objc func joinPeopleAction(sender:UITapGestureRecognizer) {
    self.performSegue(withIdentifier: "join_people", sender: self)
  }
  
  @IBAction func exit(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
