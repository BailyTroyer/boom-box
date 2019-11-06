//
//  SongCardTableViewCell.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import UIKit

class SongCardTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var songName: UILabel!
  @IBOutlet weak var songSwitch: UISwitch!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // initialization code
    
    profilePicture.layer.borderWidth = 1.0
    profilePicture.layer.masksToBounds = false
    profilePicture.layer.borderColor = UIColor.white.cgColor
    profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
    profilePicture.clipsToBounds = true
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
