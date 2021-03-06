//
//  LoginViewController.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import SpotifyLogin
import UIKit
import Lottie

class LogInViewController: UIViewController {
  
  var loginButton: SpotifyLoginButton!
  var animationView: AnimationView!
  var viewThing: UIView = UIView()
    
  override func viewWillAppear(_ animated: Bool) {
    animationView.play()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let title = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX - self.view.frame.maxX/8, height: 100))
    title.center.y = view.center.y + self.view.frame.maxY/16
    title.center.x = view.center.x
    
    title.textAlignment = .center
    title.text = "Your song, their song, someone's song."
    
    guard let customFont = UIFont(name: "AirbnbCerealApp-Medium", size: 16) else {
        fatalError("""
    Failed to load the "AirbnbCereal-Medium" font.
    Make sure the font file is included in the project and the font name is spelled correctly.
    """
        )
    }
    
    title.font = customFont
    title.numberOfLines = 2
    title.textColor = UIColor.white
    self.view.addSubview(title)
    
    // ------ body ------
    
    let body = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.maxX - self.view.frame.maxX/8, height: 100))
    //label.center = CGPoint(x: 160, y: 285)
    body.center.y = view.center.y + self.view.frame.maxY/7
    body.center.x = view.center.x
    
    body.textAlignment = .center
    body.text = "Join your friends live music playlist as other people vote for the next song!"
    
    guard let customBodyFont = UIFont(name: "AirbnbCerealApp-Light", size: 16) else {
        fatalError("""
    Failed to load the "AirbnbCereal-Medium" font.
    Make sure the font file is included in the project and the font name is spelled correctly.
    """
        )
    }
    
    body.font = customBodyFont
    body.numberOfLines = 3
    body.textColor = UIColor.lightGray
    self.view.addSubview(body)
      
      
    //load map pin lottie animation
    animationView = AnimationView(name: "duck")
    animationView.frame = CGRect(x: 0, y: 0, width: 225, height: 225)
    
    // label.center.y = view.center.y
    animationView.center.x = self.view.center.x
    animationView.center.y = self.view.center.y - self.view.frame.maxY/5
    animationView.contentMode = .scaleAspectFill
    
    self.view.addSubview(animationView)
    animationView.play()
    
    animationView.loopMode = .loop
  
  
    loginButton = SpotifyLoginButton(
      viewController: self,
      scopes: [
        .streaming,
        .userReadTop,
        .playlistReadPrivate,
        .userLibraryRead,
        .userReadPlaybackState,
        .playlistModifyPublic,
        .playlistModifyPrivate,
        .playlistReadPrivate,
        .userReadPrivate,
        .userReadEmail
      ]
    )
    
    viewThing = UIView(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/5), width: (self.view.frame.maxX - self.view.frame.maxX/4), height: 40))
    loginButton.center.x = viewThing.center.x

    viewThing.center.x = self.view.center.x
    
    viewThing.addSubview(loginButton)
    self.view.addSubview(viewThing)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(loginSuccessful),
                                           name: .SpotifyLoginSuccessful,
                                           object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.animationView.stop()
  }

  
  @objc func loginSuccessful() {
    print("CALLED LOGIN SUCCESSFUL")
    SpotifyLogin.shared.getAccessToken { (accessToken, error) in
      if let token=accessToken, error==nil {
        Party.shared.userId = SpotifyLogin.shared.username
        Party.shared.token = token
        
        Party.shared.fetchUserInfo()
        
        // Try to connect to party from their last session
        let defaults = UserDefaults.standard

        let partyCode = defaults.string(forKey: "partyCode")
        let isHost = defaults.bool(forKey: "isHost")
        
        if let code = partyCode {
          Party.shared.code = code
          Party.shared.host = isHost
          
          // check if party is still going
          Party.shared.getPartyInfo(partyCode: code, completion: {data in
            if(data == nil){
              self.performSegue(withIdentifier: "authed", sender: self)
            }
            else{
              Party.shared.autoParty = true
              self.performSegue(withIdentifier: "auto_party", sender: self)
            }
          })
        }
        else{
          self.performSegue(withIdentifier: "authed", sender: self)
        }
      }
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

}

