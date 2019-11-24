//
//  SearchResultTableViewCell.swift
//  BoomBox
//
//  Created by Darren Matthew on 11/24/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation

import UIKit

protocol SearchResultTableViewCellDelegate: class {
  func didVote(onCell: SearchResultTableViewCell)
}

class SearchResultTableViewCell: UITableViewCell {
  
  @IBOutlet weak var songArt: UIImageView!
  @IBOutlet weak var songTitle: UILabel!
  @IBOutlet weak var songArtist: UILabel!
  
  var songUrl: String!

  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // initialization code
    
    songArt.layer.borderWidth = 1.0
    songArt.layer.masksToBounds = false
    songArt.layer.borderColor = UIColor.white.cgColor
    songArt.layer.cornerRadius = 6
    songArt.clipsToBounds = true
  }
  
  
    

  
//  override func setSelected(_ selected: Bool, animated: Bool) {
//    super.setSelected(selected, animated: animated)
//
//    // Configure the view for the selected state
//  }
}
