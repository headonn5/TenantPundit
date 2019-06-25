//
//  TPFeedbackViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 22/02/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit
import StoreKit
import Firebase
import FBSDKLoginKit

class TPFeedbackViewController: UIViewController, UITextViewDelegate {

  let kOFFSET_FOR_KEYBOARD: CGFloat = 160.0
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var feedbackLabel: UILabel!
  @IBOutlet weak var feedbackTextView: UITextView!
  @IBAction func likeUsAction(_ sender: UIButton)
  {
    hideAdditionalViews(true)
    
    if #available(iOS 10.3, *) {
      SKStoreReviewController.requestReview()
    } else {
      // Fallback on earlier versions
      showMessagePrompt(withTitle: TPConstants.SubmitLikedTitle, message: TPConstants.SubmitLikedMessage)
    }
  }
  
  @IBAction func improveAction(_ sender: UIButton)
  {
    hideAdditionalViews(false)
  }
  
  @IBAction func submitFeedback(_ sender: UIButton)
  {
    guard !feedbackTextView.text.isEmpty else {
      showMessagePrompt(withTitle: TPConstants.ErrorAlertTitle, message: TPConstants.ErrorEmptyTextField)
      return
    }
    let data: [String:String] = [TPConstants.Feedback:feedbackTextView.text]
    Database.database().reference().child(TPConstants.Users).child(FBSDKAccessToken.current().userID).child(TPConstants.AppFeedback).setValue(data) { (error, dbRef) in
      guard error == nil else {
        self.showMessagePrompt(withTitle: TPConstants.ErrorAlertTitle, message: error!.localizedDescription)
        return
      }
      self.showMessagePrompt(withTitle: TPConstants.SuccessAlertTitle, message: TPConstants.SubmitFeedbackSuccess)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    self.view.endEditing(true)
  }

  override func viewDidLoad()
  {
    super.viewDidLoad()
    hideAdditionalViews(true)
    feedbackTextView.addBorder(radius: 10.0, width: 2.0, color: UIColor(white: 0.0, alpha: 0.8).cgColor)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: self)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: self)
  }
  
  func setViewMovedUp(_ movedUp: Bool)
  {
    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationDuration(0.3)
    var rect = self.view.frame
    if movedUp {
      rect.origin.y = rect.origin.y - kOFFSET_FOR_KEYBOARD
      rect.size.height = rect.size.height + kOFFSET_FOR_KEYBOARD
    }
    else {
      rect.origin.y = rect.origin.y + kOFFSET_FOR_KEYBOARD
      rect.size.height = rect.size.height - kOFFSET_FOR_KEYBOARD
    }
    
    self.view.frame = rect
    UIView.commitAnimations()
  }
  
  func keyboardWillShow()
  {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
      setViewMovedUp(true)
    }
    else if (self.view.frame.origin.y < 0)
    {
      setViewMovedUp(false)
    }
  }
  
  func keyboardWillHide()
  {
    if (self.view.frame.origin.y >= 0)
    {
      setViewMovedUp(true)
    }
    else if (self.view.frame.origin.y < 0)
    {
      setViewMovedUp(false)
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView)
  {
    //move the main view, so that the keyboard does not hide it.
    if  (self.view.frame.origin.y >= 0)
    {
      setViewMovedUp(true)
    }
  }
  
  func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
    guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
      completion(false)
      return
    }
    guard #available(iOS 10, *) else {
      completion(UIApplication.shared.openURL(url))
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: completion)
  }

  func showMessagePrompt(withTitle title: String, message: String)
  {
    let messageAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
      if message == TPConstants.SubmitLikedMessage {
        self.rateApp(appId: TPRemoteFetchService.sharedRemoteConfigService.configProperties!.appItunesID, completion: { (isSuccess) in
          print("isSuccess \(isSuccess)")
        })
      }
      else if message == TPConstants.SubmitFeedbackSuccess { // Dismiss view controller when the feedback is submitted.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
          self.navigationController?.popViewController(animated: true)
        }
      }
    })
    messageAlertController.addAction(okAction)
    self.present(messageAlertController, animated: true, completion: nil)
  }
  
  func hideAdditionalViews(_ shouldHide: Bool)
  {
    feedbackTextView.isHidden = shouldHide
    submitButton.isHidden = shouldHide
    feedbackLabel.isHidden = shouldHide
  }

}
