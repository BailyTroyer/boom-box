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
  
  var playingAd: Bool = false
  
  var dataTimer: Timer!
  
  var song_nominations: [JSON] = []
  
  var first: Bool = true
  
  var emptyMessageLabel: UILabel!
  var emptyMessageButton: UIButton!
  
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
    self.setBackgroundLabel()
    //self.tableView.backgroundView = self.emptyMessageLabel
//    if(self.song_nominations.count == 0){
//      self.tableView.backgroundView = self.emptyMessageLabel
//    }else{
//      self.tableView.backgroundView = nil
//    }

    return self.song_nominations.count
  }
  
  func setBackgroundLabel(){
    var message: String
    if(self.song_nominations.count == 0){
      if(!Party.shared.partyStarted){
        if(Party.shared.host){
          message = "Oops... You need to start the music!\n\nGo to Spotify and start playing the \n'\(Party.shared.name!)' playlist!"
        }
        else{
          message = "Oops... It looks like the host hasn't started the playlist!"
        }
        
      }
      else {
        message = "There aren't any song nominations up...\n\n\nTap to add a song!"
      }
    }
    else{
      message = "\n\n\nTap to add a song!"
    }
    
    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: message)
    attributedString.setColor(color: #colorLiteral(red: 0.4755314086, green: 0.3991935802, blue: 0.01888621333, alpha: 1), forText: "add a song!")
    attributedString.setColor(color: #colorLiteral(red: 0.4755314086, green: 0.3991935802, blue: 0.01888621333, alpha: 1), forText: "'\(Party.shared.name!)'")
    emptyMessageLabel.attributedText = attributedString
  }
  
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if(indexPath.row > self.song_nominations.count - 1){return UITableViewCell()}
    let cell =  tableView.dequeueReusableCell(withIdentifier: "songCard", for: indexPath) as! SongCardTableViewCell
    
    let song = song_nominations[indexPath.row]
    
    cell.setSelected(true, animated: false)
    
    if(Party.shared.voteHistory.contains(song["id"].stringValue)){
      cell.songSwitch.isOn = true
    }
    else{
      cell.songSwitch.isOn = false
    }
    
    cell.artistName.text = song["artists"][0]["name"].string!
    cell.songName.text = song["name"].string!
    cell.songId = song["id"].string!
    cell.votes.text = "\(song["votes"].int!)"
    
    cell.profilePicture.alpha = 0
    
    if let url = URL(string: song["album"]["images"][0]["url"].string!) {
      DispatchQueue.global().async {
        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        DispatchQueue.main.async {
          cell.profilePicture.image = UIImage(data: data!)
          
          UIView.animate(withDuration: 0.3, animations: {
            cell.profilePicture.alpha = 0.5
          })
        }
      }
    }
    
//    let scale = 1.0 - (CGFloat(indexPath.row) / 15.0)
//    
//    cell.transform = CGAffineTransform.init(scaleX: scale, y: scale)
    
    return cell
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
    
    
    let rect = CGRect(origin: CGPoint(x: 400,y :0), size: CGSize(width: tableView.bounds.size.width - 400, height: tableView.bounds.size.height))
    guard let customFont = UIFont(name: "AirbnbCerealApp-Medium", size: 16) else {
        fatalError("""
    Failed to load the "AirbnbCereal-Medium" font.
    Make sure the font file is included in the project and the font name is spelled correctly.
    """
        )
    }
    emptyMessageLabel = UILabel(frame: rect)
    emptyMessageLabel.numberOfLines = 0
    emptyMessageLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    emptyMessageLabel.textAlignment = .center;
    emptyMessageLabel.alpha = 0
    emptyMessageLabel.font = customFont
    
    tableView.backgroundView = emptyMessageLabel
    
    
    let tableTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedTableView))
    tableView.addGestureRecognizer(tableTouchRecognizer)
    //self.view.addGestureRecognizer(tableTouchRecognizer)
    
    
    partyCode.text = Party.shared.code
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
    nowPlayingPic.isUserInteractionEnabled = true
    nowPlayingPic.addGestureRecognizer(tapGestureRecognizer)
    nowPlayingPic.layer.masksToBounds = false
    nowPlayingPic.layer.cornerRadius = nowPlayingPic.frame.size.width / 8
    nowPlayingPic.clipsToBounds = true
    //nowPlayingPic.alpha = 0.1
    self.nowPlayingTitle.text = ""
    
    exit.layer.cornerRadius = exit.frame.size.width / 2
    nominate.layer.cornerRadius = nominate.frame.size.width / 2
    alert.layer.cornerRadius = alert.frame.size.width / 2
    
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    refreshControl.tintColor = UIColor.lightGray
    
    
    self.dataTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
      self.fetchData()
    }
    
    
  }
  
  @objc func tappedTableView(tap: UITapGestureRecognizer){
    let location = tap.location(in: self.tableView)
    let path = self.tableView.indexPathForRow(at: location)
    if path != nil {
      //self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: path)
    } else {
        // handle tap on empty space below existing rows however you want
      if(song_nominations.count == 0){
        if(!Party.shared.partyStarted){ // open spotify
          let playlistUrl = "https://open.spotify.com/playlist/\(Party.shared.playlistId!)"
          if let url = URL(string: playlistUrl) {
              UIApplication.shared.open(url)
          }
        }
        else{ // add a song
          self.go()
        }
      }
      else{
        self.go()
      }
    }
  }
  
  @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
  {
    let tappedImage = tapGestureRecognizer.view as! UIImageView
    
    if(tappedImage.alpha == 1){
      UIView.animate(withDuration: 0.3, animations: {self.nowPlayingPic.alpha = 0.1})
    }else{
      UIView.animate(withDuration: 0.3, animations: {self.nowPlayingPic.alpha = 1})
    }
  }
  
  @objc private func refreshData(_ sender: Any) {
    fetchData()
  }
  
  func fetchData() {
    //print("Fetching data")

    // check for updates
    self.refreshControl.endRefreshing()
    
    Party.shared.getPartyInfo(completion: { data in
      
      if (data == nil) {
        self.dataTimer.invalidate()
        let alert = UIAlertController(title: "Looks like this party has ended :(", message: "Press OK to go back...", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
          self.exit(self)
        }))

        self.present(alert, animated: true)
        
        return
      }
      
      // sort nominations by votes
      Party.shared.partyStarted = data!["started"].boolValue
      self.setBackgroundLabel()
      
      if(data!["playing_ad"].boolValue){
        self.playingAd = true
        self.nowPlayingTitle.text = "Advertisement..."
        UIView.animate(withDuration: 0.3, animations: {self.nowPlayingPic.alpha = 0})
      }
      else if(self.playingAd){ // was playing ad, not anymore
        self.playingAd = false
        UIView.animate(withDuration: 0.3, animations: {self.nowPlayingPic.alpha = 1})
      }
      
      if(!data!["song_nominations"].exists() && !self.first || !Party.shared.partyStarted){
        return
      }
      
      let sortedNoms = data!["song_nominations"].arrayValue.sorted(by: {(a, b) in
        return a["votes"].int! > b["votes"].int!
      })
      
      
      
      self.guestCount.text = "\(data!["guests"].arrayValue.count + 1)"
      let newNowPlayingTitle = "\(data!["now_playing"]["name"].string!) - \(data!["now_playing"]["artists"][0]["name"].string!)"
      
      if(self.nowPlayingTitle.text != newNowPlayingTitle){
        if let url = URL(string: data!["now_playing"]["album"]["images"][1]["url"].string!) {
          DispatchQueue.global().async {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
              
              if(!self.playingAd){
                self.nowPlayingTitle.text = newNowPlayingTitle
              }
              
              UIView.transition(with: self.nowPlayingPic!, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.nowPlayingPic.image = UIImage(data: data!)
              }, completion: nil)
            }
          }
        }
      }
      
      self.first = false
      if(sortedNoms != self.song_nominations){
        self.song_nominations = sortedNoms
        self.tableView.reloadData()
        
        if(self.song_nominations.count == 0){
          self.startEmptyMessageAnimation()
        }
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
    
    //self.nowPlayingPic.alpha = 0.1
    //getImage()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.tableView.reloadData()
    
    //print("set new partyview")
    Party.shared.partyView = self
    
    if(Party.shared.host){
      let alert = UIAlertController(title: "Start playing the music!", message: "Open Spotify and start playing the '\(Party.shared.name!)' playlist.", preferredStyle: .alert)

      alert.addAction(UIAlertAction(title: "I'll do it myself", style: .destructive, handler: {_ in
        self.startEmptyMessageAnimation()
      }))
      
      alert.addAction(UIAlertAction(title: "Open Spotify", style: .default, handler: {_ in
        
        self.startEmptyMessageAnimation()
        
        let playlistUrl = "https://open.spotify.com/playlist/\(Party.shared.playlistId!)"
        if let url = URL(string: playlistUrl) {
            UIApplication.shared.open(url)
        }
      }))

      self.present(alert, animated: true)
    }else{
      self.startEmptyMessageAnimation()
    }

    print("VIEW APPEARED")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.dataTimer.invalidate()
  }
  
  func returnToMenu(){
    if(Party.shared.createVC != nil){
      Party.shared.createVC!.dismiss(animated: true, completion: {
        self.dismiss(animated: true, completion: nil)
      })
      Party.shared.createVC = nil
    }
  }
  
  func startEmptyMessageAnimation(){
    self.emptyMessageLabel.alpha = 0
    UIView.animate(
      withDuration: 2,
      delay: 0,
      options: [.autoreverse, .repeat, .curveEaseOut],
      animations: {self.emptyMessageLabel.alpha = 1},
      completion: nil
    )
  }
  
  @IBAction func cops(_ sender: Any) {
    Party.shared.policeAlert(completion: { result in
      print("result")
    })
  }
  
  @IBAction func exit(_ sender: Any) {
    
    let alert = UIAlertController(title: "You're the host!", message: "Leaving the party will end it for everyone...", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Keep it going", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "End party", style: .destructive, handler: { action in
      Party.shared.leaveParty(completion: {_ in})
      self.returnToMenu()
    }))
    
    
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

extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
      self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}
