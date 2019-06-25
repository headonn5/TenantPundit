//
//  TPBaseViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 17/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import ObjectiveC

class TPBaseViewController: UIViewController {
  
  public typealias GenericHandlerCallback = () -> Swift.Void
  
  private struct AssociatedKey {
    static var alertView = "tpLoadingAlertView"
  }

  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  func showMessagePrompt(withTitle title: String, message: String)
  {
    let messageAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: TPConstants.ErrorAlertActionTitle, style: .default, handler: nil)
    messageAlertController.addAction(okAction)
    self.present(messageAlertController, animated: true, completion: nil)
  }
  
  func hideLoadingView(withCompletionHandler handler: @escaping GenericHandlerCallback)
  {
    let loadingAlertController = objc_getAssociatedObject(self, &AssociatedKey.alertView) as? TPAlertViewController
    if loadingAlertController != nil {
      loadingAlertController!.dismiss(animated: true, completion: { 
        handler()
      })
    }
    objc_setAssociatedObject(self, &AssociatedKey.alertView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }

  func showLoadingView()
  {
    var loadingAlertController = objc_getAssociatedObject(self, &AssociatedKey.alertView) as? TPAlertViewController
    if loadingAlertController != nil {
      return
    }
    
    loadingAlertController = TPAlertViewController(title: "", message: nil, preferredStyle: .alert)
    
    
    let images = getImageArray()
    let animateImage = UIImage.animatedImage(with: images, duration: 1.0)
    let animatedImageView = UIImageView(image: animateImage)
    animatedImageView.frame = CGRect(x: self.view.frame.size.width/2 - 60, y: self.view.frame.size.height/2 - 60, width:
      120, height: 120)
    animatedImageView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .
      flexibleRightMargin]
    
    loadingAlertController?.view.addSubview(animatedImageView)
    
    objc_setAssociatedObject(self, &AssociatedKey.alertView, loadingAlertController, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    loadingAlertController?.show()
  }
  
  func getImageArray() -> [UIImage]
  {
    var images = [UIImage]()
    for i in 0...20
    {
      images.append(UIImage(named:"frame_\(i).png")!)
    }
    return images
  }

}
