//
//  MyReviewsViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 14/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class TPMyReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableview: UITableView!
  
  var myReviews: [TPReview]?
  var refreshControl: UIRefreshControl = UIRefreshControl()
  var ref: DatabaseReference!
  var storageRef = Storage.storage().reference()
  fileprivate var _reviewsRefHandle: DatabaseHandle?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.ref = Database.database().reference()
    myReviews = TPReviews.allReviews.filter{$0.tenantFacebookUserID == FBSDKAccessToken.current().userID}
    
    // If there are no reviews fetched already, fetch reviews
//    if myReviews!.isEmpty {
//      fetchReviews {
//        DispatchQueue.main.async {
//          self.tableview.reloadData()
//        }
//      }
//    }

    // Set estimated row height for dynamic type cell
    self.tableview.estimatedRowHeight = 56.0
    
    // Remove empty cells from tableview
    self.tableview.tableFooterView = UIView(frame: .zero)
    
    refreshControl.addTarget(self, action: #selector(didRefresh(sender:)), for: .valueChanged)
    self.tableview.addSubview(refreshControl)
    
    // Control the visibility of Edit button if the list of reviews is empty
    guard let _ = myReviews, myReviews?.count != 0 else {
      setInteractionModeForEditButton(withTitle: "Edit", mode: false)
      return
    }
    setInteractionModeForEditButton(mode: true)
  }
  
  deinit
  {
    if let refHandle = _reviewsRefHandle  {
      self.ref.child(TPConstants.Reviews).removeObserver(withHandle: refHandle)
    }
  }
  
  @IBAction func editReview(_ sender: UIBarButtonItem)
  {
    if sender.title == "Done" {
      sender.title = "Edit"
      self.tableview.setEditing(false, animated: true)
    }
    else {
      sender.title = "Done"
      self.tableview.setEditing(true, animated: true)
    }
  }
  @IBAction func modifyMyReview(_ sender: UIButton)
  {
    performSegue(withIdentifier: TPConstants.SegueEditReview, sender: sender)
  }
  
  func didRefresh(sender: UIRefreshControl)
  {
    myReviews = TPReviews.allReviews.filter{$0.tenantFacebookUserID == FBSDKAccessToken.current().userID}
//    fetchReviews {
//      DispatchQueue.main.async {
        sender.endRefreshing()
        self.tableview.reloadData()
//      }
//    }
  }
  
//  func fetchReviews(completionHandler: @escaping (() -> ()))
//  {
//    let query = self.ref.child(TPConstants.Reviews).queryOrdered(byChild: TPConstants.TenantFacebookUserID).queryEqual(toValue:
//      FBSDKAccessToken.current().userID)
//    _reviewsRefHandle = query.observe(.value, with: { [weak self] (snapshot) -> Void in
//      guard let strongSelf = self else { return }
//      var tempReviewsLists = [TPReview]()
//      for dictionary in snapshot.children {
//        tempReviewsLists.append(TPReview(withSnapshot: dictionary as! DataSnapshot))
//      }
//      strongSelf.myReviews = tempReviewsLists
//      completionHandler()
//    })
//  }
  
  func deleteDataFromFirebase(review: TPReview!)
  {
    self.ref.child(TPConstants.Reviews).child(review.key).removeValue { (error, dbRef) in
      if (error != nil) {
        print("Failed to remove data from firebase with error \(error!.localizedDescription)")
      }
    }
    guard !myReviews!.isEmpty else {
      setInteractionModeForEditButton(withTitle: "Edit", mode: false)
      return
    }
    setInteractionModeForEditButton(mode: true)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return (self.myReviews != nil) ? self.myReviews!.count : 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return 1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = self.tableview.dequeueReusableCell(withIdentifier: TPConstants.MyReviewsCellID, for: indexPath)
    // Add border to the cell
    cell.addBorder(radius: 10.0, width: 1.0, color: UIColor(white: 0.0, alpha: 0.1).cgColor)
    
    let myReview = myReviews?[indexPath.section]
    let imageView = cell.viewWithTag(1) as! UIImageView
    if myReview?.houseImages != nil {
      let reference = storageRef.child(myReview!.houseImages![0])
      reference.downloadURL(completion: { (url, error) in
        if url != nil {
          imageView.sd_setImage(with: url!, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
        }
      })
    }
    else {
      imageView.image = UIImage(named: "no-image-placeholder.jpg")
    }
    
//    addTranslucentView(toView: imageView, onCell: cell)
    
    let label = cell.viewWithTag(2) as! UILabel
    label.text = myReview?.locality
    
    return cell
  }
  
//  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    return true
//  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
  {
    if tableView.isEditing {
      return .delete
    }
    return .none
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
  {
    if tableView.isEditing && editingStyle == .delete {
      let review = myReviews?.remove(at: indexPath.section)
      tableView.deleteSections([indexPath.section], with: .fade)
      // Delete data from Firebase
      deleteDataFromFirebase(review: review!)
    }
  }
  
  func addTranslucentView(toView view: UIView, onCell cell: UITableViewCell)
  {
    let translucentView = UIView(frame: (cell.contentView.bounds))
    translucentView.backgroundColor = .black
    translucentView.isOpaque = false
    translucentView.alpha = 0.2
    translucentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(translucentView)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10.0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 200.0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    view.backgroundColor = TPConstants.GrayWhiteColor
    return headerView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    performSegue(withIdentifier: TPConstants.SegueMyReviewDetail, sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == TPConstants.SegueMyReviewDetail {
      let reviewDetailController = segue.destination as! TPReviewDetailViewController
      if self.myReviews != nil {
        reviewDetailController.review = self.myReviews![(self.tableview.indexPathForSelectedRow?.section)!]
      }
    }
    else if segue.identifier == TPConstants.SegueEditReview {
      let writeReviewController = segue.destination as! TPWriteReviewViewController
      if self.myReviews != nil && sender is UIButton {
        guard let cell = (sender as! UIButton).superview?.superview as? UITableViewCell else {
          return
        }
        let indexPath = tableview.indexPath(for: cell)
        writeReviewController.review = self.myReviews![indexPath!.section]
      }
    }
  }
  
  func setInteractionModeForEditButton(withTitle title: String? = nil, mode: Bool)
  {
    if (title != nil) {
      self.navigationItem.rightBarButtonItem?.title = title
    }
    self.navigationItem.rightBarButtonItem?.isEnabled = mode
  }

}
