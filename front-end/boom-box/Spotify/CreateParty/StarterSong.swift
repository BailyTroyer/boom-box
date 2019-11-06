//
//  NumberPeople.swift
//  Spotify
//
//  Created by Baily Troyer on 11/3/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class StarterSong: UIViewController {
  
  var continueButton: UIButton = UIButton()
  
  var link: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
//      self.link.becomeFirstResponder()
      
  }
  
  @objc func next_view() {
    // do something here?
    
    if let link_text = link, link != "" {
      Party.shared.starter_song_link = link_text
      self.performSegue(withIdentifier: "party_code", sender: self)
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    
  }
  
//  override func viewWillDisappear(_ animated: Bool) {
//      self.link.resignFirstResponder()
//  }
  
  @IBAction func back(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  @IBAction func pasteFromClipboard(_ sender: Any) {
    let pasteboard = UIPasteboard.general
    if let read = pasteboard.string {
      print("read: \(read)")
      
      self.link = read
      
      let alert = UIAlertController(title: "Read from clipboard: \(read)", message: nil, preferredStyle: .alert)
      self.present(alert, animated: true, completion: nil)

      // change to desired number of seconds (in this case 5 seconds)
      let when = DispatchTime.now() + 1
      DispatchQueue.main.asyncAfter(deadline: when){
        // your code with delay
        alert.dismiss(animated: true, completion: nil)
      }
    }
  }
  
}
