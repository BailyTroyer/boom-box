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
  
  var nowPlayingSong: String?
  
  var partyName: String!
  
  var playingAd: Bool = false
  
  var dataTimer: Timer!
  
  var song_nominations: [JSON] = []
  
  var first: Bool = true
  
  var placeholderCell: SongCardTableViewCell!
  
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
    return self.song_nominations.count
  }
  
  func setBackgroundLabel(){
    var message: String
    if(self.song_nominations.count == 0){
      if(!Party.shared.partyStarted){
        if(Party.shared.host){
          message = "Oops... You need to start the music!\n\nGo to Spotify on any device and start playing\n\(self.nowPlayingSong!) in the \(Party.shared.name!) playlist!"
        }
        else{
          message = "Oops... It looks like the host isn't playing the playlist!"
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
    if(Party.shared.host){
      attributedString.setColor(color: #colorLiteral(red: 0.4755314086, green: 0.3991935802, blue: 0.01888621333, alpha: 1), forText: Party.shared.name!)
      attributedString.setColor(color: #colorLiteral(red: 0.4755314086, green: 0.3991935802, blue: 0.01888621333, alpha: 1), forText: self.nowPlayingSong!)
    }
    emptyMessageLabel.attributedText = attributedString
  }
  
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  tableView.dequeueReusableCell(withIdentifier: "songCard", for: indexPath) as! SongCardTableViewCell
    //tableView.de
    let song = song_nominations[indexPath.row]
    if (song == ""){
      return self.placeholderCell
    }
    
    //cell.setSelected(true, animated: false)
    
    if(song["nominated_by"].stringValue == Party.shared.username){
      cell.songSwitch.isHidden = true
      cell.denominate.isHidden = false
    }else{
      cell.denominate.isHidden = true
      cell.songSwitch.isHidden = false
    }
    
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
//
    let top = tableView.convert(CGPoint(x: cell.frame.midX, y: cell.frame.minY), to: tableView.superview)

    //find distance from the top of table view
    let distFromTop = top.y - tableView.frame.minY

    let scale = 1.0 - (CGFloat(distFromTop) / 2500.0)
    let transform = CGAffineTransform.init(scaleX: scale, y: scale)
    
    UIView.animate(withDuration: 0.2, delay: 0, options:[.curveEaseInOut, .allowUserInteraction], animations: {
      cell.profilePicture.superview?.transform = transform
    }, completion: nil)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    print("Pressed: \(indexPath.row)")
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    transformCells(view: scrollView as! UITableView)
  }
  
  func transformCells(view: UITableView){
    let visibleCells = view.visibleCells as! [SongCardTableViewCell]

    for cell in visibleCells{
      // table view top
      let top = view.convert(CGPoint(x: cell.frame.midX, y: cell.frame.minY), to: view.superview)
      
      //find distance from the top of table view
      let distFromTop = top.y - tableView.frame.minY
      
      let scale = 1.0 - (CGFloat(distFromTop) / 2500.0)
      
      //-5x^{2}\ +\ 5
      
      //let scale = sqrt(-(CGFloat(distFromTop) / view.frame.maxY))
      //if(cell.profilePicture.superview?.transform = CGAffineTransform())
      
 
      let transform = CGAffineTransform.init(scaleX: scale, y: scale)

      UIView.animate(withDuration: 0.2, delay: 0, options:[.curveEaseInOut, .allowUserInteraction], animations: {
        cell.profilePicture.superview?.transform = transform
      }, completion: nil)
      cell.profilePicture.superview?.transform = transform
      //print(cell.profilePicture.superview?.transform)

      //cell.profilePicture.superview?.transform = transform
      
    }
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
    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
      self.nominate.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
    }, completion: nil)

    self.dataTimer.invalidate()
    
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
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
    nowPlayingPic.isUserInteractionEnabled = true
    nowPlayingPic.addGestureRecognizer(tapGestureRecognizer)
    nowPlayingPic.layer.masksToBounds = false
    //nowPlayingPic.layer.cornerRadius = nowPlayingPic.frame.size.width / 10
    nowPlayingPic.clipsToBounds = true
    //nowPlayingPic.alpha = 0.1
    nowPlayingTitle.text = ""
    partyCode.text =  ""
    
    exit.layer.cornerRadius = exit.frame.size.width / 2
    nominate.layer.cornerRadius = nominate.frame.size.width / 2
    alert.layer.cornerRadius = alert.frame.size.width / 2
    
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    refreshControl.tintColor = UIColor.lightGray
    
    
    self.startDataTimer()
  }
  
  func startDataTimer(){
    print("started timer")
    self.dataTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { timer in
      UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
        self.exit.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        self.nominate.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
      }, completion: {_ in
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
          self.exit.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
          self.nominate.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        })
      })
      self.fetchData()
    }
  }
  
  @objc func tappedTableView(tap: UITapGestureRecognizer){
    let location = tap.location(in: self.tableView)
    let path = self.tableView.indexPathForRow(at: location)
    if path != nil {
      //self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: path)
    } else {
        // handle tap on empty space below existing rows
      if(song_nominations.count == 0){
        if(!Party.shared.partyStarted && Party.shared.host){ // open spotify
          let playlistUrl = "https://open.spotify.com/playlist/\(Party.shared.playlistId!)"
          if let url = URL(string: playlistUrl) {
              UIApplication.shared.open(url)
          }
        }
        else{ // add a song
          self.recommendSong(self)
        }
      }
      else{
        self.recommendSong(self)
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

          self.returnToMenu()
        }))

        self.present(alert, animated: true)
        
        return
      }
      
      
      Party.shared.partyStarted = data!["started"].boolValue
      Party.shared.name = data!["name"].stringValue
      self.partyCode.text = data!["party_code"].stringValue
      self.nowPlayingSong = data!["now_playing"]["name"].stringValue
      Party.shared.playlistId = data!["playlist"]["id"].stringValue
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
        self.song_nominations = []
        self.nowPlayingTitle.text = ""
        UIView.animate(withDuration: 0.3, animations: {self.nowPlayingPic.alpha = 0.3})
        self.setBackgroundLabel()
        self.tableView.reloadData()
        
        return
      }
      
      if(self.nowPlayingPic.alpha == 0.3){
        UIView.animate(withDuration: 0.3, animations: {self.nowPlayingPic.alpha = 1})
      }
      
      // sort nominations by votes
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
        self.setBackgroundLabel()
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
      
//      Party.shared.nominate(completion: { result in
//        if result {
//          print("YESS SUBMITTED")
//        } else {
//          print("FDFDJSFJHDfdsafs")
//        }
//      })
    }
    
    return page
    
  }
  
  func go() {
    self.performSegue(withIdentifier: "nominate", sender: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.fetchData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.tableView.reloadData()
    
    //print("set new partyview")
    Party.shared.partyView = self
    
    var alert: UIAlertController? = nil
    
    if(Party.shared.host){
      if(Party.shared.autoParty){
        alert = UIAlertController(title: "Welcome back!", message: "You're still the host of this party.", preferredStyle: .alert)
        alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in self.startEmptyMessageAnimation()}))
      }
      else{
        alert = UIAlertController(title: "Start playing the music!", message: "Open Spotify and start playing the '\(Party.shared.name!)' playlist.", preferredStyle: .alert)
        alert!.addAction(UIAlertAction(title: "I'll do it myself", style: .destructive, handler: {_ in self.startEmptyMessageAnimation() }))
        
        alert!.addAction(UIAlertAction(title: "Open Spotify", style: .default, handler: {_ in
          
          self.startEmptyMessageAnimation()
          
          let playlistUrl = "https://open.spotify.com/playlist/\(Party.shared.playlistId!)"
          if let url = URL(string: playlistUrl) {
              UIApplication.shared.open(url)
          }
        }))
      }
    }else{
      if(Party.shared.autoParty){
        alert = UIAlertController(title: "Welcome back!", message: "The last party you were in is still going on.", preferredStyle: .alert)
        alert!.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in self.startEmptyMessageAnimation()}))
      }
      self.startEmptyMessageAnimation()
    }
    
    if(alert != nil){
      self.present(alert!, animated: true)
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
    else{
      self.dismiss(animated: true, completion: nil)
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
    self.dataTimer.invalidate()
    print(self.dataTimer.isValid)
    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
      self.exit.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
    }, completion: nil)
    
    let alert = UIAlertController(title: "You're the host!", message: "Leaving the party will end it for everyone...", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Keep it going", style: .cancel, handler: { _ in
      self.startDataTimer()
      UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
        self.exit.transform = CGAffineTransform.init(rotationAngle: 0)
      }, completion: nil)
    }))
    
    alert.addAction(UIAlertAction(title: "End party", style: .destructive, handler: { _ in
      Party.shared.leaveParty(completion: {_ in
        self.returnToMenu()
      })
    }))
    
    
    // warn host if ending party
    if(Party.shared.host){
      self.present(alert, animated: true)
    }
    else{
      Party.shared.leaveParty(completion: {_ in
        self.returnToMenu()
      })
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

extension NSMutableAttributedString {

    func setColor(color: UIColor, forText stringValue: String) {
       let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
      
      self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
      self.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)

    }

}
