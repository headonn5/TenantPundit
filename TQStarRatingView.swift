//
//  TQStarRatingView.swift
//  TQStarRatingSwift
//
//  Created by NishantFL on 17/12/17.
//  Copyright © 2017 TechQuench. All rights reserved.
//

import UIKit

protocol TQStarRatingDelegate: class {
  func ratingUpdated(forView view:TQStarRatingView, rating: Double)
}

class TQStarRatingView: UIView {
  
  private let maxIcons: Int = 5
  private let minIcons: Int = 0
  open var dullImage: UIImage?
  open var happyImage: UIImage?
  open var neutralImage: UIImage?
  open var iconSize: CGSize = CGSize(width: 40.0, height: 40.0)
  private var happyImageViews: [UIImageView] = []
  private var sadImageViews: [UIImageView] = []
  private var neutralImageViews: [UIImageView] = []
  private var rating: Double = 0
  open var ratingType: RatingType = .halfRatings
  open weak var delegate: TQStarRatingDelegate?
  
  enum RatingType {
    case fullRatings
    case halfRatings
  }
  
  func initializeRatingViews()
  {
    dullImage = UIImage(named: "sad.jpg")
    happyImage = UIImage(named: "happy.jpg")
    neutralImage = UIImage(named: "neutral.jpg")
    
    // Add new image views
    for _ in 0..<maxIcons {
      let dullImageView = UIImageView()
      dullImageView.image = dullImage
      dullImageView.contentMode = .scaleAspectFit
      sadImageViews.append(dullImageView)
      addSubview(dullImageView)
      
      let happyImageView = UIImageView()
      happyImageView.image = happyImage
      happyImageView.contentMode = .scaleAspectFit
      happyImageViews.append(happyImageView)
      addSubview(happyImageView)
      
      let neutralImageView = UIImageView()
      neutralImageView.image = neutralImage
      neutralImageView.contentMode = .scaleAspectFit
      neutralImageViews.append(neutralImageView)
      addSubview(neutralImageView)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    initializeRatingViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    initializeRatingViews()
  }
  
  func changeRatings(inLocation location: CGPoint)
  {
    var updatedRating = 0.0
    
    for i in stride(from: (maxIcons-1), through: 0, by: -1) {
      
      let imageView = sadImageViews[i]
      guard location.x > imageView.frame.origin.x else {
        continue
      }
      let locationRefFromImageView = imageView.convert(location, from: self)
      
      // Check if the locationRefFromImageView lies inside the image view
      if imageView.point(inside: locationRefFromImageView, with: nil) && ratingType == .halfRatings {
        let fractionInsideImageView = locationRefFromImageView.x/imageView.frame.size.width
        updatedRating = Double(i) + ((fractionInsideImageView > 0.6) ? 1.0 : 0.5)
      }
      else {
        updatedRating = Double(i) + 1.0
      }
      break
    }
    
    // Check min rating
    rating = updatedRating < Double(minIcons) ? Double(minIcons) : updatedRating
    
    refreshView()
  }
  
  func refreshView()
  {
    for i in 0..<happyImageViews.count {
      
      let happyImageView = happyImageViews[i]
      let neutralImageView = neutralImageViews[i]
      let sadImageView = sadImageViews[i]
      
      if rating >= Double(i+1) {
        happyImageView.isHidden = false
        sadImageView.isHidden = true
        neutralImageView.isHidden = true
      }
      else if rating > Double(i) && rating < Double(i+1) {
        happyImageView.isHidden = true
        sadImageView.isHidden = true
        neutralImageView.isHidden = false
      }
      else {
        happyImageView.isHidden = true
        sadImageView.isHidden = false
        neutralImageView.isHidden = true
      }
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let totalIcons = CGFloat(maxIcons)
    let imageWidth = min(frame.size.width/totalIcons, iconSize.width)
    let imageHeight = min(frame.size.height, iconSize.height)
    let centerForImageFrame = frame.size.width/2
    let imageXPosition = centerForImageFrame - (totalIcons/2)*imageWidth
    
    
    for i in 0..<maxIcons {
      let imageViewFrame = CGRect(x: (imageXPosition + CGFloat(i)*imageWidth), y: frame.size.height/2 - imageHeight/2, width: imageWidth, height: imageHeight)
      
      var imageView = neutralImageViews[i]
      imageView.frame = imageViewFrame
      
      imageView = happyImageViews[i]
      imageView.frame = imageViewFrame
      
      imageView = sadImageViews[i]
      imageView.frame = imageViewFrame
    }
  }

  // MARK: Touch events
  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    changeRatings(inLocation: touch.location(in: self))
  }
  
  override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    changeRatings(inLocation: touch.location(in: self))
  }
  
  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Update delegate
    delegate?.ratingUpdated(forView: self, rating: rating)
  }
  
  override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Update delegate
    delegate?.ratingUpdated(forView: self, rating: rating)
  }
}
