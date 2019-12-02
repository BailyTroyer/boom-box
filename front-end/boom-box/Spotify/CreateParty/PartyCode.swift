//
//  PartyCode.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class PartyCode: UIViewController {
  
  @IBOutlet weak var partyCode: UILabel!
  
  @IBOutlet weak var loadingLabel: UILabel!
  @IBOutlet weak var loader: UIActivityIndicatorView!
  
  @IBOutlet weak var label1: UILabel!
  @IBOutlet weak var label2: UILabel!
  var continueButton: UIButton = UIButton()
  
  var uuid: String?
    
  var started = false
  
  var lottieLoader: AnimationView = AnimationView(name: "loading")
  
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loader.alpha = 0
    self.loadingLabel.alpha = 0

    continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/10), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
    
    // button text "sign in"
    continueButton.setTitle("Create Party", for: .normal)
    
    // add button target
    continueButton.addTarget(self, action: #selector(next_view), for: .touchUpInside)
    
    // button color white
    continueButton.backgroundColor = #colorLiteral(red: 1, green: 0.8729196191, blue: 0.03638987988, alpha: 1)
    continueButton.setTitleColor(#colorLiteral(red: 0.1612424775, green: 0.1719595896, blue: 0.1890429046, alpha: 1), for: .normal)
    
    // center within view
    continueButton.center.x = self.view.frame.midX
    
    // round button
    continueButton.layer.cornerRadius = 10
    
    // add button to view
    self.view.addSubview(continueButton)
    
    lottieLoader.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
    lottieLoader.center.x = self.view.center.x
    lottieLoader.center.y = self.view.center.y + self.view.frame.maxY/4
    lottieLoader.contentMode = .scaleAspectFill
    lottieLoader.alpha = 0

    self.view.addSubview(lottieLoader)
    lottieLoader.loopMode = .loop
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.lottieLoader.stop()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.partyCode.alpha = 0
    self.uuid = randomString(length: 6)
    Party.shared.code = self.uuid
    //self.partyCode.text = uuid
    
    
    UIView.animate(withDuration: 0.3, animations: {
      self.partyCode.alpha = 1
    })
  }
  
  func randomString(length: Int) -> String {

    let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {
      let rand = arc4random_uniform(len)
      var nextChar = letters.character(at: Int(rand))
      if(randomString == ""){
        randomString += NSString(characters: &nextChar, length: 1) as String
      }
      else{
        randomString += "•\(NSString(characters: &nextChar, length: 1) as String)"
      }
    }
    
    self.partyCode.text = randomString

    return randomString.replacingOccurrences(of: "•", with: "")
  }
  
  @objc func next_view() {
    if(self.started){return} // if the request is already in progress
    
    lottieLoader.play()
    
    UIView.animate(withDuration: 0.3, animations: {
      self.lottieLoader.alpha = 1
      self.loadingLabel.alpha = 1
      self.continueButton.alpha = 0.3
    })
    self.started = true
    Party.shared.createParty(completion: { response in
      
      UIView.animate(withDuration: 0.3, animations: {
        self.lottieLoader.alpha = 0
        self.loadingLabel.alpha = 0
      })
      
      if response {
        Party.shared.host = true
        
        if Party.shared.size == "medium" {
          self.performSegue(withIdentifier: "to_large_party", sender: self)
        } else {
          self.performSegue(withIdentifier: "to_small_party", sender: self)
        }
      } else {
        // failed to create party
        self.started = false
        
        let alert = UIAlertController(title: "Oh no!", message: "There was an issue creating your party... Our servers may be down.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
        
        UIView.animate(withDuration: 0.3, animations: {
          self.continueButton.alpha = 1
        })
        print("oh no!")
      }
    })
  }
  
  @IBAction func back(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func copyClipBoard(_ sender: Any) {
    
    // store to clipboard
    let pasteboard = UIPasteboard.general
    pasteboard.string = uuid
    
    let alert = UIAlertController(title: "Code copied to clipboard.", message: nil, preferredStyle: .alert)
    self.present(alert, animated: true, completion: nil)

    // change to desired number of seconds (in this case 5 seconds)
    let when = DispatchTime.now()
    DispatchQueue.main.asyncAfter(deadline: when){
      // your code with delay
      alert.dismiss(animated: true, completion: nil)
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
