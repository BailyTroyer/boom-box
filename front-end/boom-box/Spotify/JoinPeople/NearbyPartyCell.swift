//
//  NearbyPartyCell.swift
//  BoomBox
//
//  Created by Darren Matthew on 12/1/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation

import UIKit

class NearbyPartyCell: UITableViewCell {
  
  @IBOutlet weak var nowPlayingArt: UIImageView!
  @IBOutlet weak var hostName: UILabel!
  @IBOutlet weak var partyName: UILabel!
  
  var partyCode: String!

  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // initialization code
    
    hostName.text = ""
    partyName.text = ""
    nowPlayingArt.alpha = 0
    
    nowPlayingArt.layer.borderWidth = 1.0
    nowPlayingArt.layer.masksToBounds = false
    nowPlayingArt.layer.borderColor = UIColor.white.cgColor
    nowPlayingArt.layer.cornerRadius = 18
    nowPlayingArt.clipsToBounds = true
  }
}
