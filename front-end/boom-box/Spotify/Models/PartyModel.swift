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
  var username: String?
  var starter_song_link: String?
  var song_url: String?
  var vote: Bool?
  var voteSongId: String?
  var searchString: String?
  var playlistId: String?
  var createVC: PartyView? = nil
  
  var currentParty: String?
  var partyStarted: Bool = false
  var host: Bool = false
  

  //let apiUrl = "https://41f1df47.ngrok.io"
  let apiUrl = "https://boom-box-beta.appspot.com"
  
  func getImage(completion: @escaping (_ repsonse: String) -> Void) {
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(token!)",
      "Accept": "application/json"
    ]
    
    Alamofire.request("https://api.spotify.com/v1/me", method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
      
      print(response)
      //to get status code
      if let status = response.response?.statusCode {
        switch(status){
        case 201:
          print("example success")
        default:
          print("error with response status: \(status)")
        }
      }
      //to get JSON return value
      if let result = response.result.value {
        let json = JSON(result)
        
        let imageURL = (json["images"][0]["url"]).stringValue
        completion(imageURL)
      }
      completion("")
      
    }
    
  }
  
  func nominate(completion: @escaping (_ response: Bool) -> Void) {
    let parameters: [String: Any] = [
      "party_code": code!,
      "song_url": song_url!,
      "token": token!
    ]
    
    Alamofire.request("\(apiUrl)/party/nomination", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      
      completion(response.result.isSuccess)
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
    
    if(name == nil){
      name = "BoomBox Party - \(code!)"
    }
    
    let parameters: [String: Any] = [
      "size": size!,
      "party_code": code!,
      "name": name!,
      "token": token!,
      "starter_song": starter_song_link!,
      "user_id": username!
    ]
    
    Alamofire.request("\(apiUrl)/party", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      
      self.playlistId = response.result.value
      completion(response.result.isSuccess)
    }
    
    self.host = true
  }
  
  func joinParty(completion: @escaping (_ response: Bool) -> Void) {
    
    let parameters: [String: Any] = [
      "party_code": code!,
      "user_id": username!
    ]
    print("Joining party: \(code!)")
    
    Alamofire.request("\(apiUrl)/party/attendance", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      print(response)
      completion(response.result.isSuccess)
      
    }
  }
  
  func getPartyInfo(completion: @escaping (_ response: JSON?
    ) -> Void) {
    
    Alamofire.request("\(apiUrl)/party/info?party_code=\(code!)", method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { response in
      //print(response)
      
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
      "user_id": username!
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
    }
  }
    
  func voteForSong(completion: @escaping (_ response: Bool) -> Void) {
      
    let parameters: [String: Any] = [
      "party_code": code!,
      "user_id": username!,
      "vote": vote!,
      "song_id": voteSongId!
    ]
    
    Alamofire.request("\(apiUrl)/vote", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      //print(response)
      completion(response.result.isSuccess)
      
    }
  }
  
  func getSearchResults(completion: @escaping (_ response: JSON) -> Void) {
    
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(token!)",
      "Accept": "application/json"
    ]
    
    Alamofire.request("https://api.spotify.com/v1/search?q=\(searchString!)&type=track&limit=10", method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
      
      //to get JSON return value
      if let result = response.result.value {
        let json = JSON(result)
        completion(json)
      }
    }
  }
}
