//
//  SmallPartyView.swift
//  Spotify
//
//  Created by Baily Troyer on 11/3/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import SwiftyJSON
import BLTNBoard
import UIKit

class SmallPartyView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var hostName: UILabel!
  @IBOutlet weak var profPic: UIImageView!
  
  var song_nominations: [JSON] = []
  
  private let refreshControl = UIRefreshControl()
  
  lazy var bulletinManager: BLTNItemManager = {
    let rootItem: BLTNItem = SmallPartyView.makePopUp()
    return BLTNItemManager(rootItem: rootItem)
  }()
  
  
  func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
  }
  
  func downloadImage(from url: URL) {
    print("Download Started")
    getData(from: url) { data, response, error in
      guard let data = data, error == nil else { return }
      print(response?.suggestedFilename ?? url.lastPathComponent)
      print("Download Finished")
      DispatchQueue.main.async() {
        self.profPic.image = UIImage(data: data)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //print("noms: \(song_nominations.count)")
    return self.song_nominations.count
    //return 8
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if(indexPath.row > self.song_nominations.count - 1){return UITableViewCell()}
    let table =  tableView.dequeueReusableCell(withIdentifier: "songCard", for: indexPath) as! SongCardTableViewCell
    
    let song = song_nominations[indexPath.row]
    
    table.setSelected(true, animated: false)
    
    if(Party.shared.voteSongId == song["id"].string && Party.shared.vote!){
      table.songSwitch.isOn = true
    }
    else{
      table.songSwitch.isOn = false
    }
    
    table.songName.text = "\(song["name"].string!) - \(song["artists"][0]["name"].string!)"
    table.songId = song["id"].string!
    table.votes.text = "\(song["votes"].int!)"
    
      
    if let url = URL(string: song["album"]["images"][0]["url"].string!) {
      DispatchQueue.global().async {
        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        DispatchQueue.main.async {
          table.profilePicture.image = UIImage(data: data!)
        }
      }
    }
    
    return table
    
  }
  
  func getImage() {
    
    Party.shared.getImage(completion: { imageURL in
      
      if let url = URL(string: imageURL) {
        DispatchQueue.global().async {
          let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
          DispatchQueue.main.async {
            self.profPic.image = UIImage(data: data!)
          }
        }
      }
    })
  }
  
  @IBAction func recommendSong(_ sender: Any) {
    bulletinManager.showBulletin(above: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    profPic.layer.borderWidth = 1.0
    profPic.layer.masksToBounds = false
    profPic.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    profPic.layer.cornerRadius = profPic.frame.size.width / 2
    profPic.clipsToBounds = true
    
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    
    
    Party.shared.getPartyInfo(completion: { data in
      //print(data)
    })
    
  }
  
  @objc private func refreshData(_ sender: Any) {
    fetchData()
  }
  
  func fetchData() {
    
    // check for updates
    self.refreshControl.endRefreshing()
    
    Party.shared.getPartyInfo(completion: { data in
      print(data)
      if(!data["song_nominations"].exists()){return}
      // sort nominations by votes
      self.song_nominations = data["song_nominations"].arrayValue.sorted(by: {(a, b) in
        return a["votes"].int! > b["votes"].int!
      })
      
      self.tableView.reloadData()
    })
  }
  
  
  static func makePopUp() -> BLTNItem {
    
    let page = BLTNPageItem(title: "Yayy!")
    page.image = UIImage(named: "heart")
    
    page.descriptionText = "Now you can select a song for people to vote on."
    page.actionButtonTitle = "Let's go!"
    page.alternativeButtonTitle = "Not now"
    page.isDismissable = true
    
    page.actionHandler = { item in
      item.manager?.displayNextItem()
    }
    
    page.alternativeHandler = { item in
      item.manager?.dismissBulletin()
    }
    
    page.next = makeTextFieldPage()
    
    return page
    
  }
  
  static func makeTextFieldPage() -> TextFieldBulletinPage {
    
    let page = TextFieldBulletinPage(title: "What's your fav song?")
    page.isDismissable = false
    page.descriptionText = "Paste the Spotify link here!"
    page.actionButtonTitle = "Submit Song"
    page.isDismissable = true
    
    page.textInputHandler = { (item, text) in
      print("Text: \(text ?? "nil")")
      
      // do something here with the link
      item.manager?.dismissBulletin()
      
      Party.shared.song_url = text
      
      Party.shared.nominate(completion: { result in
        
        if result {
          print("YESS SUBMITTED")
        } else {
          print("FDFDJSFJHDfdsafs")
        }
      })
    }
    
    return page
    
  }
  
  func go() {
    self.performSegue(withIdentifier: "popup", sender: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    getImage()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.tableView.reloadData()
  }
  
  @IBAction func cops(_ sender: Any) {
    Party.shared.policeAlert(completion: { result in
      print("result")
    })
  }
  
  @IBAction func exit(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
