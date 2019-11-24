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

class NominateSong: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  
  var continueButton: UIButton = UIButton()
    
  @IBOutlet weak var searchInput: UITextField!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var searchResultsTable: UITableView!
  
  var results: [JSON] = []
  
  
  var link: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    searchResultsTable.dataSource = self
    searchResultsTable.delegate = self
    
    continueButton = UIButton(frame: CGRect(x: 0, y: (self.view.frame.maxY - 64), width: (self.view.frame.maxX - self.view.frame.maxX/6), height: 50))
    
    // button text "sign in"
    continueButton.setTitle("Nominate Song", for: .normal)
    
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
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    searchButton.addTarget(self, action: #selector(doSearch), for: .touchUpInside)
  }
  
  @objc func doSearch() {
    if(self.searchInput.text == nil) {return}
    
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
  
  @objc func keyboardWillHide(notification: NSNotification) {
      UIView.animate(withDuration: 0.3, animations: {
        self.continueButton.alpha = 1
      })
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
    let songUrl = self.results[indexPath.row]["external_urls"]["spotify"].string!
    
    self.link = songUrl
    
    UIView.animate(withDuration: 0.3, animations: {
      self.continueButton.alpha = 1
    })
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  searchResultsTable.dequeueReusableCell(withIdentifier: "searchResult", for: indexPath) as! SearchResultTableViewCell
    
    let song = results[indexPath.row]
    
    cell.songTitle.text = song["name"].string!
    cell.songArtist.text = song["artists"][0]["name"].string!
    cell.songUrl = song["external_urls"]["spotify"].string!
    
    cell.songArt.alpha = 0
    if let url = URL(string: song["album"]["images"][2]["url"].string!) {
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
    
    return cell
  }
  
  func fetchData() {
    Party.shared.getSearchResults(completion: { data in
      //print(data)
      self.results = data["tracks"]["items"].arrayValue
      self.searchResultsTable.reloadData()
    })
  }
  
  @objc func next_view() {
    // do something here?
    
    // nominate song and go back
    
    Party.shared.song_url = self.link
    
    Party.shared.nominate(completion: { result in
      
      if result {
        print("YESS SUBMITTED")
      } else {
        print("FDFDJSFJHDfdsafs")
      }
    })
    
    self.back(self)
  }

  
  @IBAction func back(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
