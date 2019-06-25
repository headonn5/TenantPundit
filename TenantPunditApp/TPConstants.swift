//
//  Constants.swift
//  TenantPunditApp
//
//  Created by NishantFL on 11/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit

struct TPConstants {
  static let Reviews = "reviews"
  static let Users = "users"
  static let Bookmarks = "bookmarks"
  static let AppFeedback = "app_feedback"
  
  static let TenantEmail = "tenant_email"
  static let TenantName = "tenant_name"
  static let TenantFacebookUserID = "tenant_facebook_user_id"
  static let HouseAddress = "house_address"
  static let Locality = "locality"
  static let City = "city"
  static let OwnerName = "owner_name"
  static let TenantContact = "tenant_contact"
  static let HouseImages = "house_images"
  static let HouseSize = "house_size"
  static let Feedback = "feedback"
  static let HouseRating = "house_rating"
  static let OwnerRating = "owner_rating"
  static let Rent = "rent"
  static let Date = "date"
  static let HouseType = "house_type"
  static let SecurityDeposit = "security_deposit"
  static let MajorLocality = "major_locality"
  
  static let SegueTab = "showTabController"
  static let SegueReviewDetail = "showReviewDetail"
  static let SegueMyReviewDetail = "showMyReviewDetail"
  static let SegueShowImage = "showImage"
  static let SegueShowCity = "showCityList"
  static let SegueShowMyReviews = "showMyReviews"
  static let SegueShowAbout = "showAbout"
  static let SegueShowLogin = "showLoginScreen"
  static let SegueProfileToWriteReview = "showWriteReviewFromProfile"
  static let SegueEditReview = "showEditReview"
  static let SegueSavedToReviewDetail = "showReviewDetailFromSaved"
  static let SegueShowFeedback = "showFeedback"
  
  static let ReviewCellID = "reviewCell"
  static let MyReviewsCellID = "myReviewsCell"
  static let SavedCellID = "savedCell"
  static let HouseDescriptionCellID = "houseDescriptionCell"
  static let CityTableViewCellID = "cityCell"
  static let SelectCityCellID = "cityCollectionViewCell"
  static let ProfileCellID = "profileCell"
  
  static let PageSlideController = "tpPageController"
  static let ImageSliderController = "tpImageSliderController"
  static let FullImageSliderController = "tpFullImageSliderController"
  
  static let ErrorAlertTitle = "Error"
  static let SuccessAlertTitle = "Success"
  static let ErrorAlertActionTitle = "OK"
  static let ErrorEmptyTextField = "Please fill all the fields marked with *"
  static let ErrorAlreadyReviewed = "You have already reviewed this house once"
  static let SubmitReviewSuccess = "Review posted successfully."
  static let SubmitFeedbackSuccess = "Thank you for your feedback. We'll look into it."
  static let SubmitLikedTitle = "Greetings"
  static let SubmitLikedMessage = "Thank you for liking us. Please spare a moment to rate us in the App Store as well."
  
  static let NotMentioned = "Not Mentioned"
  
  static let CityList = ["Bengaluru", "Delhi", "Mumbai", "Gurgaon", "Pune", "Chennai", "Chandigarh", "Hyderabad"]
  static let CityImagesList = ["bangalore_guitar.jpg", "india_gate_delhi.jpg", "mumbai_terminus.jpg", "gurgaon_kod.jpg", "pune_tunnel.jpg", "chennai_beach.jpg", "chandigarh_green.jpg", "hyderabad_charminar.jpg"]
  
  static let CityPreference = "cityPreference"
  static let DefaultCityPref = "Delhi"

  
  static let PlaceholderFeedback = "Additional Comments *"
  
  static let DelayDuration = 2.0
  
  static let PurpleColor = UIColor(red: 94.0/255.0, green: 2.0/255.0, blue: 49.0/255.0, alpha: 1.0)
  static let GrayWhiteColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
  static let LightBrownColor = UIColor(red: 209.0/255.0, green: 204.0/255.0, blue: 200.0/255.0, alpha: 1.0)
  
  static let IsDeveloperModeEnabledForFirebase = false
  static let ItunesUrlKey = "iTunesUrl"

}
