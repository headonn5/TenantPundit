//
//  TPSavedViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 22/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class TPSavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!
  var bookmarkedReviews: [TPReview]?
  var ref: DatabaseReference!
  var storageRef = Storage.storage().reference()
  
  @IBAction func editBookmarkedReviews(_ sender: UIBarButtonItem)
  {
    if sender.title == "Done" {
      sender.title = "Edit"
      tableView.setEditing(false, animated: true)
    }
    else {
      sender.title = "Done"
      tableView.setEditing(true, animated: true)
    }
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()

    self.ref = Database.database().reference()
    
    // Set estimated row height for dynamic type cell
    tableView.estimatedRowHeight = 56.0
    
    // Remove empty cells from tableview
    tableView.tableFooterView = UIView(frame: .zero)
    
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    self.bookmarkedReviews = TPReviews.allReviews.filter{ TPUser.sharedInstance.savedReviews!.contains($0.key) }
    
    // Reload the tableview
    self.tableView.reloadData()
    
    // Control the visibility of Edit button if the list of reviews is empty
    guard let _ = TPUser.sharedInstance.savedReviews, !TPUser.sharedInstance.savedReviews!.isEmpty else {
      setInteractionModeForEditButton(withTitle: "Edit", mode: false)
      return
    }
    setInteractionModeForEditButton(mode: true)
  }
  
//  func fetchAllReviews(completionHandler: @escaping (()->()))
//  {
//    _ = self.ref.child(TPConstants.Reviews).observeSingleEvent(of: .value, with: { [weak self] (snapshot) -> Void in
//      var tempReviewsLists = [TPReview]()
//      for dictionary in snapshot.children {
//        tempReviewsLists.append(TPReview(withSnapshot: dictionary as! DataSnapshot))
//      }
//      TPReviews.allReviews = tempReviewsLists
//      completionHandler()
//    })
//  }
  
  //MARK: - UITableView DataSource Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return (bookmarkedReviews != nil) ? bookmarkedReviews!.count : 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TPConstants.SavedCellID, for: indexPath) 
    // Add border to the cell
    cell.addBorder(radius: 10.0, width: 1.0, color: UIColor(white: 0.0, alpha: 0.1).cgColor)
    
    let review = bookmarkedReviews![indexPath.section]
    let imageView = cell.viewWithTag(1) as! UIImageView
    if review.houseImages != nil {
      let reference = storageRef.child(review.houseImages![0])
      reference.downloadURL(completion: { (url, error) in
        if url != nil {
          imageView.sd_setImage(with: url!, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
        }
      })
    }
    else {
      imageView.image = UIImage(named: "no-image-placeholder.jpg")
    }
    
    let localityLabel = cell.viewWithTag(2) as! UILabel
    localityLabel.text = review.majorLocality
    
    let ownerReviewLabel = cell.viewWithTag(3) as! UILabel
    ownerReviewLabel.text = review.ownerRating
    
    let houseReviewLabel = cell.viewWithTag(4) as! UILabel
    houseReviewLabel.text = review.houseRating
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 200.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: TPConstants.SegueSavedToReviewDetail, sender: self)
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if tableView.isEditing {
      return .delete
    }
    return .none
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if tableView.isEditing && editingStyle == .delete {
      _ = bookmarkedReviews!.remove(at: indexPath.section)
      tableView.deleteSections([indexPath.section], with: .fade)
      // Reset the new value of bookmarks in Firebase
      let reviewKeys = bookmarkedReviews!.map{ $0.key }
      updateBookmarkedReviews(reviewKeys)
      guard !bookmarkedReviews!.isEmpty else {
        setInteractionModeForEditButton(withTitle: "Edit", mode: false)
        return
      }
      setInteractionModeForEditButton(mode: true)
    }
  }
  
  func setInteractionModeForEditButton(withTitle title: String? = nil, mode: Bool)
  {
    if (title != nil) {
      self.navigationItem.rightBarButtonItem?.title = title
    }
    self.navigationItem.rightBarButtonItem?.isEnabled = mode
  }
  
  func updateBookmarkedReviews(_ reviewKeys: [String])
  {
    let data: [String:[String]] = ["bookmarks":reviewKeys]
    if reviewKeys.isEmpty {
      self.ref.child(TPConstants.Users).child(FBSDKAccessToken.current().userID).child("saved_reviews").removeValue(completionBlock: { (error, dbRef) in
        TPUser.sharedInstance.savedReviews = reviewKeys
      })
    }
    else {
      self.ref.child(TPConstants.Users).child(FBSDKAccessToken.current().userID).child("saved_reviews").setValue(data)
    }
    
    
//    guard !bookmarkedReviews!.isEmpty else {
//      tableView.isEditing = false
//      return
//    }
//    tableView.isEditing = true
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10.0
  }
  
//  hei
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    view.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    return headerView
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == TPConstants.SegueSavedToReviewDetail {
      let reviewDetailController = segue.destination as! TPReviewDetailViewController
      if bookmarkedReviews != nil {
        reviewDetailController.review = bookmarkedReviews![(tableView.indexPathForSelectedRow?.section)!]
      }
    }
  }

}
