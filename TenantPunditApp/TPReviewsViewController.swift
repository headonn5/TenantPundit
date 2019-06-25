//
//  TPReviewsViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 12/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FBSDKLoginKit

class TPReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, TPSelectCityDelegate, TPReviewTableCellDelegate {

  @IBOutlet weak var tableview: UITableView!
  @IBOutlet weak var cityBtn: UIBarButtonItem!
  @IBOutlet weak var searchBar: UISearchBar!
  var isSearchActive : Bool = false
  var filteredReviews:[TPReview] = []
  var reviews: [TPReview]?
  var refreshControl: UIRefreshControl = UIRefreshControl()
  var ref: DatabaseReference!
  var storageRef = Storage.storage().reference()
  fileprivate var _reviewsRefHandle: DatabaseHandle?
  let defaultCityPref = UserDefaults.standard.value(forKey: TPConstants.CityPreference)!
  var bookmarkedReviews: [String]!
  var imageCache = [String:UIImage]()
  
  
  @IBAction func selectCity(_ sender: UIBarButtonItem)
  {
    performSegue(withIdentifier: TPConstants.SegueShowCity, sender: self)
  }
  
  @IBAction func bookmarkReview(_ sender: UIButton)
  {
    // Handle button action apart from bookmarkAdded functionality, because for that we have a delegate function
  }
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.ref = Database.database().reference()
    
    cityBtn.title = defaultCityPref as? String
    
    // Tweak to change color of placeholder text in search bar
    let textField = searchBar.value(forKey: "_searchField") as! UITextField
    textField.setValue(UIColor.darkGray, forKeyPath: "_placeholderLabel.textColor")
    
//    let parentController = self.navigationController?.parent as! TPTabController
    self.reviews = TPReviews.shared
    
    // Set estimated row height for dynamic type cell
    self.tableview.estimatedRowHeight = 56.0
      
    // Remove empty cells from tableview
    self.tableview.tableFooterView = UIView(frame: .zero)
    
    refreshControl.addTarget(self, action: #selector(didRefresh(sender:)), for: .valueChanged)
    self.tableview.addSubview(refreshControl)
    
    if TPRemoteFetchService.sharedRemoteConfigService.configProperties!.isUpdateAvailable {
      showUpdateAlert(withTitle: "Update Alert", message: "Please update your app to enjoy more benefits.")
    }
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    // Update bookmarked reviews whenever the view appears
    guard let _ = TPUser.sharedInstance.savedReviews else {
      bookmarkedReviews = [String]()
      return
    }
    bookmarkedReviews = TPUser.sharedInstance.savedReviews!
  }
  
  func showUpdateAlert(withTitle title: String, message: String)
  {
    let messageAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
      self.updateApp(appId: TPRemoteFetchService.sharedRemoteConfigService.configProperties!.appItunesID, completion: { (isSuccess) in
        print("isSuccess \(isSuccess)")
      })
    })
    messageAlertController.addAction(okAction)
    self.present(messageAlertController, animated: true, completion: nil)
  }
  
  func updateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
    guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
      completion(false)
      return
    }
    completion(UIApplication.shared.openURL(url))
  }
  
//  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    self.view.endEditing(true)
//  }
  
  func bookmarkAdded(_ isBookmarkAdded: Bool, forReview review: TPReview?)
  {
    if let index = bookmarkedReviews.index(of: review!.key) {
      bookmarkedReviews.remove(at: index)
    }
    else {
      bookmarkedReviews.append(review!.key)
    }
    let data: [String:[String]] = ["bookmarks":bookmarkedReviews]
    
    if bookmarkedReviews.isEmpty {
      self.ref.child(TPConstants.Users).child(FBSDKAccessToken.current().userID).child("saved_reviews").removeValue(completionBlock: { (error, dbRef) in
        TPUser.sharedInstance.savedReviews = self.bookmarkedReviews
      })
    }
    else {
      self.ref.child(TPConstants.Users).child(FBSDKAccessToken.current().userID).child("saved_reviews").setValue(data)
    }
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
  {
//    for (TMBContact *contact in _tmbContacts) {
//      NSRange contactEmailRange = [contact.emailID rangeOfString:searchText options:NSCaseInsensitiveSearch];
//      NSRange contactNameRange = [contact.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
//      if (contactEmailRange.location != NSNotFound || contactNameRange.location != NSNotFound) {
//        [_filteredContacts addObject:contact];
//      }
//    }
    
//    for review in self.reviews! {
//      let address = review.houseAddress.range(of: searchText)
//      if
//
//    }
    if(searchText.count == 0){
      isSearchActive = false;
    } else {
      isSearchActive = true;
      filteredReviews = self.reviews!.filter({
        return ($0.locality.range(of: searchText, options: .caseInsensitive) != nil)
      })
    }
    
//    filteredReviews = self.reviews!.filter({ (text) -> Bool in
//      let tmp: NSString = text
//      let range =
//      let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
//      return range.location != NSNotFound
//    })
    
    self.tableview.reloadData()
  }
  
  deinit
  {
    if let refHandle = _reviewsRefHandle  {
      self.ref.child(TPConstants.Reviews).removeObserver(withHandle: refHandle)
    }
  }
  
  func didRefresh(sender: UIRefreshControl)
  {
    // Generally, we would not get any new results with the refresh call, as listener in TPFirebaseConnection class
    // is always listening for new/updated reviews. This is not a listener, so will fetch the reviews only once.
    // This function is called to ensure if the listener fails in odd circumstances, user can get updated reviews.
    fetchReviews(fromCity: cityBtn.title!) {
      DispatchQueue.main.async {
        sender.endRefreshing()
        // Remove all cached images
        self.imageCache.removeAll()
        self.tableview.reloadData()
      }
    }
  }
  
  func fetchReviews(fromCity city: String, completionHandler: @escaping (() -> ()))
  {
    let reference = self.ref.child(TPConstants.Reviews)
    let query = reference.queryOrdered(byChild: "city").queryEqual(toValue: city)
    query.observeSingleEvent(of: .value, with: { [weak self] (snapshot) -> Void in
      guard let strongSelf = self else { return }
      var tempReviewsLists = [TPReview]()
      for dictionary in snapshot.children {
        tempReviewsLists.append(TPReview(withSnapshot: dictionary as! DataSnapshot))
      }
      TPReviews.shared = tempReviewsLists
      strongSelf.reviews = TPReviews.shared
      
      // Update bookmarked reviews as well whenever reviews are fetched.
      // The listener for user in TPFirebaseConnection changes the shared instance of TPUser
      // when list of bookmarked reviews changes.
      strongSelf.bookmarkedReviews = TPUser.sharedInstance.savedReviews!
      
      completionHandler()
    })
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if isSearchActive {
      return filteredReviews.count
    }
    return (self.reviews != nil) ? self.reviews!.count : 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return 1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: TPConstants.ReviewCellID, for: indexPath) as! TPReviewTableCell
    
    // Add border to the cell
    cell.addBorder(radius: 10.0, width: 1.0, color: UIColor(white: 0.0, alpha: 0.1).cgColor)
    
    // Add itself as delegate of TPReviewTableCell
    cell.delegate = self

    var review: TPReview?
    if isSearchActive {
      review = filteredReviews[indexPath.section]
    }
    else {
      review = self.reviews?[indexPath.section]
    }
    cell.review = review
    let imageView = cell.viewWithTag(1) as! UIImageView
    
    if review?.houseImages != nil {
      let reference = storageRef.child(review!.houseImages![0])
      if let image = self.imageCache[review!.houseImages![0]] {
        imageView.image = image
      }
      else {
        reference.downloadURL(completion: { (url, error) in
          if url != nil {
            //          imageView.sd_setImage(with: url!, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
            SDWebImageManager.shared().imageDownloader?.downloadImage(with: url!, options: .useNSURLCache , progress: nil, completed: { (image, data, error, isDownloaded) in
              if error == nil {
                self.imageCache[review!.houseImages![0]] = image!
                if let cellToUpdate = tableView.cellForRow(at: indexPath) {
                  let cellImageView: UIImageView = cellToUpdate.viewWithTag(1) as! UIImageView
                  cellImageView.image = image!
                }
              }
            })
          }
        })
      }
    }
    else {
      imageView.image = UIImage(named: "no-image-placeholder.jpg")
    }
    
    if bookmarkedReviews.contains(review!.key) {
      cell.likeButton.setImage(UIImage(named: "bookmark_black.png"), for: .normal)
    }
    else {
      cell.likeButton.setImage(UIImage(named: "bookmark_white.png"), for: .normal)
    }
//    addTranslucentView(toView: imageView, onCell: cell)
    
    let areaLabel = cell.viewWithTag(2) as! UILabel
//    areaLabel.text = "\(review?.locality ?? "")"
    areaLabel.text = "\(review?.majorLocality ?? "")"
    
    let houseRatingLabel = cell.viewWithTag(3) as! UILabel
    houseRatingLabel.text = review!.houseRating

    let ownerRatingLabel = cell.viewWithTag(4) as! UILabel
    ownerRatingLabel.text = review!.ownerRating
    
    return cell
  }
  
  func addTranslucentView(toView view: UIView, onCell cell: UITableViewCell)
  {
    if view.subviews.count < 1 {
      let translucentView = UIView(frame: (cell.contentView.bounds))
      translucentView.backgroundColor = .black
      translucentView.isOpaque = false
      translucentView.alpha = 0.2
      translucentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.addSubview(translucentView)
    }
  }
  
//  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//    isSearchActive = true;
//  }
//  
//  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//    isSearchActive = false;
//  }
//  
//  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//    isSearchActive = false;
//  }
//  
//  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//    isSearchActive = false;
//  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10.0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 230.0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    view.backgroundColor = TPConstants.GrayWhiteColor
    return headerView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    // Dismiss the keyboard if it is shown while searching the text
    if searchBar.isFirstResponder {
      searchBar.resignFirstResponder()
      return
    }
    performSegue(withIdentifier: TPConstants.SegueReviewDetail, sender: self)
  }
  
  func didSelectCity(cityName: String)
  {
    cityBtn.title = cityName
    TPFirebaseConnection.fetchReviews(forCity: cityName) {
      DispatchQueue.main.async {
        self.reviews = TPReviews.shared
        
        // Update bookmarked reviews as well whenever reviews are fetched.
        // The listener for user in TPFirebaseConnection changes the shared instance of TPUser
        // when list of bookmarked reviews changes.
        self.bookmarkedReviews = TPUser.sharedInstance.savedReviews!
        self.tableview.reloadData()
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let reviewDetailController = segue.destination as? TPReviewDetailViewController {
      if isSearchActive {
        reviewDetailController.review = self.filteredReviews[(self.tableview.indexPathForSelectedRow?.section)!]
      }
      else {
        reviewDetailController.review = self.reviews![(self.tableview.indexPathForSelectedRow?.section)!]
      }
    }
    
    if let selectCityController = segue.destination as? TPSelectCityViewController {
      selectCityController.delegate = self
    }
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  

}

