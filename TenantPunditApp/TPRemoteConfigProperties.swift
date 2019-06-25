//
//  TPRemoteConfiguration.swift
//  TenantPunditApp
//
//  Created by NishantFL on 09/01/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class TPRemoteConfigProperties: NSObject {
  
  var appAbout = ""
  var appAboutMale = ""
  var appAboutFemale = ""
  var appItunesID = ""
  var isUpdateAvailable = false
    
  init(withConfig config: RemoteConfig)
  {
    appAbout = config["app_about"].stringValue!
    appAboutMale = config["app_about_male"].stringValue!
    appAboutFemale = config["app_about_female"].stringValue!
    appItunesID = config["app_itunes_id"].stringValue!
    isUpdateAvailable = config["is_update_available"].boolValue
  }

}
