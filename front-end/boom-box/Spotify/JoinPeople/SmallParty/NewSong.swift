//
//  NewSong.swift
//  Spotify
//
//  Created by Baily Troyer on 11/3/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class NewSong: UIViewController {
  
  var doneButton: UIButton = UIButton()
  
  @IBOutlet weak var songLink: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    songLink.addTarget(self, action: #selector(textFieldDidChange(_:)),
    for: UIControl.Event.editingChanged)
  }

  override func viewDidAppear(_ animated: Bool) {
      doneButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/12), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
      
      // button text "sign in"
      doneButton.setTitle("Done", for: .normal)
      
      // add button target
      doneButton.addTarget(self, action: #selector(next_view), for: .touchUpInside)
      
      // button color white
      doneButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
      
      // center within view
      doneButton.center.x = self.view.frame.midX
      
      // round button
      doneButton.layer.cornerRadius = 10
      // button.layer.borderWidth = 1
      // button.layer.borderColor = UIColor.black.cgColor
      
      doneButton.setTitleColor(UIColor.white, for: .normal)
      
      // add button to view
      self.view.addSubview(doneButton)
      
      doneButton.bindToKeyboard()
      self.songLink.becomeFirstResponder()
      
  }
  
  @objc func next_view() {
    self.dismiss(animated: true, completion: nil)
    // call API to upload song
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
      self.doneButton.resignFirstResponder()
  }
  @IBAction func back(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
