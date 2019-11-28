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
  @IBOutlet weak var nowPlayingPic: UIImageView!
  @IBOutlet weak var nowPlayingTitle: UILabel!
  @IBOutlet weak var guestCount: UILabel!
  @IBOutlet weak var partyCode: UILabel!
  
  @IBOutlet weak var alert: UIButton!
  @IBOutlet weak var nominate: UIButton!
  @IBOutlet weak var exit: UIButton!
  
  var partyName: String!
  
  var dataTimer: Timer!
  
  var song_nominations: [JSON] = []
  
  var first: Bool = true
  
  var emptyMessageLabel: UILabel!
  var emptyMessage: String = ""
  
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
        self.nowPlayingPic.image = UIImage(data: data)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(self.song_nominations.count == 0){
      self.tableView.backgroundView = self.emptyMessageLabel
    }else{
      self.tableView.backgroundView = nil
    }

    return self.song_nominations.count
  }
  
  func setBackgroundLabel(){
    if(!Party.shared.partyStarted){
      if(Party.shared.host){
        self.emptyMessageLabel.text = "Oops... It looks like you need to start the music. Go to Spotify and start playing the '\(Party.shared.name!)' playlist!"
      }
      else{
        self.emptyMessageLabel.text = "Oops... It looks like the host hasn't started the playlist!"
      }
      
    }
    else {
      self.emptyMessageLabel.text = "There aren't any song suggestions up... You should make one!"
    }
  }
  
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if(indexPath.row > self.song_nominations.count - 1){return UITableViewCell()}
    let table =  tableView.dequeueReusableCell(withIdentifier: "songCard", for: indexPath) as! SongCardTableViewCell
    
    let song = song_nominations[indexPath.row]
    
    table.setSelected(true, animated: false)
    
    if(Party.shared.voteHistory.contains(song["id"].stringValue)){
      table.songSwitch.isOn = true
    }
    else{
      table.songSwitch.isOn = false
    }
    
    table.songName.text = "\(song["name"].string!) - \(song["artists"][0]["name"].string!)"
    table.songId = song["id"].string!
    table.votes.text = "\(song["votes"].int!)"
    
    table.profilePicture.alpha = 0
    if let url = URL(string: song["album"]["images"][0]["url"].string!) {
      DispatchQueue.global().async {
        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        DispatchQueue.main.async {
          table.profilePicture.image = UIImage(data: data!)
          
          UIView.animate(withDuration: 0.3, animations: {
            table.profilePicture.alpha = 0.5
          })
        }
      }
    }
    table.alpha = 0;
    // do slide-in animation on cell
    UIView.animate(withDuration: 0.5, animations: {
      table.alpha = 1
     })
    
    return table
    
  }
  
  func getImage() {
    
    Party.shared.getImage(completion: { imageURL in
      
      if let url = URL(string: imageURL) {
        DispatchQueue.global().async {
          let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
          DispatchQueue.main.async {
            self.nowPlayingPic.image = UIImage(data: data!)
          }
        }
      }
    })
  }
  
  @IBAction func recommendSong(_ sender: Any) {
    //bulletinManager.showBulletin(above: self)
    self.go()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    
    
    let rect = CGRect(origin: CGPoint(x: 200,y :0), size: CGSize(width: tableView.bounds.size.width - 200, height: tableView.bounds.size.height))
    emptyMessageLabel = UILabel(frame: rect)
    emptyMessageLabel.numberOfLines = 0
    emptyMessageLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    emptyMessageLabel.textAlignment = .center;
    //emptyMessageLabel.sizeToFit()
    
    partyCode.text = Party.shared.code
    
    nowPlayingPic.layer.masksToBounds = false
    nowPlayingPic.layer.cornerRadius = nowPlayingPic.frame.size.width / 8
    nowPlayingPic.clipsToBounds = true
    
    exit.layer.cornerRadius = exit.frame.size.width / 2
    nominate.layer.cornerRadius = nominate.frame.size.width / 2
    alert.layer.cornerRadius = alert.frame.size.width / 2
    
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    
    self.dataTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { timer in
      self.fetchData()
    }
  }
  
  @objc private func refreshData(_ sender: Any) {
    fetchData()
  }
  
  func fetchData() {

    // check for updates
    self.refreshControl.endRefreshing()
    
    Party.shared.getPartyInfo(completion: { data in
      
      if (data == nil) {
        self.dataTimer.invalidate()
        let alert = UIAlertController(title: "Looks like this party has ended :(", message: "Press Okay to go back...", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
          self.exit(self)
        }))

        self.present(alert, animated: true)
        
        return
      }
      
      // sort nominations by votes
      Party.shared.partyStarted = data!["started"].boolValue
      self.setBackgroundLabel()
      
      let sortedNoms = data!["song_nominations"].arrayValue.sorted(by: {(a, b) in
        return a["votes"].int! > b["votes"].int!
      })
      
      if(!data!["song_nominations"].exists() && !self.first || !Party.shared.partyStarted){
        return
      }
      
      self.guestCount.text = "\(data!["guests"].arrayValue.count + 1)"
      let newNowPlayingTitle = "\(data!["now_playing"]["name"].string!) - \(data!["now_playing"]["artists"][0]["name"].string!)"
      
      if(self.nowPlayingTitle.text != newNowPlayingTitle){
      
        if let url = URL(string: data!["now_playing"]["album"]["images"][1]["url"].string!) {
          DispatchQueue.global().async {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
              self.nowPlayingTitle.text = newNowPlayingTitle
              UIView.animate(withDuration: 0.2, animations: {self.nowPlayingPic.alpha = 0}, completion: {_ in
                self.nowPlayingPic.image = UIImage(data: data!)
                UIView.animate(withDuration: 0.3, animations: {self.nowPlayingPic.alpha = 1})
              })
            }
          }
        }
      }
      
      self.first = false
      if(sortedNoms != self.song_nominations){
        self.song_nominations = sortedNoms
        self.tableView.reloadData()
      }
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
    self.performSegue(withIdentifier: "nominate", sender: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.fetchData()
    self.nowPlayingPic.alpha = 0
    //getImage()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.tableView.reloadData()
    
    if(Party.shared.host){
      let alert = UIAlertController(title: "Start playing the music!", message: "Open Spotify on any of your devices and start playing the '\(Party.shared.name!)' playlist.", preferredStyle: .alert)

      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      alert.addAction(UIAlertAction(title: "Open Spotify", style: .default, handler: {action in
        
        let playlistUrl = "https://open.spotify.com/playlist/\(Party.shared.playlistId!)"
        if let url = URL(string: playlistUrl) {
            UIApplication.shared.open(url)
        }
      }))

      self.present(alert, animated: true)
    }

    print("VIEW APPEARED")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.dataTimer.invalidate()
  }
  
  func returnToMenu(){
    if(Party.shared.createVC != nil){
      Party.shared.createVC!.dismiss(animated: true, completion: nil)
      Party.shared.createVC = nil
    }
  }
  
  @IBAction func cops(_ sender: Any) {
    Party.shared.policeAlert(completion: { result in
      print("result")
    })
  }
  
  @IBAction func exit(_ sender: Any) {
    
    let alert = UIAlertController(title: "You're the host!", message: "Leaving the party will end it for everyone...", preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "End party", style: .default, handler: { action in
      
      Party.shared.leaveParty(completion: {_ in})
      self.returnToMenu()
    }))
    
    alert.addAction(UIAlertAction(title: "Keep it going", style: .default, handler: {_ in}))

    
    // warn host if ending party
    if(Party.shared.host){
      self.present(alert, animated: true)
    }
    else{
      Party.shared.leaveParty(completion: {_ in})
      self.returnToMenu()
    }
  }
}
