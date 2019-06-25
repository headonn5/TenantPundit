//
//  TPReviewDetailViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 14/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import FirebaseStorage

struct HouseDetail {
  var heading: String!
  var info: String!
}

class TPReviewDetailViewController: UIViewController, UIPageViewControllerDataSource, UITableViewDataSource, TPImageSliderViewControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var review: TPReview?
  var pageViewController: UIPageViewController?
  var houseParamsList: [HouseDetail]?
  var contentImages: [URL]?
  var selectedImageIndex: Int = 0
  let storageRef = Storage.storage().reference()
  @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    guard review != nil else {
      print("Error: Review is nil")
      return
    }
    
    if review!.houseImages != nil {
      var tempImageUrls: [URL] = []
      let endingDelimiter = review!.houseImages!.count
      for i in stride(from: 0, to: endingDelimiter, by: 1) {
        let reference = storageRef.child(review!.houseImages![i])
        reference.downloadURL(completion: { (url, error) in
          if url != nil {
            tempImageUrls.append(url!)
            if tempImageUrls.count == endingDelimiter {
              self.contentImages = tempImageUrls
              self.createPageViewController()
              self.setUpPageViewController()
            }
          }
        })
      }
    }
    else {
      self.tableViewTopConstraint.constant = 0.0
    }
    
    // Set estimated row height for dynamic type cell
    self.tableView.estimatedRowHeight = 56.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    
    // Remove empty cells from tableview
    self.tableView.tableFooterView = UIView(frame: .zero)
    self.tableView.tableHeaderView = UIView(frame: .zero)
    
    guard let _ = review else {
      return
    }
    
    let ownerName = (review!.ownerName != nil && review!.ownerName != "") ? review!.ownerName : TPConstants.NotMentioned
    let tenantName = (review!.tenantName != nil && review!.tenantName != "") ? review!.tenantName : TPConstants.NotMentioned
    
    // Build the list of house details parameters
    houseParamsList = [HouseDetail]()
    houseParamsList!.append(HouseDetail(heading: "Type", info: review!.houseType))
    houseParamsList!.append(HouseDetail(heading: "Address", info: review!.houseAddress))
    houseParamsList!.append(HouseDetail(heading: "Locality", info: review!.locality))
    houseParamsList!.append(HouseDetail(heading: "City", info: review!.houseType))
    houseParamsList!.append(HouseDetail(heading: "Bedrooms", info: review!.houseSize))
    houseParamsList!.append(HouseDetail(heading: "Owner's Rating", info: review!.ownerRating))
    houseParamsList!.append(HouseDetail(heading: "House's Rating", info: review!.houseRating))
    houseParamsList!.append(HouseDetail(heading: "Owner's Name", info: ownerName!))
    houseParamsList!.append(HouseDetail(heading: "Tenant's Name", info: tenantName!))
    houseParamsList!.append(HouseDetail(heading: "Rent", info: review!.rent))
    houseParamsList!.append(HouseDetail(heading: "Security Deposit", info: review!.securityDeposit))
    houseParamsList!.append(HouseDetail(heading: "Feedback :", info: ""))
    houseParamsList!.append(HouseDetail(heading: review!.feedback, info: ""))
  }
  
  func createPageViewController()
  {
    let pageController = storyboard?.instantiateViewController(withIdentifier: TPConstants.PageSlideController) as!
    TPPageViewController
    pageController.view.frame = CGRect(x: 0.0, y: 10.0, width: self.view.frame.size.width, height: 250)
    pageController.dataSource = self
    
    if contentImages != nil && contentImages!.count > 0 {
      let firstController = getItemController(0)!
      let startingViewController = [firstController]
      
      pageController.setViewControllers(startingViewController, direction: .forward, animated: true, completion: nil)
      self.pageViewController = pageController
      addChildViewController(self.pageViewController!)
      self.view.addSubview(self.pageViewController!.view)
      self.pageViewController?.didMove(toParentViewController: self)
    }
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController:
    UIViewController) -> UIViewController?
  {
    let imageController = viewController as! TPImageSliderViewController
    if imageController.imageIndex > 0 {
      return getItemController(imageController.imageIndex - 1)
    }
    
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController:
    UIViewController) -> UIViewController?
  {
    let imageController = viewController as! TPImageSliderViewController
    if contentImages != nil && imageController.imageIndex+1 < contentImages!.count {
      return getItemController(imageController.imageIndex + 1)
    }
    
    return nil
  }
  
  func setUpPageViewController()
  {
    let pageControlAppearance = UIPageControl.appearance()
    
    pageControlAppearance.pageIndicatorTintColor = UIColor.black
    pageControlAppearance.currentPageIndicatorTintColor = UIColor.white
    pageControlAppearance.backgroundColor = UIColor.clear
    pageControlAppearance.alpha = 0.8
    pageControlAppearance.isOpaque = false

//    pageControlAppearance = UIPageControl(frame: CGRect(x: 110, y: 55, width: 100, height: 100))
//    pageControl.pageIndicatorTintColor = UIColor.lightGray
//    pageControl.currentPageIndicatorTintColor = UIColor.red
//    pageControl.backgroundColor = UIColor.clear
//    pageControl.isOpaque = false
    
//    pageControl.currentPage=(currentController() as! TPImageSliderViewController).itemIndex
//    self.view.addSubview(pageControl)
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int
  {
    return (contentImages != nil) ? contentImages!.count : 0
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int
  {
    return 0
  }
  
  func currentController() -> UIViewController?
  {
    if self.pageViewController?.viewControllers?.count == 0 {
      return self.pageViewController!.viewControllers![0]
    }
    return nil
  }
  
  func getItemController(_ itemIndex: Int) -> TPImageSliderViewController?
  {
    if contentImages != nil {
      if itemIndex < contentImages!.count {
        let pageImageController = storyboard?.instantiateViewController(withIdentifier: TPConstants.ImageSliderController) as!
        TPImageSliderViewController
        pageImageController.delegate = self
        pageImageController.imageIndex = itemIndex
        pageImageController.imageUrl = contentImages![itemIndex]
        
        return pageImageController
      }
    }
    
    return nil
  }
  
  //MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    let imageController = segue.destination as! TPImageDetailViewController
    imageController.imageIndex = self.selectedImageIndex
    imageController.contentImages = self.contentImages
  }
  
  //MARK: - TPImageSliderViewControllerDelegate Delegate Methods
  func didTapImageToView(imageIndex: Int) {
    self.selectedImageIndex = imageIndex
    performSegue(withIdentifier: TPConstants.SegueShowImage, sender: self)
  }
  
  //MARK: - UITableView DataSource Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (houseParamsList != nil) ? houseParamsList!.count : 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TPConstants.HouseDescriptionCellID, for: indexPath) as!
    TPReviewDetailTableCell
    
    let parameter = cell.viewWithTag(1) as! UILabel
    parameter.text = houseParamsList![indexPath.row].heading
    
    let description = cell.viewWithTag(2) as! UILabel
    description.text = houseParamsList![indexPath.row].info
    
    // Removed Re-Aligning of feedback description for Feedback data, as it was causing the other labels to realign
    // when the table view cells were being reused.
    
    return cell
  }
  
  
}
