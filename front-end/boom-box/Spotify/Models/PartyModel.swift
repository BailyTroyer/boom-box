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
  

  let apiUrl = "https://8acf8907.ngrok.io"
  
  func getImage(completion: @escaping (_ repsonse: String) -> Void) {
    
    //    https://api.spotify.com/v1/me
    
    
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
    
    let parameters: [String: Any] = [
      "size": size!,
      "party_code": code!,
      "name": name!,
      "token": token!,
      "starter_song": starter_song_link!,
      "user_id": username!
    ]
    
    Alamofire.request("\(apiUrl)/party", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      print(response)
      completion(response.result.isSuccess)
      
    }
  }
  
  func joinParty(completion: @escaping (_ response: Bool) -> Void) {
    
    let parameters: [String: Any] = [
      "party_code": code!,
      "user_id": username!
    ]
    
    Alamofire.request("\(apiUrl)/party/attendance", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseString { response in
      print(response)
      completion(response.result.isSuccess)
      
    }
  }
  
  func getPartyInfo(completion: @escaping (_ response: JSON) -> Void) {
    
    Alamofire.request("\(apiUrl)/party/info?party_code=\(code!)", method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { response in
      //print(response)
      
      if let result = response.result.value {
        
        let json = JSON(result)
        completion(json)
      }
      //print(response)
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
}
