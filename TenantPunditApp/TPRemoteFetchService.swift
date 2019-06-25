//
//  TPRemoteFetchService.swift
//  TenantPunditApp
//
//  Created by NishantFL on 09/01/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class TPRemoteFetchService: NSObject {
  
  static let sharedRemoteConfigService = TPRemoteFetchService()
  var configProperties: TPRemoteConfigProperties?
  
  private override init()
  {
    // public initialiser privatised to restrict creation of instances of this class by other classes
  }
  
  func fetchRemoteConfiguration(withCompletionHandler handler: @escaping ((RemoteConfig, Error?) -> ()))
  {
    let config = configureRemoteConfig()
    
    var expirationDuration = 3600
    // If your app is using developer mode, expirationDuration is set to 0, so each fetch will
    // retrieve values from the service.
    if config.configSettings.isDeveloperModeEnabled {
      expirationDuration = 0
    }
    
    // TimeInterval is set to expirationDuration here, indicating the next fetch request will use
    // data fetched from the Remote Config service, rather than cached parameter values, if cached
    // parameter values are more than expirationDuration seconds old. See Best Practices in the
    config.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
      if status == .success {
        print("Config fetched!")
        config.activateFetched()
      } else {
        print("Config not fetched \(status)")
        print("Error: \(error?.localizedDescription ?? "No error available.")")
      }
      
      handler(config, error)
    }
  }
  
  func configureRemoteConfig() -> RemoteConfig
  {
    let remoteConfig = RemoteConfig.remoteConfig()
    let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: TPConstants.IsDeveloperModeEnabledForFirebase)
    remoteConfig.configSettings = remoteConfigSettings!
    remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    
    return remoteConfig
  }

}
