//
//  TPUser.swift
//  TenantPunditApp
//
//  Created by NishantFL on 09/01/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit
import Firebase

class TPUser: NSObject {
  
  static let sharedInstance = TPUser()
  
  var name: String = ""
  var gender: String = ""
  
  var savedReviews: [String]?
  
  private override init()
  {
    self.savedReviews = [String]()
  }
  
//  init(withSnapshot snapshot:DataSnapshot)
//  {
//    let snapshotDictionary = snapshot.value as! [String:Any]
//    self.savedReviews = snapshotDictionary[TPConstants.Bookmarks] as? [String]
//  }
  

}
