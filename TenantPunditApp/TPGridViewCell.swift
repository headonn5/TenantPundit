//
//  TPGridViewCell.swift
//  TenantPunditApp
//
//  Created by NishantFL on 11/02/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit

class TPGridViewCell: UICollectionViewCell {
  
  @IBOutlet var imageView: UIImageView!
  
  var representedAssetIdentifier: String!
  
  var thumbnailImage: UIImage! {
    didSet {
      imageView.image = thumbnailImage
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailImage = nil
  }
}

