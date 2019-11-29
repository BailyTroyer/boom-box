//
//  NumberPeople.swift
//  Spotify
//
//  Created by Baily Troyer on 11/3/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class NumberPeople: UIViewController {
  
  var continueButton: UIButton = UIButton()
  @IBOutlet weak var nubmerPeople: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
      continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
      
      // button text "sign in"
      continueButton.setTitle("Continue", for: .normal)
      
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
      
      continueButton.bindToKeyboard()
      self.nubmerPeople.becomeFirstResponder()
      
  }
  
  @objc func next_view() {
    if nubmerPeople.text != "" && Int(nubmerPeople.text!)! > 0 {
      if Int(nubmerPeople.text!)! > 10 {
        Party.shared.size = "medium"
      } else {
        Party.shared.size = "small"
      }
      self.performSegue(withIdentifier: "starter_song", sender: self)
    } else {
      print("show error code")
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
      self.nubmerPeople.resignFirstResponder()
  }
  
  @IBAction func back(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
