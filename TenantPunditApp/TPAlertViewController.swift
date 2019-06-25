//
//  TPAlertViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 17/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit

class TPAlertViewController: UIAlertController {

    override func viewDidLoad()
    {
      super.viewDidLoad()
      let subview = self.view.subviews.last! as UIView
      let alertContentView = subview.subviews.last! as UIView
      for view in alertContentView.subviews {
        // Set background color to match the translucent gray background color below alert view controller
        // so that alert view controller is almost invisible and just the loader inside it should be visible.
        view.backgroundColor = UIColor(red: 126.0/255.0, green: 122.0/255.0, blue: 119.0/255.0, alpha: 1.0)
//        view.backgroundColor = TPConstants.LightBrownColor
      }
//      for subview in alertContentView.subviews.last!.subviews {
//        subview.backgroundColor = UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 0.85)
//      }
    }
  
  override func updateViewConstraints()
  {
    let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.view.subviews[0], attribute:
      NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100.0)
    
    let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.view.subviews[0], attribute:
      NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute:
      NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100.0)
    
    for constraint in self.view.subviews[0].constraints {
      if constraint.firstAttribute == NSLayoutAttribute.width && constraint.constant == 270{
        NSLayoutConstraint.deactivate([constraint])
        break
      }
    }

    self.view.subviews[0].addConstraint(widthConstraint)
    self.view.subviews[0].addConstraint(heightConstraint)

    super.updateViewConstraints()
  }
  
  func hide()
  {
    dismiss(animated: true, completion: nil)
  }
  
  func show()
  {
    present(animated: true, completion: nil)
  }
  
  func present(animated: Bool, completion: (() -> Void)?)
  {
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
      if let presentedViewController = rootVC.presentedViewController {
        presentFromController(controller: presentedViewController, animated: animated, completion: completion)
      }
    }
  }
  
  private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?)
  {
    if let navVC = controller as? UINavigationController,
      let visibleVC = navVC.visibleViewController {
      presentFromController(controller: visibleVC, animated: animated, completion: completion)
    }  else {
      controller.present(self, animated: animated, completion: completion);
    }
  }

}
