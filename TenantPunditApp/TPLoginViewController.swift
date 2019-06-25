//
//  ViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 11/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
//import JWTDecode

class TPLoginViewController: TPBaseViewController, FBSDKLoginButtonDelegate {
  
  @IBOutlet weak var wishingLabel: UILabel!
  var loginButton: FBSDKLoginButton!
  var ref: DatabaseReference!
//  fileprivate var _reviewsRefHandle: DatabaseHandle?
//  fileprivate var _userRefHandle: DatabaseHandle?
  var loadingAlertController: TPAlertViewController?

  override func viewDidLoad()
  {
    super.viewDidLoad()

    // Check if the user is already logged in, else show login button
    validateUser()
  }
  
  func validateUser()
  {
    if FBSDKAccessToken.current() != nil {
      self.presentTabController()
    }
    addFacebookButton()
  }
  
  func presentTabController()
  {
    DispatchQueue.main.async {
      self.showLoadingView()
//      self.hideFacebookButton()
    }
    let facebookCredential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
    Auth.auth().signIn(with: facebookCredential) { (user, error) in
      
      if error != nil {
        self.hideLoadingView {
          self.showErrorAlert(description: error!.localizedDescription)
        }
      }
      else if (user != nil) {
        
        self.fetchRemoteConfig()
        
        // Set user's info
        TPUser.sharedInstance.name = user!.displayName!
        TPUser.sharedInstance.gender = "T"
//        print("if user email is valid \(user?.isEmailVerified)")
//        user?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
//          print("Id token is \(idToken)")
//          do {
//            let jwt = try decode(jwt: idToken!)
//            print("something \(jwt)")
//          }
//          catch {
//            print("Catching error")
//          }
//        })
        // Display user's name
        self.wishingLabel.fadeTransition(duration: 0.4)
        self.wishingLabel.text = "Hi \(user!.displayName!)!"
        
        self.configureDatabase()
      }
//      self.ref.child(TPConstants.Reviews).observeSingleEvent(of: .value, with: { (snapshot) in
//        let reviewObject = TPReview(withSnapshot: snapshot)
        
//      })
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    let tabController = segue.destination as! TPTabController
    tabController.selectedIndex = 1
    if TPReviews.shared.count != 0 {
      tabController.reviews = TPReviews.shared
    }
  }
  
  public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error:
    Error!)
  {
    if(error != nil) {
      self.showMessagePrompt(withTitle: "Error", message: "\(error.localizedDescription)")
    }
    else if(result.token != nil) {
      self.presentTabController()
    }
    else {
      self.showMessagePrompt(withTitle: "Error", message: "Please login to proceed.")
    }
  }
  
  public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
  {
    
  }
  
  public func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool
  {
    return true
  }
  
//  deinit
//  {
//    if let refHandle = _reviewsRefHandle  {
//      self.ref.child(TPConstants.Reviews).removeObserver(withHandle: refHandle)
//    }
//    if let refHandle = _userRefHandle {
//      self.ref.child(TPConstants.Users).removeObserver(withHandle: refHandle)
//    }
//  }
  
  func configureDatabase()
  {
    ref = Database.database().reference()
    
    // Fetch default city and save it in default prefs.
    let defaultCityPref = UserDefaults.standard.value(forKey: TPConstants.CityPreference) as! String
    
    // Listen for new reviews in the Firebase database
    TPFirebaseConnection.fetchReviews(forCity: defaultCityPref) {
      // Synchronously listen for user data in the Firebase database after the call to listen reviews
      TPFirebaseConnection.fetchUserData(ref: self.ref, completionHandler: {
        DispatchQueue.main.async {
          self.hideLoadingView {
            // Perform segue to home screen
            self.performSegue(withIdentifier: TPConstants.SegueTab, sender: self)
          }
        }
      })
    }
  }
  
  func fetchDefaultCity() -> String?
  {
    if let defaultCityPref = UserDefaults.standard.value(forKey: TPConstants.CityPreference) {
      return defaultCityPref as? String
    }
    return nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    // Reset the wishing label if user is not logged in
    if FBSDKAccessToken.current() == nil {
      self.wishingLabel.fadeTransition(duration: 0.4)
      self.wishingLabel.text = "Hello Pundit!"
    }
  }

  func sendMessage(withData data: [String:String])
  {
    // Push data to Firebase Database
    self.ref.child(TPConstants.Reviews).childByAutoId().setValue(data)
  }
  
//  func hideFacebookButton()
//  {
//    if (loginButton != nil) {
//      loginButton.isHidden = true
//    }
//  }
//
//  func showFacebookButton()
//  {
//    if (loginButton != nil) {
//      loginButton.isHidden = false
//    }
//  }
  
}

extension TPLoginViewController {
  func addFacebookButton()
  {
    let buttonSize = CGSize(width: 200.0, height: 50.0)
    let buttonOrigin = CGPoint(x: view.center.x, y: view.center.y+80.0)
    let placeholder = CGRect(origin: buttonOrigin, size: buttonSize)
    loginButton = FBSDKLoginButton(frame: placeholder)
    loginButton.readPermissions = ["public_profile", "email", "user_friends"]
    loginButton.delegate = self
    loginButton.removeConstraints(loginButton.constraints)
    loginButton.center = buttonOrigin
    loginButton.backgroundColor = UIColor(red: 114.0/255.0, green: 1.0/255.0, blue: 3.0/255.0, alpha: 1.0)
    view.addSubview(loginButton)
  }
  
  func fetchRemoteConfig()
  {
    // Fetch all remote configs when user logs in
    TPRemoteFetchService.sharedRemoteConfigService.fetchRemoteConfiguration { (remoteConfig, error) in
      if error == nil {
        let remoteConfigProperties: TPRemoteConfigProperties = TPRemoteConfigProperties(withConfig: remoteConfig)
        TPRemoteFetchService.sharedRemoteConfigService.configProperties = remoteConfigProperties
      }
      else {
        print("Error in fetching remote config properties: \(String(describing: error))")
      }
    }
  }
  
  func showErrorAlert(description: String)
  {
    let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

extension UIView {
  func fadeTransition(duration:CFTimeInterval) {
    let animation = CATransition()
    animation.timingFunction = CAMediaTimingFunction(name:
      kCAMediaTimingFunctionEaseInEaseOut)
    animation.type = kCATransitionFade
    animation.duration = duration
    layer.add(animation, forKey: kCATransitionFade)
  }
}

