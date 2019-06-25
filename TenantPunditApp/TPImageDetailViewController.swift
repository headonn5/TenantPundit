//
//  TPImageDetailViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 20/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import SDWebImage

class TPImageDetailViewController: UIViewController, UIPageViewControllerDataSource {
  
  var pageViewController: UIPageViewController?
  var contentImages: [URL]?
  var imageIndex: Int = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    createPageViewController()
  }

  func createPageViewController()
  {
    let pageController = storyboard?.instantiateViewController(withIdentifier: TPConstants.PageSlideController) as!
    TPPageViewController
    pageController.dataSource = self
    
    let firstController = getItemController(imageIndex)!
    let startingViewController = [firstController]
    
    pageController.setViewControllers(startingViewController, direction: .forward, animated: true, completion: nil)
    self.pageViewController = pageController
    addChildViewController(self.pageViewController!)
    self.view.addSubview(self.pageViewController!.view)
    self.pageViewController?.didMove(toParentViewController: self)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController:
    UIViewController) -> UIViewController?
  {
    let imageController = viewController as! TPFullImageViewController
    if imageController.imageIndex > 0 {
      return getItemController(imageController.imageIndex - 1)
    }
    
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController:
    UIViewController) -> UIViewController?
  {
    let imageController = viewController as! TPFullImageViewController
    if imageController.imageIndex+1 < contentImages!.count {
      return getItemController(imageController.imageIndex + 1)
    }
    
    return nil
  }
  
  func presentationCount(for pageViewController: UIPageViewController) -> Int
  {
    return 0
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
  
  func getItemController(_ itemIndex: Int) -> TPFullImageViewController?
  {
    if itemIndex < contentImages!.count {
      let pageImageController = storyboard?.instantiateViewController(withIdentifier:
        TPConstants.FullImageSliderController) as!
      TPFullImageViewController
      pageImageController.imageIndex = itemIndex
      pageImageController.imageUrl = contentImages![itemIndex]
      return pageImageController
    }
    return nil
  }

  

}
