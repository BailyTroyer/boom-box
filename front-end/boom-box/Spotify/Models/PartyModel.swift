//
//  PartyModel.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Party {
  static let shared = Party()
  
  var name: String?
  var code: String?
  var size: String?
  var user_id: String?
  var token: String?
  var userId: String?
  var starter_song_link: String?
  var song_url: String?
  var vote: Bool?
  var voteSongId: String?
  var searchString: String?
  var playlistId: String?
  var playlistName: String?
  var createVC: PartyView? = nil
  var partyView: SmallPartyView? = nil
  var voteHistory: [String] = []
  var autoParty: Bool = false
  
  var userImageUrl: String?
  var userDisplayName: String?
  var userIsPremium: Bool?

  var partyStarted: Bool = false
  var host: Bool = false
  

  //let apiUrl = "https://e366f9fd.ngrok.io"
  let apiUrl = "https://boom-box-beta.appspot.com"
  
  func fetchUserInfo() {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(token!)",
      "Accept": "application/json"
    ]
    
    Alamofire.request("https://api.spotify.com/v1/me", method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
      
      //print(response)
      //to get status code
      if let status = response.response?.statusCode {
        switch(status){
        case 200:
          if let result = response.result.value {
            let json = JSON(result)

            self.userImageUrl = json["images"][0]["url"].stringValue
            self.userDisplayName = json["display_name"].stringValue
            self.userIsPremium = json["product"].stringValue == "premium"
          }
        default:
          print("error with response status: \(status)")
        }
      }
    }
  }
  
  func nominate(completion: @escaping (_ response: Int) -> Void) {
    let parameters: [String: Any] = [
      "party_code": code!,
      "song_url": song_url!,
      "token": token!,
      "user_id": userId!
    ]
    
    Alamofire.request("\(apiUrl)/party/nomination", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      
      if(response.response == nil){
        completion(500)
      }
      completion(response.response!.statusCode)
    }
  }
  
  func removeNomination(songId: String, completion: @escaping (_ response: Int) -> Void) {
    let parameters: [String: Any] = [
      "party_code": code!,
      "song_id": songId
    ]
    
    Alamofire.request("\(apiUrl)/party/nomination", method: .delete, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      
      if(response.response == nil){
        completion(500)
      }
      completion(response.response!.statusCode)
    }
  }
  
  func policeAlert(completion: @escaping (_ response: Bool) -> Void) {
    let parameters: [String: Any] = [
      "party_code": code!,
      //"user_id": name!,
      "token": token!
    ]
    
    Alamofire.request("\(apiUrl)/party/cops", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      print(response)
      completion(response.result.isSuccess)
      
    }
  }
  
  func createParty(completion: @escaping (_ response: Bool) -> Void) {
    
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "MM-dd-yy"
    let dateString = formatter.string(from: Date())
    
    
    if(name == nil){
      name = "BoomBox - \(code!)"
    }
    
    let parameters: [String: Any] = [
      "size": size!,
      "party_code": code!,
      "name": name!,
      "token": token!,
      "starter_song": starter_song_link!,
      "user_id": userId!,
      "time": dateString,
      "display_name": userDisplayName!
    ]
    
    Alamofire.request("\(apiUrl)/party", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      
      self.playlistId = response.result.value
      
      UserDefaults.standard.set(self.code!, forKey: "partyCode")
      UserDefaults.standard.set(true, forKey: "isHost")
      UserDefaults.standard.synchronize()
      self.host = true
      self.autoParty = false
      
      completion(response.result.isSuccess)
    }
    

    
    
  }
  
  func joinParty(completion: @escaping (_ response: Int) -> Void) {
    
    let parameters: [String: Any] = [
      "party_code": code!,
      "user_id": userId!
    ]
    print("Joining party: \(code!)")
    
    Alamofire.request("\(apiUrl)/party/attendance", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      self.autoParty = false
      if(response.response == nil){
        completion(500)
      }
      completion(response.response!.statusCode)
    }
  }
  
  func getPartyInfo(partyCode: String, completion: @escaping (_ response: JSON?
    ) -> Void) {
    
    //print("Called GetPartyInfo")
    
    Alamofire.request("\(apiUrl)/party/info?party_code=\(partyCode)&token=\(token!)&user_id=\(userId!)", method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { response in
      //print(response.response?.statusCode)
      
      if(response.response?.statusCode == 400){
        completion(nil)
      }
      else if(response.response?.statusCode == 200){
        completion(JSON(response.result.value!))
      }
    }
  }
  
  func leaveParty(completion: @escaping (_ response: Bool) -> Void) {
  
    var endpoint: String
    
    if(code == nil) {
      self.host = false
      return
    }
      
    let parameters: [String: Any] = [
      "party_code": code!,
      "user_id": userId!
    ]
    
    if(host){
      endpoint = "/party"
    }
    else{
      endpoint = "/party/attendance"
    }
    
    Alamofire.request("\(apiUrl)\(endpoint)", method: .delete, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      
      completion(response.response?.statusCode == 200)
      
      self.code = nil
      self.host = false
      self.name = nil
      self.partyView = nil
      self.voteHistory = []
      
      UserDefaults.standard.set(nil, forKey: "partyCode")
      UserDefaults.standard.set(false, forKey: "isHost")
      UserDefaults.standard.synchronize()
    }
  }
    
  func voteForSong(vote: Bool, songId: String, completion: @escaping (_ response: Bool) -> Void) {
    
      
    let parameters: [String: Any] = [
      "party_code": code!,
      "user_id": userId!,
      "vote": vote,
      "song_id": songId
    ]
    
    Alamofire.request("\(apiUrl)/vote", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      
      let index = self.voteHistory.firstIndex(of: songId)
      
      if(vote){
        //if index == nil {
          self.voteHistory.append(songId)
        //}
      }
      else{
        if index != nil {
          self.voteHistory.remove(at: index!)
        }
      }
      
      completion(response.result.isSuccess)
    }
  }
  
  func getSearchResults(completion: @escaping (_ response: JSON) -> Void) {
    
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(token!)",
      "Accept": "application/json"
    ]
    
    Alamofire.request("https://api.spotify.com/v1/search?q=\(searchString!)&type=track&limit=30", method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
      
      //to get JSON return value
      if let result = response.result.value {
        let json = JSON(result)
        completion(json)
      }
    }
  }
}
