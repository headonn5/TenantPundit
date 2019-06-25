//
//  TPReview.swift
//  TenantPunditApp
//
//  Created by NishantFL on 12/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Firebase

class TPReview: NSObject {
  
  var key: String
  var houseAddress: String
  var locality: String
  var city: String
  var houseSize: String
  var houseType: String
  var feedback: String
  var houseRating: String
  var ownerRating: String
  var tenantFacebookUserID: String
  var date: String
  var rent: String
  var majorLocality: String
  var securityDeposit: String
  var tenantContact: String?
  var tenantEmail: String?
  var tenantName: String?
  var ownerName: String?
  var houseImages: [String]?
  
  override init()
  {
    self.key = ""
    self.tenantName = ""
    self.tenantContact = ""
    self.tenantEmail = ""
    self.houseAddress = ""
    self.houseType = ""
    self.locality = ""
    self.city = ""
    self.houseSize = ""
    self.feedback = ""
    self.houseRating =  ""
    self.ownerRating = ""
    self.ownerName = ""
    self.tenantFacebookUserID = ""
    self.date = ""
    self.rent = ""
    self.securityDeposit = ""
    self.majorLocality = ""
    self.houseImages = [String]()
  }
  
  init(withSnapshot snapshot:DataSnapshot)
  {
    let snapshotDictionary = snapshot.value as! [String:Any]
    self.key = snapshot.key
    self.tenantName = snapshotDictionary[TPConstants.TenantName] as? String
    self.tenantContact = snapshotDictionary[TPConstants.TenantContact] as? String
    self.tenantEmail = snapshotDictionary[TPConstants.TenantEmail] as? String
    self.houseAddress = snapshotDictionary[TPConstants.HouseAddress]! as! String
    self.locality = snapshotDictionary[TPConstants.Locality]! as! String
    self.city = snapshotDictionary[TPConstants.City]! as! String
    self.houseSize = snapshotDictionary[TPConstants.HouseSize]! as! String
    self.feedback = snapshotDictionary[TPConstants.Feedback]! as! String
    self.houseRating = snapshotDictionary[TPConstants.HouseRating]! as! String
    self.ownerRating = snapshotDictionary[TPConstants.OwnerRating]! as! String
    self.ownerName = snapshotDictionary[TPConstants.OwnerName] as? String
    self.tenantFacebookUserID = snapshotDictionary[TPConstants.TenantFacebookUserID]! as! String
    self.date = snapshotDictionary[TPConstants.Date]! as! String
    self.rent = snapshotDictionary[TPConstants.Rent]! as! String
    self.houseType = snapshotDictionary[TPConstants.HouseType]! as! String
    self.securityDeposit = snapshotDictionary[TPConstants.SecurityDeposit]! as! String
    self.majorLocality = snapshotDictionary[TPConstants.MajorLocality] as! String
    self.houseImages = snapshotDictionary[TPConstants.HouseImages] as? [String]
  }

}
