//
//  TPImageSliderViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 18/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import SDWebImage

protocol TPImageSliderViewControllerDelegate: class {
  func didTapImageToView(imageIndex: Int)
}

class TPImageSliderViewController: UIViewController {
  
  @IBOutlet weak var contentImageView: UIImageView!
  var imageIndex: Int = 0
  var imageUrl: URL?
  weak var delegate: TPImageSliderViewControllerDelegate?

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
    contentImageView.isUserInteractionEnabled = true
    contentImageView.addGestureRecognizer(tapGestureRecognizer)
    
    if imageUrl != nil {
      contentImageView.sd_setImage(with: imageUrl!, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
    }
    else {
      contentImageView.image = UIImage(named: "no-image-placeholder.jpg")
    }
  }
  
  func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
  {
//    let tappedImage = tapGestureRecognizer.view as! UIImageView
      delegate?.didTapImageToView(imageIndex: self.imageIndex)
  }

}
