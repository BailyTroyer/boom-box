//
//  JoinPeople.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class JoinPeople: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var code: UITextField!
  @IBOutlet weak var nearbyStatus: UILabel!
  
  var continueButton: UIButton = UIButton()
  
  var emptyMessageLabel: UILabel!
  
  @IBOutlet weak var nearbyPartiesTable: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    nearbyPartiesTable.dataSource = self
    nearbyPartiesTable.delegate = self
    
    nearbyStatus.text = ""
    
    guard let customFont = UIFont(name: "AirbnbCerealApp-Book", size: 16) else {
        fatalError("""
    Failed to load the "AirbnbCereal-Medium" font.
    Make sure the font file is included in the project and the font name is spelled correctly.
    """
        )
    }
    emptyMessageLabel = UILabel()
    emptyMessageLabel.numberOfLines = 0
    emptyMessageLabel.textColor = #colorLiteral(red: 0.2759276235, green: 0.2987528678, blue: 0.3319122779, alpha: 1)
    emptyMessageLabel.textAlignment = .center;
    emptyMessageLabel.alpha = 0
    emptyMessageLabel.font = customFont
    
    nearbyPartiesTable.backgroundView = emptyMessageLabel
    emptyMessageLabel.attributedText = NSMutableAttributedString(string: "")
    
    NearbyPartyManager.shared.currentNearbyParties = []
    NearbyPartyManager.shared.nearbyTable = nearbyPartiesTable
    NearbyPartyManager.shared.searchForNearbyParties()
    
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
    
  override func viewDidAppear(_ animated: Bool) {
    //self.code.becomeFirstResponder()
    UIView.animate(withDuration: 0.3, animations: {
      self.emptyMessageLabel.alpha = 1
    })
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.code.resignFirstResponder()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(NearbyPartyManager.shared.currentNearbyParties.count == 0){
      emptyMessageLabel.attributedText = NSMutableAttributedString(string: "\n\nThere aren't any parties nearby...")
      self.code.becomeFirstResponder()
      UIView.animate(withDuration: 0.3, animations: {
        self.emptyMessageLabel.alpha = 1
      })
      self.nearbyStatus.text = ""
    }else{
      UIView.animate(withDuration: 0.3, animations: {self.emptyMessageLabel.alpha = 0})
      emptyMessageLabel.attributedText = NSMutableAttributedString(string: "")
      self.nearbyStatus.text = "We found some parties nearby!"
    }
    return NearbyPartyManager.shared.currentNearbyParties.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
    let cell =  nearbyPartiesTable.dequeueReusableCell(withIdentifier: "nearbyParty", for: indexPath) as! NearbyPartyCell
    self.code.text = NearbyPartyManager.shared.currentNearbyParties[indexPath.row]["code"]
    
    self.view.endEditing(true)
    
    UIView.animate(withDuration: 0.3, animations: {
      self.continueButton.alpha = 1
    })
    UIView.animate(
      withDuration: 0.2,
      animations: {cell.superview?.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)}
    )
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  nearbyPartiesTable.dequeueReusableCell(withIdentifier: "nearbyParty", for: indexPath) as! NearbyPartyCell
    
    
    
    //cell.selectedBackgroundView = self.cardBackground
    let code = NearbyPartyManager.shared.currentNearbyParties[indexPath.row]["code"]
    cell.partyCode = code
    
    Party.shared.getPartyInfo(partyCode: code!, completion: {data in
      if let party = data {
        
        cell.hostName.text = party["host_display_name"].stringValue
        
        cell.partyName.text = party["name"].stringValue
        
        UIView.animate(withDuration: 0.3, animations: {
          cell.nowPlayingArt.alpha = 0
        })
        
        if let urlString = party["now_playing"]["album"]["images"][1]["url"].string {
          if let url = URL(string: urlString) {
            DispatchQueue.global().async {
              let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
              DispatchQueue.main.async {
                cell.nowPlayingArt.image = UIImage(data: data!)
                
                UIView.animate(withDuration: 0.3, animations: {
                  cell.nowPlayingArt.alpha = 0.6
                })
              }
            }
          }
        }
      }else{return}
    })
      
    return cell
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
    NearbyPartyManager.shared.stop()
  }
  
  @IBAction func cancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
