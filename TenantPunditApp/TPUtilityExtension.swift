//
//  TPSpinnerExtension.swift
//  TenantPunditApp
//
//  Created by NishantFL on 21/02/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit

extension UIViewController {
  class func displaySpinner(onView : UIView) -> UIView {
    let spinnerView = UIView.init(frame: onView.bounds)
    spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
    ai.startAnimating()
    ai.center = spinnerView.center
    
    DispatchQueue.main.async {
      spinnerView.addSubview(ai)
      onView.addSubview(spinnerView)
    }
    
    return spinnerView
  }
  
  class func removeSpinner(spinner :UIView) {
    DispatchQueue.main.async {
      spinner.removeFromSuperview()
    }
  }
  
  class func showToast(onViewController viewController: UIViewController, withMessage message: String)
  {
    // Dismiss keyboard if shown any
    viewController.view.endEditing(true)
    
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    viewController.present(alert, animated: true)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TPConstants.DelayDuration) {
      alert.dismiss(animated: true)
    }
  }
}

extension UIView {
  
  func addBorder(radius: CGFloat, width: CGFloat, color: CGColor)
  {
    self.layer.cornerRadius = radius
    self.layer.borderWidth = width
    self.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).cgColor
  }
}
