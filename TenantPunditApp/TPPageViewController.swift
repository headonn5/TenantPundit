//
//  TPPageViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 18/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit

class TPPageViewController: UIPageViewController {
  
  var pageControl: UIPageControl?

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
//    let rect = CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0)
    let bgImageView = UIImageView(frame: .zero)
    bgImageView.image = UIImage(named: "wallpaper.jpg")
    view.addSubview(bgImageView)
    
    bgImageView.translatesAutoresizingMaskIntoConstraints = false
    let leadingConstraint = NSLayoutConstraint(item: bgImageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
    let trailingConstraint = NSLayoutConstraint(item: bgImageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
//    let topConstraint = NSLayoutConstraint(item: bgImageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
    let bottomConstraint = NSLayoutConstraint(item: bgImageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
    let heightConstraint = NSLayoutConstraint(item: bgImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0)
    view.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint, heightConstraint])
    
  }
  
  override func viewDidLayoutSubviews()
  {
    super.viewDidLayoutSubviews()
    
    self.view.backgroundColor = TPConstants.LightBrownColor
    
    // Change color of page indicator
    customizePageControl(selectedColor: TPConstants.PurpleColor, unselectedColor: UIColor.lightGray)
  }
  
  func customizePageControl(selectedColor: UIColor, unselectedColor: UIColor)
  {
    for view in self.view.subviews {
      if let pageControl = view as? UIPageControl {
        pageControl.pageIndicatorTintColor = unselectedColor
        pageControl.currentPageIndicatorTintColor = selectedColor
        
      }
    }
  }
  
  

  

}
