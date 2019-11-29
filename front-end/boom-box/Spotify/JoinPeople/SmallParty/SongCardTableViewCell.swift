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
    
  var songId: String?
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // initialization code
    
    profilePicture.layer.borderWidth = 1.0
    profilePicture.layer.masksToBounds = false
    profilePicture.layer.borderColor = UIColor.white.cgColor
    profilePicture.layer.cornerRadius = 30
    profilePicture.clipsToBounds = true
    
    songSwitch.addTarget(self, action: #selector(onSwitchValueChanged(sender:)), for: .valueChanged)
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
