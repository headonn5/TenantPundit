//
//  AppDelegate.swift
//  TenantPunditApp
//
//  Created by NishantFL on 11/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
    [UIApplicationLaunchOptionsKey: Any]?) -> Bool
  {
    FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    FirebaseApp.configure()
    GMSPlacesClient.provideAPIKey("AIzaSyAAptdsVquczXLtrjP2uc162lJ8zvO6Ilg")
    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
  {
    let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.
      sourceApplication] as! String, annotation: options[.annotation])
    
    return handled
  }
  
}

