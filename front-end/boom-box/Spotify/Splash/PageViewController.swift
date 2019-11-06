//
//  PageViewController.swift
//  Spotify
//
//  Created by Baily Troyer on 11/2/19.
//  Copyright © 2019 baily. All rights reserved.
//

import Foundation
import SpotifyLogin
import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
  var pageControl = UIPageControl()
  var sign_in_button = UIButton()
  var sign_up_button = UIButton()
  
  var buttonColor1 = UIColor.blue
  var buttonColor2 = UIColor.blue
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.dataSource = self
    self.delegate = self
    
    if let firstViewController = orderedViewControllers.first {
      setViewControllers([firstViewController],
                         direction: .forward,
                         animated: true,
                         completion: nil)
    }
    
    configurePageControl()
    
    let userInterfaceStyle = traitCollection.userInterfaceStyle
    if userInterfaceStyle == .dark {
      self.buttonColor1 = UIColor.white
      self.buttonColor2 = UIColor.white
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
//    SpotifyLogin.shared.getAccessToken { (accessToken, error) in
//      if error != nil {
//        // User is not logged in, show log in flow.
//        print("OH NO!")
//      } else {
//        print("ACCESS TOKEN: \(String(describing: accessToken))")
//      }
//    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
          if error != nil, token == nil {
              self?.showLoginFlow()
          }
      }
  }
  
  func showLoginFlow() {
      self.performSegue(withIdentifier: "home_to_login", sender: self)
  }
  
//  override func viewDidAppear(_ animated: Bool) {
//
//    // add button to view
////    let button = SpotifyLoginButton(viewController: self, scopes: [.streaming, .userReadTop, .playlistReadPrivate, .userLibraryRead])
////    let viewThing = UIView(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/6), width: (self.view.frame.maxX - self.view.frame.maxX/4), height: 40))
////    viewThing.center.x = self.view.center.x
////
////    self.view.addSubview(viewThing)
////    viewThing.addSubview(button)
////
////    NotificationCenter.default.addObserver(self, selector: #selector(loginSuccessful), name: .SpotifyLoginSuccessful, object: nil)
//  }
  
  @objc func loginSuccessful() {
    print("LOGGED IN")
    SpotifyLogin.shared.getAccessToken { (accessToken, error) in
      if error != nil {
        // User is not logged in, show log in flow.
        print("OH NO!")
      } else {
        print("ACCESS TOKEN: \(String(describing: accessToken))")
      }
    }
  }
  
  func configurePageControl() {
    // The total number of pages that are available is based on how many available colors we have.
    pageControl = UIPageControl(frame: CGRect(x: 0, y: (self.view.frame.maxY - self.view.frame.maxY/4.5), width: UIScreen.main.bounds.width, height: 40))
    self.pageControl.numberOfPages = orderedViewControllers.count
    self.pageControl.currentPage = 0
    self.pageControl.tintColor = UIColor.black
    self.pageControl.pageIndicatorTintColor = UIColor.white
    self.pageControl.currentPageIndicatorTintColor = UIColor.black
    self.view.addSubview(pageControl)
  }
  
  // MARK: Delegate functions
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let pageContentViewController = pageViewController.viewControllers![0]
    self.pageControl.currentPage = orderedViewControllers.firstIndex(of: pageContentViewController)!
  }
  
  func newVc(viewController: String) -> UIViewController {
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
  }
  
  lazy var orderedViewControllers: [UIViewController] = {
    return [self.newVc(viewController: "sOne"),
            self.newVc(viewController: "sTwo"),
            self.newVc(viewController: "sThree")]
  }()
  
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    // User is on the first view controller and swiped left to loop to
    // the last view controller.
    guard previousIndex >= 0 else {
      return orderedViewControllers.last
      // Uncommment the line below, remove the line above if you don't want the page control to loop.
      // return nil
    }
    
    guard orderedViewControllers.count > previousIndex else {
      return nil
    }
    
    return orderedViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = orderedViewControllers.count
    
    // User is on the last view controller and swiped right to loop to
    // the first view controller.
    guard orderedViewControllersCount != nextIndex else {
      return orderedViewControllers.first
      // Uncommment the line below, remove the line above if you don't want the page control to loop.
      // return nil
    }
    
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    
    return orderedViewControllers[nextIndex]
  }
}
