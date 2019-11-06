//
//  LargePartyView.swift
//  Spotify
//
//  Created by Baily Troyer on 11/3/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import UIKit

class LargePartyView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
  
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    // profile picture
    
    
    profilePicture.layer.borderWidth = 1.0
    profilePicture.layer.masksToBounds = false
    profilePicture.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
    profilePicture.clipsToBounds = true
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let width = UIScreen.main.bounds.width
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.itemSize = CGSize(width: width / 2, height: width / 2)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    collectionView!.collectionViewLayout = layout
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.collectionView.reloadData()
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 6
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // tableView.dequeueReusableCell(withIdentifier: "songCard", for: indexPath) as! SongCardTableViewCell
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongCell", for: indexPath) as! SongCell
    cell.songImage.layer.masksToBounds = true
    return cell
  }
  
  @IBAction func exit(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func cops(_ sender: Any) {
    Party.shared.policeAlert(completion: { result in
      print("result")
    })
  }
}
