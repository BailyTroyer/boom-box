//
//  NominateSong.swift
//  BoomBox
//
//  Created by Darren Matthew on 11/24/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class NominateSong: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
  
  
  var continueButton: UIButton = UIButton()
    
  @IBOutlet weak var searchInput: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var searchResultsTable: UITableView!
  
  let cardBackground = UIView()
  
  var results: [JSON] = []
  
  
  var link: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    searchResultsTable.dataSource = self
    searchResultsTable.delegate = self
    searchInput.delegate = self
    
    searchButton.alpha = 0.2
    searchResultsTable.separatorColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    cardBackground.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/8), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
    
    // button text "sign in"
    continueButton.setTitle("Nominate Song", for: .normal)
    
    // add button target
    continueButton.addTarget(self, action: #selector(next_view), for: .touchUpInside)
    
    // button color white
    continueButton.backgroundColor = #colorLiteral(red: 1, green: 0.8729196191, blue: 0.03638987988, alpha: 1)
    continueButton.setTitleColor(#colorLiteral(red: 0.1612424775, green: 0.1719595896, blue: 0.1890429046, alpha: 1), for: .normal)
    
    // center within view
    continueButton.center.x = self.view.frame.midX
    
    // round button
    continueButton.layer.cornerRadius = 10
    
    continueButton.alpha = 0
    
    // add button to view
    self.view.addSubview(continueButton)
    
    continueButton.bindToKeyboard()
    self.searchInput.becomeFirstResponder()
    
    searchButton.addTarget(self, action: #selector(doSearch), for: .touchUpInside)
    searchInput.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: UIControl.Event.editingChanged)
  }
  
  @objc func doSearch() {
    if(self.searchInput.text == nil ||
      self.searchInput.text == "") {return}
    
    Party.shared.searchString = self.searchInput.text!.replacingOccurrences(of: " ", with: "%20")
    self.link = nil
    self.view.endEditing(true)
    self.fetchData()
    
    UIView.animate(withDuration: 0.3, animations: {
      self.continueButton.alpha = 0.4
    })
  }
  
  @objc func keyboardWillShow(notification: NSNotification) {
      UIView.animate(withDuration: 0.3, animations: {
        self.continueButton.alpha = 0
      })
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.searchInput.resignFirstResponder()
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    if(searchInput.text == "" || self.searchInput.text == nil){
      UIView.animate(withDuration: 0.3, animations: {
        self.searchButton.alpha = 0.2
      })
    }
    else {
      UIView.animate(withDuration: 0.3, animations: {
        self.searchButton.alpha = 1
      })
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if(searchInput.text! == ""){
      return false
    }
    searchInput.resignFirstResponder()
    self.doSearch()
    return true
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
    let songUrl = self.results[indexPath.row]["external_urls"]["spotify"].string!
    
    self.link = songUrl
    
    self.view.endEditing(true)
    
    UIView.animate(withDuration: 0.3, animations: {
      self.continueButton.alpha = 1
    })
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  searchResultsTable.dequeueReusableCell(withIdentifier: "searchResult", for: indexPath) as! SearchResultTableViewCell
    
    cell.selectedBackgroundView = self.cardBackground
    
    let song = results[indexPath.row]
    
    cell.songTitle.text = song["name"].string!
    cell.songArtist.text = song["artists"][0]["name"].string!
    cell.songUrl = song["external_urls"]["spotify"].string!
    
    cell.songArt.alpha = 0
    if let urlString = song["album"]["images"][2]["url"].string {
      if let url = URL(string: urlString) {
        DispatchQueue.global().async {
          let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
          DispatchQueue.main.async {
            cell.songArt.image = UIImage(data: data!)
            
            UIView.animate(withDuration: 0.3, animations: {
              cell.songArt.alpha = 1
            })
          }
        }
      }
    }
    
    return cell
  }
  
  func fetchData() {
    
    self.results = []
    self.searchResultsTable.reloadData()
    
    Party.shared.getSearchResults(completion: { data in
      //print(data)
      self.results = data["tracks"]["items"].arrayValue
      self.searchResultsTable.reloadData()
    })
  }
  
  @objc func next_view() {
    // do something here?
    if(self.link == nil){return}
    
    // nominate song and go back
    
    Party.shared.song_url = self.link
    
    Party.shared.nominate(completion: { code in
      if(code == 200){
        self.back(self)
      }else{
        let alert = UIAlertController(title: "Oops! That didn't work...", message: "Press OK to go back...", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      }
    })
  }

  
  @IBAction func back(_ sender: Any) {
    UIView.animate(withDuration: 0.25, delay: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations: {
      Party.shared.partyView?.nominate.transform = CGAffineTransform.init(rotationAngle: 0)
    }, completion: nil)

    self.dismiss(animated: true, completion: {
      if(Party.shared.partyView != nil){
        Party.shared.partyView?.fetchData()
        Party.shared.partyView?.startDataTimer()
      }
    })
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
