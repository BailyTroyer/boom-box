//
//  AppDelegate.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import UIKit
import SpotifyLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let redirectURL: URL = URL(string: "loginsample://")!
    SpotifyLogin.shared.configure(clientID: "f399ad7b3a9947ee93e9812cfe6321f8",
                                  clientSecret: "6637f60d371142d59b9c9511ed42333c",
                                  redirectURL: redirectURL)
    
    UINavigationBar.appearance().backIndicatorImage = UIImage()
    UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()
    return true
  }
  
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    let handled = SpotifyLogin.shared.applicationOpenURL(url) { _ in }
    return handled
  }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("APP WILL TERMINATE")
        Party.shared.leaveParty(completion: {_ in})
    }
    
    
  //
  //  // MARK: UISceneSession Lifecycle
  //
  //  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
  //    // Called when a new scene session is being created.
  //    // Use this method to select a configuration to create the new scene with.
  //    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  //  }
  //
  //  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  //    // Called when the user discards a scene session.
  //    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
  //    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  //  }
  
  
}

