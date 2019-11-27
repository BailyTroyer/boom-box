//
//  PartyCode.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class PartyCode: UIViewController {
  
  @IBOutlet weak var partyCode: UILabel!
  
  @IBOutlet weak var loadingLabel: UILabel!
  @IBOutlet weak var loader: UIActivityIndicatorView!
  
  @IBOutlet weak var label1: UILabel!
  @IBOutlet weak var label2: UILabel!
  var continueButton: UIButton = UIButton()
  
  var uuid: String?
    
  var started = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let uuid = randomString(length: 5)
    self.uuid = uuid
    Party.shared.code = uuid
    
    self.partyCode.text = uuid
    
    self.loader.alpha = 0
    self.loadingLabel.alpha = 0
    
    let userInterfaceStyle = traitCollection.userInterfaceStyle
    print("STYLE: \(userInterfaceStyle)")
    
    if userInterfaceStyle == .dark {
      print("fdsfds")
      self.label1.textColor = UIColor.white
      self.label2.textColor = UIColor.white
    }
    
    continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/10), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
    
    // button text "sign in"
    continueButton.setTitle("Create Party", for: .normal)
    
    // add button target
    continueButton.addTarget(self, action: #selector(next_view), for: .touchUpInside)
    
    // button color white
    continueButton.backgroundColor = #colorLiteral(red: 0.6913432479, green: 0.2954210937, blue: 0.8822820783, alpha: 1)
    
    // center within view
    continueButton.center.x = self.view.frame.midX
    
    // round button
    continueButton.layer.cornerRadius = 10
    // button.layer.borderWidth = 1
    // button.layer.borderColor = UIColor.black.cgColor
    
    continueButton.setTitleColor(UIColor.white, for: .normal)
    
    // add button to view
    self.view.addSubview(continueButton)
    
    continueButton.bindToKeyboard()
  }
  
  func randomString(length: Int) -> String {

      let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      let len = UInt32(letters.length)

      var randomString = ""

      for _ in 0 ..< length {
          let rand = arc4random_uniform(len)
          var nextChar = letters.character(at: Int(rand))
          randomString += NSString(characters: &nextChar, length: 1) as String
      }

      return randomString
  }
  
  @objc func next_view() {
    // call createParty
    if(self.started){return}
    
    
    
    UIView.animate(withDuration: 0.3, animations: {
      self.loader.alpha = 1
      self.loadingLabel.alpha = 1
      self.continueButton.alpha = 0.3
    })
    
    Party.shared.createParty(completion: { response in
      
      self.started = true
      
      UIView.animate(withDuration: 0.3, animations: {
        self.loader.alpha = 0
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
  
}
