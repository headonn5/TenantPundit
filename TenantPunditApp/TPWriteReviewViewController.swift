//
//  TPWriteReviewViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 14/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GooglePlaces
import SDWebImage

class TPWriteReviewViewController: TPBaseViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, TPPhotoAlbumDelegate, TQStarRatingDelegate {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var houseTypeField: UITextField!
  @IBOutlet weak var homeAddressField: UITextField!
  @IBOutlet weak var areaField: UITextField!
  @IBOutlet weak var cityField: UITextField!
  @IBOutlet weak var homeSizeField: UITextField!
  @IBOutlet weak var rentField: UITextField!
  @IBOutlet weak var securityDepositField: UITextField!
  @IBOutlet weak var feedbackTextView: UITextView!
  @IBOutlet weak var imageView1: UIImageView!
  @IBOutlet weak var imageView2: UIImageView!
  @IBOutlet weak var imageView3: UIImageView!
  @IBOutlet weak var imageView4: UIImageView!
  @IBOutlet weak var ratingView: TQStarRatingView!
  @IBOutlet weak var ownerRatingView: TQStarRatingView!
  @IBOutlet weak var ownerRatingLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var ownerNameField: UITextField!
  @IBOutlet weak var tenantNameField: UITextField!
  private lazy var toBeUploadedImageUrls = [String]()
  var review: TPReview?
  var pickerView: UIPickerView!
  var selectedImages: [HouseImage]?
  var majorLocality = ""
  
  
  @IBAction func addPictures(_ sender: UIButton)
  {
//    self.selectImages()
    self.performSegue(withIdentifier: "showPhotoLibrary", sender: self)
  }
  
  var activeField: UITextField?
  let houseTypeList = ["PG/Hostel", "Apartment", "Individual House"]
  let bhkList = ["1 BHK", "2 BHK", "3 BHK", "4 or more BHK"]
  let cityList = TPConstants.CityList
  var houseAddress = ""
  var ref: DatabaseReference!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.ref = Database.database().reference()
    // Set custom border for text view
    feedbackTextView.addBorder(radius: 10.0, width: 1.0, color: UIColor(white: 0.0, alpha: 0.1).cgColor)
    initializeHouseTypeInputView()
    registerForKeyboardNotifications()
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
    self.view.addGestureRecognizer(tapGestureRecognizer)
    
    // Set the delegate for TQStarRatingView
    ratingView.delegate = self
    ownerRatingView.delegate = self
    
    // Add placeholder text for text view
    addPlaceholderText()
    
    // This means that user has come to edit the review
    if review != nil {
      refillData()
    }
  }
  
  func addPlaceholderText()
  {
    feedbackTextView.text = TPConstants.PlaceholderFeedback
    feedbackTextView.textColor = UIColor.lightGray
  }
  
  func refillData()
  {
    houseTypeField.text = review!.houseType
    homeAddressField.text = review!.houseAddress
    areaField.text = review!.locality
    cityField.text = review!.city
    homeSizeField.text = review!.houseSize
    rentField.text = review!.rent
    securityDepositField.text = review!.securityDeposit
    feedbackTextView.text = review!.feedback
    ratingLabel.text = review!.houseRating
    ownerRatingLabel.text = review!.ownerRating
    majorLocality = review!.majorLocality
    if let ownerName = review!.ownerName {
      ownerNameField.text = ownerName
    }
    if let tenantName = review!.tenantName {
      tenantNameField.text = tenantName
    }
    // Refill Images by downloading from Firebase Storage
    guard let houseImages = review?.houseImages else {
      return
    }
    for (index, imageUrlString) in houseImages.enumerated() {
      let reference = Storage.storage().reference().child(imageUrlString)

      switch index {
      case 0:
        reference.downloadURL(completion: { (url, error) in
          self.imageView2.sd_setImage(with: url, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
        })
      case 1:
        reference.downloadURL(completion: { (url, error) in
          self.imageView3.sd_setImage(with: url, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
        })
      case 2:
        reference.downloadURL(completion: { (url, error) in
          self.imageView1.sd_setImage(with: url, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
        })
      case 3:
        reference.downloadURL(completion: { (url, error) in
          self.imageView4.sd_setImage(with: url, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
        })
      default:
        break
      }
    }
  }
  
  func deleteImagesFromFirebaseStorage(_ completionHandler: @escaping ((Bool, Error?) -> ()))
  {
    let houseImages = review?.houseImages
    if houseImages == nil {
      completionHandler(true, nil)
    }
    else {
      for (index, imageUrlString) in houseImages!.enumerated() {
        let reference = Storage.storage().reference().child(imageUrlString)
        reference.delete(completion: { (error) in
          if error != nil {
            completionHandler(false, error!)
          }
          else if index == houseImages!.count-1 {
            completionHandler(true, nil)
          }
        })
      }
    }
  }
  
  func dismissKeyboard(_ sender: UITapGestureRecognizer)
  {
    self.view.endEditing(true)
  }
  
  func sendMessage(toChild child: String, withData data: [String:Any])
  {
    // Display the spinner
    let spinner = UIViewController.displaySpinner(onView: self.view)
    
    if selectedImages != nil {
      // Delete old images first and then upload the new ones
      deleteImagesFromFirebaseStorage({ (isSuccess, error) in
        if !isSuccess, error == nil {
          // Unsuccessful submit. Show Alert
          self.showMessagePrompt(withTitle: TPConstants.ErrorAlertTitle, message: error!.localizedDescription)
        }
        else {
          self.sendReviewsWithImages(toChild: child, withData: data, completionHandler: { (error, dbRef) in
            if (error != nil) {
              // Unsuccessful submit. Show Alert
              self.showMessagePrompt(withTitle: TPConstants.ErrorAlertTitle, message: error!.localizedDescription)
            }
            else {
              UIViewController.showToast(onViewController: self, withMessage: TPConstants.SubmitReviewSuccess)
              // Successful submit. Dismiss controller
              DispatchQueue.main.asyncAfter(deadline: .now() + TPConstants.DelayDuration, execute: {
                self.navigationController?.popViewController(animated: true)
              })
            }
            
            // Hide the spinner
            UIViewController.removeSpinner(spinner: spinner)
          })
        }
      })
    }
    else {
      sendReviewsWithoutImages(toChild: child, withData: data, completionHandler: { (error, dbRef) in
        if (error != nil) {
          // Unsuccessful submit. Show Alert
          self.showMessagePrompt(withTitle: TPConstants.ErrorAlertTitle, message: error!.localizedDescription)
        }
        else {
          UIViewController.showToast(onViewController: self, withMessage: TPConstants.SubmitReviewSuccess)
          // Successful submit. Dismiss controller
          DispatchQueue.main.asyncAfter(deadline: .now() + TPConstants.DelayDuration, execute: {
            self.navigationController?.popViewController(animated: true)
          })
        }
        
        // Hide the spinner
        UIViewController.removeSpinner(spinner: spinner)
      })
    }
    
    // Store house address to check later that the user should not submit multiple reviews for single house
    // during the same session.
    houseAddress = data[TPConstants.HouseAddress]! as! String
  }
  
  func sendReviewsWithoutImages(toChild child: String, withData data: [String:Any], completionHandler: @escaping ((Error?, DatabaseReference)->()))
  {
    // If the user is editing the review, do not generate the new review.
    if review != nil {
      var dataToPush = data
      // Update Image URLs
      dataToPush[TPConstants.HouseImages] = review!.houseImages
      // Update the review in the Firebase Database
      self.ref.child(child).child(review!.key).updateChildValues(data, withCompletionBlock: { (error, dbRef) in
        completionHandler(error, dbRef)
      })
    }
    else {
      // Push the review to Firebase Database
      self.ref.child(child).childByAutoId().setValue(data, withCompletionBlock: { (error, dbRef) in
        completionHandler(error, dbRef)
      })
    }
  }
  
  func sendReviewsWithImages(toChild child: String, withData data: [String:Any], completionHandler: @escaping ((Error?, DatabaseReference)->()))
  {
    // If the user is editing the review, do not generate the new review.
    if review != nil {
      uploadImagesToFirebase(selectedImages!, completionHandler: { (imageUrls) in
        // Append Image URLs
        var dataToPush = data
        dataToPush[TPConstants.HouseImages] = imageUrls
        // Update the review in the Firebase Database
        self.ref.child(child).child(self.review!.key).updateChildValues(dataToPush, withCompletionBlock: { (error, dbRef) in
          completionHandler(error, dbRef)
        })
      })
    }
    else {
      uploadImagesToFirebase(selectedImages!, completionHandler: { (imageUrls) in
        // Append Image URLs
        var dataToPush = data
        dataToPush[TPConstants.HouseImages] = imageUrls
        // Push the review to the Firebase Database
        self.ref.child(child).childByAutoId().setValue(dataToPush, withCompletionBlock: { (error, dbRef) in
          completionHandler(error, dbRef)
        })
      })
    }
  }
  
  func uploadImagesToFirebase(_ images: [HouseImage], completionHandler: @escaping (([String]) -> ()))
  {
    // Upload images only when submit button is clicked.
    // There after submitting the data to firebase when image upload is complete
    uploadImages(images: images) { (imageLocations) in
      print("Images uploaded successfully")
      
      completionHandler(imageLocations)
      // Send the data to Firebase
//      sendMessage(toChild: TPConstants.Reviews, withData: dataToSend)
    }
  }
  
  func initializeHouseTypeInputView() {
    // Add picker
    pickerView = UIPickerView()
    pickerView.delegate = self
    pickerView.dataSource = self

    self.houseTypeField.inputView = pickerView
    self.homeSizeField.inputView = pickerView
    self.cityField.inputView = pickerView
    
    // Add toolbar with done button on the right
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35))
    toolbar.barTintColor = TPConstants.PurpleColor
    let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
    doneButton.tintColor = UIColor.white
    doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 15.0)!], for: .normal)
    toolbar.items = [flexibleSeparator, doneButton]
    self.houseTypeField.inputAccessoryView = toolbar
    self.homeSizeField.inputAccessoryView = toolbar
    self.cityField.inputAccessoryView = toolbar
  }
  
  func doneButtonPressed(_ sender: Any)
  {
    self.houseTypeField.resignFirstResponder()
    self.homeSizeField.resignFirstResponder()
    self.cityField.resignFirstResponder()
    // Reset the selection in picker view, since we are using one picker for different fields.
    self.pickerView.selectRow(0, inComponent: 0, animated: true)
  }
  
  // MARK: - UIPickerViewDataSource Methods
  func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    if self.houseTypeField.isFirstResponder {
      return self.houseTypeList.count
    }
    else if self.homeSizeField.isFirstResponder {
      return self.bhkList.count
    }
    else if self.cityField.isFirstResponder {
      return self.cityList.count
    }
    return 0
  }
  
  // MARK: - UIPickerViewDelegate Methods
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
  {
    if self.houseTypeField.isFirstResponder {
      return self.houseTypeList[row]
    }
    else if self.homeSizeField.isFirstResponder {
      return self.bhkList[row]
    }
    else if self.cityField.isFirstResponder {
      return self.cityList[row]
    }
    return ""
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    if self.houseTypeField.isFirstResponder {
      self.houseTypeField.text = self.houseTypeList[row]
    }
    else if self.homeSizeField.isFirstResponder {
      self.homeSizeField.text = self.bhkList[row]
    }
    else if self.cityField.isFirstResponder {
      self.cityField.text = self.cityList[row]
    }
  }
  
  @IBAction func submitReview(_ sender: UIButton)
  {
    var dataToSend = [TPConstants.HouseType:self.houseTypeField.text!,
                      TPConstants.HouseAddress:self.homeAddressField.text!,
                      TPConstants.Locality:self.areaField.text!,
                      TPConstants.City:self.cityField.text!,
                      TPConstants.HouseSize:self.homeSizeField.text!,
                      TPConstants.Feedback:self.feedbackTextView.text!,
                      TPConstants.Rent:self.rentField.text!,
                      TPConstants.SecurityDeposit:self.securityDepositField.text!,
                      TPConstants.TenantFacebookUserID:FBSDKAccessToken.current().userID!,
                      TPConstants.HouseRating:ratingLabel.text!,
                      TPConstants.OwnerRating:ownerRatingLabel.text!,
                      TPConstants.MajorLocality:majorLocality,
                      TPConstants.Date:"\(Date().timeIntervalSince1970)"] as [String : Any]
    
    // Check if any of the values of dictionary to send is not empty (exclude House images urls, as it is an array of strings)
    if dataToSend.values.contains(where: {$0 as! String == "" || $0 as! String == TPConstants.PlaceholderFeedback}) {
      self.showMessagePrompt(withTitle: TPConstants.ErrorAlertTitle, message: TPConstants.ErrorEmptyTextField)
    }
    else {
      if houseAddress != self.homeAddressField.text!
      {
        // Append optionals
        dataToSend[TPConstants.OwnerName] = ownerNameField.text!
        dataToSend[TPConstants.TenantName] = tenantNameField.text!
        
        sendMessage(toChild: TPConstants.Reviews, withData: dataToSend)
//        self.showMessagePrompt(withTitle: TPConstants.SuccessAlertTitle, message: TPConstants.SubmitReviewSuccess)
      }
      else {
        self.showMessagePrompt(withTitle: TPConstants.ErrorAlertTitle, message: TPConstants.ErrorAlreadyReviewed)
      }
    }
  }
  
  func registerForKeyboardNotifications()
  {
    //Adding notifies on keyboard appearing
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  func deregisterFromKeyboardNotifications(){
    //Removing notifies on keyboard appearing
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  func keyboardWasShown(notification: NSNotification){
    //Need to calculate keyboard exact size due to Apple suggestions
    var info = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)

    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    
    var aRect : CGRect = self.view.frame
    aRect.size.height -= keyboardSize!.height
    if let activeField = self.activeField {
      if (!aRect.contains(activeField.frame.origin)){
        self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
      }
    }
    
//    let filteredConstraint = self.scrollView.constraints.filter { $0.identifier == "scrollViewBottonConstraint" }
//    for subview in self.view.subviews {
//      for constraint in subview
//    }
//    
//    filteredConstraint.first!.constant = filteredConstraint.first!.constant + keyboardSize!.height
  }
  
  func keyboardWillBeHidden(notification: NSNotification)
  {
    //Once keyboard disappears, restore original positions
//    var info = notification.userInfo!
//    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//    let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
    let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
  
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
//    self.view.endEditing(true)
//    self.scrollView.isScrollEnabled = true
  }
  
  func showPlaces()
  {
    let autocompleteController = GMSAutocompleteViewController()
    let filter = GMSAutocompleteFilter()
    filter.country = "IN"
    autocompleteController.autocompleteFilter = filter
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView)
  {
    // Reset the text view to remove placeholder text before the user starts typing
    if feedbackTextView.textColor == UIColor.lightGray {
      textView.text = ""
      textView.textColor = UIColor.darkGray
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView)
  {
    if feedbackTextView.text.isEmpty {
      textView.text = TPConstants.PlaceholderFeedback
      textView.textColor = UIColor.lightGray
    }
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField)
  {
    activeField = textField
  
    // If the picker view is already shown, refresh the contents of picker view
    if pickerView.window != nil {
      pickerView.reloadAllComponents()
    }
    
    if textField == self.areaField {
      showPlaces()
    }
    
    // Set the default value for text field corresponding to the first responder
    if textField == houseTypeField {
      houseTypeField.text = houseTypeList[pickerView.selectedRow(inComponent: 0)]
    }
    else if textField == homeSizeField {
      homeSizeField.text = bhkList[pickerView.selectedRow(inComponent: 0)]
    }
    else if textField == cityField {
      cityField.text = cityList[pickerView.selectedRow(inComponent: 0)]
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField)
  {
    activeField = nil
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    textField.resignFirstResponder()
    return false
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destinationVC = segue.destination as? TPPhotoAlbumViewController {
      destinationVC.delegate = self
    }
  }
  
  // MARK: - TPPhotoAlbumDelegate Methods
  func didFinishSelectingImages(images: [HouseImage?]) {
    
    // Clear all images before assigning new ones
    clearImages()
    
    // Store the selected images in the selectedImages variable
    selectedImages = images as? [HouseImage]
    for (index, houseImage) in images.enumerated() {
      switch index {
      case 0:
        self.imageView2.image = houseImage!.image
      case 1:
        self.imageView3.image = houseImage!.image
      case 2:
        self.imageView1.image = houseImage!.image
      case 3:
        self.imageView4.image = houseImage!.image
      default:
        break
      }
    }
  }
  
  // MARK: - TQStarRatingView Methods
  func ratingUpdated(forView view: TQStarRatingView, rating: Double)
  {
    if view.tag == 1 {
      // Update house ratings
      ratingLabel.text = "\(rating)"
    }
    else if view.tag == 2 {
      // Update owner's ratings
      ownerRatingLabel.text = "\(rating)"
    }
  }
  
  func clearImages()
  {
    self.imageView2.image = nil
    self.imageView3.image = nil
    self.imageView1.image = nil
    self.imageView4.image = nil
  }
  
}

extension TPWriteReviewViewController: GMSAutocompleteViewControllerDelegate {
  
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
  {
    var placeName = place.name
    // Store major locality that should be sent to the Firebase
    majorLocality = place.name
    
    for component in place.addressComponents! {
      if (component.type == kGMSPlaceTypeSublocalityLevel1) {
        placeName.append(", \(component.name)")
        majorLocality = component.name
      }
      else if (component.type == kGMSPlaceTypeSublocalityLevel3) {
        placeName.append(", \(component.name)")
        majorLocality = component.name
      }
    }
    // Fill the text field with the fetched address from Google Places
    self.areaField.text = placeName
    dismiss(animated: true, completion: nil)
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error)
  {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }
  
  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController)
  {
    dismiss(animated: true, completion: nil)
    self.areaField.text = ""
  }
  
  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController)
  {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController)
  {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
}
