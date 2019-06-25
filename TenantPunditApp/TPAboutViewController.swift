//
//  TPAboutViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 09/01/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class TPAboutViewController: UIViewController {

  @IBOutlet weak var aboutLabel: UILabel!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Set the about text
    if TPUser.sharedInstance.gender == "T" {
      self.aboutLabel.text = TPRemoteFetchService.sharedRemoteConfigService.configProperties!.appAbout
    }
  }

}
