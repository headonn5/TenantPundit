//
//  FirebaseConnection.swift
//  TenantPunditApp
//
//  Created by NishantFL on 23/02/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class TPFirebaseConnection: NSObject {
  
  class func fetchReviews(forCity city: String, completionHandler: @escaping(()->()))
  {
    let ref = Database.database().reference()
    
    // Fetch reviews from db
    let reference = ref.child(TPConstants.Reviews)
    let query = reference.queryOrdered(byChild: "city").queryEqual(toValue: city)
    _ = query.observe(.value, with: { (snapshot) -> Void in
      
      // Empty the old reviews before fetching reviews from the db
      TPReviews.shared.removeAll()
      
      for dictionary in snapshot.children {
        TPReviews.shared.append(TPReview(withSnapshot: dictionary as! DataSnapshot))
      }
      completionHandler()
    })
  }
  
  class func fetchAllReviews(ref: DatabaseReference)
  {
    _ = ref.child(TPConstants.Reviews).observe(.value, with: { (snapshot) -> Void in
      var tempReviewsLists = [TPReview]()
      for dictionary in snapshot.children {
        tempReviewsLists.append(TPReview(withSnapshot: dictionary as! DataSnapshot))
      }
      TPReviews.allReviews = tempReviewsLists
    })
  }
  
  class func fetchUserData(ref: DatabaseReference, completionHandler: @escaping(()->()))
  {
    _ = ref.child(TPConstants.Users).child(FBSDKAccessToken.current().userID).child("saved_reviews").observe(.value, with: { (snapshot) -> Void in
      for dataSnapshot in snapshot.children {
        // Listen for only Bookmarked reviews callbacks
        if (dataSnapshot as! DataSnapshot).key == TPConstants.Bookmarks {
          let snapshotDictionary = (dataSnapshot as! DataSnapshot).value as! [String]
          TPUser.sharedInstance.savedReviews = snapshotDictionary
        }
      }
      // Fetch All the reviews and store it for use later
      fetchAllReviews(ref: ref)
      completionHandler()
    })
  }

}
