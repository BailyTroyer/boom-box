//
//  SongCardTableViewCell.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol SongCardTableViewCellDelegate: class {
  func didVote(onCell: SongCardTableViewCell)
}

class SongCardTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var songName: UILabel!
  @IBOutlet weak var artistName: UILabel!
  @IBOutlet weak var songSwitch: UISwitch!
  @IBOutlet weak var votes: UILabel!
  @IBOutlet weak var denominate: UIButton!
  
  var position: Int = -1
  var songId: String?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // initialization code
    
    profilePicture.layer.borderWidth = 1.0
    profilePicture.layer.masksToBounds = false
    profilePicture.layer.borderColor = UIColor.white.cgColor
    profilePicture.layer.cornerRadius = 30
    profilePicture.clipsToBounds = true
    
    profilePicture.image = nil
    
    songSwitch.addTarget(self, action: #selector(onSwitchValueChanged(sender:)), for: .valueChanged)
    denominate.addTarget(self, action: #selector(removeSongNomination), for: .touchUpInside)
  }
  
  @objc func removeSongNomination(){
    print(songId!)
    var message = "Are you sure you want to remove this nomination?"
    if(Int(self.votes.text!) == 1){
      message += "\nIt has 1 vote!"
    }else if (Int(self.votes.text!)! > 1){
      message += "\nIt has \(self.votes.text!) votes!"
    }
      
    let alert = UIAlertController(title: "Remove nomination", message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {_ in
      Party.shared.removeNomination(songId: self.songId!, completion: {code in
        let transform = CGAffineTransform.init(translationX: (self.superview?.frame.maxX)!, y: 0)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
          self.transform = transform
        }, completion: {_ in
          let idx = Party.shared.partyView?.song_nominations.firstIndex(where: {song in
            return song["id"].stringValue == self.songId!
          })
          
          Party.shared.partyView?.song_nominations.remove(at: idx!)
          self.transform = CGAffineTransform.init(translationX: 0, y: 0)
          self.profilePicture.image = nil
          Party.shared.partyView?.tableView.reloadData()
        })
      })
    }))
    
    alert.addAction(UIAlertAction(title: "Keep it", style: .cancel, handler: nil))
    
    Party.shared.partyView!.present(alert, animated: true)
    
  }
    
  @objc func onSwitchValueChanged(sender: UISwitch){
    
    Party.shared.voteForSong(vote: sender.isOn, songId: songId!, completion: {_ in })
    
    let index = Party.shared.partyView?.song_nominations.firstIndex(where: {song in
      return song["id"].stringValue == songId!
    })
    
    
    
    if(sender.isOn){
      self.votes.text = "\(Int(self.votes.text!)! + 1)";
      Party.shared.partyView?.song_nominations[index!]["votes"].int! += 1
    }
    else{
      self.votes.text = "\(Int(self.votes.text!)! - 1)";
      Party.shared.partyView?.song_nominations[index!]["votes"].int! -= 1
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
