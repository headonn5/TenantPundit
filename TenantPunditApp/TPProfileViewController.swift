//
//  TPProfileViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 26/12/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class TPProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  let menu = ["Write a Review", "My Reviews", "About Pundit", "Feedback", "Logout"]
  let icons = ["write_review.jpg", "reviews.png", "about.png", "feedback.png", "logout.png"]
  
  override func viewDidLoad()
  {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return menu.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TPConstants.ProfileCellID, for: indexPath)
    
    let profileImageView = cell.viewWithTag(1) as! UIImageView
    let profileLabel = cell.viewWithTag(2) as! UILabel
    
    profileImageView.image = UIImage(named: icons[indexPath.row])
    profileLabel.text = menu[indexPath.row]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
  {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    return CGSize(width: self.view.frame.size.width/3, height: self.view.frame.size.height/5)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    switch indexPath.row {
    case 0:
      performSegue(withIdentifier: TPConstants.SegueProfileToWriteReview, sender: nil)
    case 1:
      performSegue(withIdentifier: TPConstants.SegueShowMyReviews, sender: nil)
    case 2:
      performSegue(withIdentifier: TPConstants.SegueShowAbout, sender: nil)
    case 3:
      performSegue(withIdentifier: TPConstants.SegueShowFeedback, sender: nil)
    case 4:
      logoutUser()
    default:
      break
    }
  }

  func logoutUser()
  {
//    let firebaseAuth = Auth.auth()
//    do {
//      try firebaseAuth.signOut()
//    } catch let signOutError as NSError {
//      print ("Error signing out: %@", signOutError)
//    }
    let facebookLoginManager = FBSDKLoginManager()
    facebookLoginManager.logOut()
    
    dismiss(animated: true, completion: nil)
  }

}
