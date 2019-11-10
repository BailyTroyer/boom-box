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
    
    let userInterfaceStyle = traitCollection.userInterfaceStyle
    print("STYLE: \(userInterfaceStyle)")
    
    if userInterfaceStyle == .dark {
      print("fdsfds")
      self.label1.textColor = UIColor.white
      self.label2.textColor = UIColor.white
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/6), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
    
    // button text "sign in"
    continueButton.setTitle("Continue", for: .normal)
    
    // add button target
    continueButton.addTarget(self, action: #selector(next_view), for: .touchUpInside)
    
    // button color white
    continueButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    
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
    //      self.name.becomeFirstResponder()
    
  }
  
  func randomString(length: Int) -> String {

      let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
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
    
    Party.shared.createParty(completion: { response in
      
      self.started = true
      
      if response {
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
    let when = DispatchTime.now() + 1
    DispatchQueue.main.asyncAfter(deadline: when){
      // your code with delay
      alert.dismiss(animated: true, completion: nil)
    }
  }
  
}
