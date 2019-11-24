//
//  NameView.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class NameView: UIViewController {
  
  @IBOutlet weak var name: UITextField!
  
  var continueButton: UIButton = UIButton()
  
  @IBOutlet weak var label1: UILabel!
  @IBOutlet weak var label2: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let userInterfaceStyle = traitCollection.userInterfaceStyle
    
    if userInterfaceStyle == .dark {
      self.label1.textColor = UIColor.white
      self.label2.textColor = UIColor.white
    }
    
    name.addTarget(self, action: #selector(textFieldDidChange(_:)),
    for: UIControl.Event.editingChanged)
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
  
  override func viewDidAppear(_ animated: Bool) {
      continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
      
      // button text "sign in"
      continueButton.setTitle("Continue", for: .normal)
      
      // add button target
      continueButton.addTarget(self, action: #selector(next_view), for: .touchUpInside)
      
      // button color white
      continueButton.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
      
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
      self.name.becomeFirstResponder()
      
  }
  
  @objc func next_view() {
    if name.text != "" {
        Party.shared.name = name.text
      self.performSegue(withIdentifier: "number_people", sender: self)
    } else {
      print("show error code")
    }
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
      self.name.resignFirstResponder()
  }
  
  @IBAction func cancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

