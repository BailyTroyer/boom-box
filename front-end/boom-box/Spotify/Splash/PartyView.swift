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
  
  var musicLoad:AnimationView = AnimationView(name: "music-load")
  var dancing:AnimationView = AnimationView(name: "dancing")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let newPartyRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.newPartyAction))
    newParty.addGestureRecognizer(newPartyRecognizer)
    
    let joinPeopleRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.joinPeopleAction))
    joinPeople.addGestureRecognizer(joinPeopleRecognizer)
    
    musicLoad.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    dancing.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    
    // label.center.y = view.center.y
    musicLoad.center.x = self.view.center.x
    dancing.center.x = self.view.center.x
    
    musicLoad.center.y = self.view.center.y - self.view.frame.maxY/4
    dancing.center.y = self.view.center.y + self.view.frame.maxY/5
    
    musicLoad.contentMode = .scaleAspectFill
    dancing.contentMode = .scaleAspectFill
    
    self.view.addSubview(musicLoad)
    self.view.addSubview(dancing)
    musicLoad.play()
    dancing.play()
    
    musicLoad.loopMode = .loop
    dancing.loopMode = .loop
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.dancing.stop()
    self.musicLoad.stop()
  }
    
    override func viewWillAppear(_ animated: Bool) {
        musicLoad.play()
        dancing.play()
    }
  
  override func viewDidAppear(_ animated: Bool) {
    

  }
  
  @objc func newPartyAction(sender:UITapGestureRecognizer) {
    
    print("tap working")
    self.performSegue(withIdentifier: "new_party", sender: self)
  }
  
  @objc func joinPeopleAction(sender:UITapGestureRecognizer) {
    
    print("tap working")
    self.performSegue(withIdentifier: "join_people", sender: self)
  }
  
  @IBAction func exit(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
