//
//  NameView.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class NameView: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var name: UITextField!
  
  var continueButton: UIButton = UIButton()
  
  @IBOutlet weak var label1: UILabel!
  @IBOutlet weak var label2: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    name.delegate = self
    
    let userInterfaceStyle = traitCollection.userInterfaceStyle
    
    if userInterfaceStyle == .dark {
      self.label1.textColor = UIColor.white
      self.label2.textColor = UIColor.white
    }
    
    name.addTarget(self, action: #selector(textFieldDidChange(_:)),
    for: UIControl.Event.editingChanged)
    
    
    continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
    
    // button text "sign in"
    continueButton.setTitle("Skip", for: .normal)
    
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
    
    
    self.name.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.name.becomeFirstResponder()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    name.resignFirstResponder()
    self.next_view()
    return true
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)

      let userInterfaceStyle = traitCollection.userInterfaceStyle // Either .unspecified, .light, or .dark
      // Update your user interface based on the appearance
      print("userInterface style")
    
      if userInterfaceStyle == .dark {
        self.label1.textColor = UIColor.white
        self.label1.textColor = UIColor.white
      }
  }
  
  @objc func next_view() {
    if name.text!.replacingOccurrences(of: " ", with: "") != "" {
      Party.shared.name = name.text
    }
    
    Party.shared.size = "small"
    self.performSegue(withIdentifier: "skip_size", sender: self)
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    if(name.text!.replacingOccurrences(of: " ", with: "") == ""){
      continueButton.setTitle("Skip", for: .normal)
    }
    else{
      continueButton.setTitle("Continue", for: .normal)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
      //self.name.resignFirstResponder()
  }
  
  @IBAction func cancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
