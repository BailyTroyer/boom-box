//
//  JoinPeople.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class JoinPeople: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var code: UITextField!
  
  var continueButton: UIButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    code.delegate = self
    
    continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
    
    // button text "sign in"
    continueButton.setTitle("Continue", for: .normal)
    
    // add button target
    continueButton.addTarget(self, action: #selector(next_view), for: .touchUpInside)
    
    // button color white
    continueButton.backgroundColor = #colorLiteral(red: 1, green: 0.8729196191, blue: 0.03638987988, alpha: 1)
    continueButton.setTitleColor(#colorLiteral(red: 0.1612424775, green: 0.1719595896, blue: 0.1890429046, alpha: 1), for: .normal)
    
    continueButton.alpha = 0.3
    
    // center within view
    continueButton.center.x = self.view.frame.midX
    
    // round button
    continueButton.layer.cornerRadius = 10
    
    // add button to view
    self.view.addSubview(continueButton)
    
    continueButton.bindToKeyboard()
    
    code.addTarget(self, action: #selector(textFieldDidChange(_:)),
                   for: UIControl.Event.editingChanged)
  }
    
    override func viewWillAppear(_ animated: Bool) {
      self.code.becomeFirstResponder()
    }
  

  
  @objc func next_view() {
    if(self.code.text!.count != 6){return}
    
    Party.shared.code = self.code.text!
    
    UIView.animate(withDuration: 0.3, animations: {
        self.continueButton.alpha = 0.3
    })
    Party.shared.joinParty(completion: { code in
      if code == 200 {
        UserDefaults.standard.set(Party.shared.code, forKey: "partyCode")
        UserDefaults.standard.set(false, forKey: "isHost")
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: "show_small_party", sender: self)
      } else {
        
        // failed to join party
        var message: String!
        
        if(code == 404){
            message = "It looks like that party doesn't exist... Did you type the code correctly?"
        }
        else{
            message = "There was an issue joining the party... Our servers may be down."
        }
        
        let alert = UIAlertController(title: "Oh no!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        UIView.animate(withDuration: 0.3, animations: {
          self.continueButton.alpha = 1
        })
      }
    })
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    self.code.text = self.code.text?.replacingOccurrences(of: " ", with: "")
    if(self.code.text?.count == 6){
        UIView.animate(withDuration: 0.3, animations: {
          self.continueButton.alpha = 1
        })
    }
    else{
        UIView.animate(withDuration: 0.3, animations: {
            self.continueButton.alpha = 0.3
        })
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      let maxLength = 6
      let currentString: NSString = textField.text! as NSString
      let newString: NSString =
          currentString.replacingCharacters(in: range, with: string) as NSString
      return newString.length <= maxLength
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.code.resignFirstResponder()
  }
  
  @IBAction func cancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
