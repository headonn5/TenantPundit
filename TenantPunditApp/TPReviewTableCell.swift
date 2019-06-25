//
//  TPReviewTableCell.swift
//  TenantPunditApp
//
//  Created by NishantFL on 22/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit

protocol TPReviewTableCellDelegate: class {
  func bookmarkAdded(_ isBookmarkAdded: Bool, forReview review: TPReview?)
}

class TPReviewTableCell: UITableViewCell {

  var review: TPReview?
  weak var delegate: TPReviewTableCellDelegate?
  
		
  @IBOutlet weak var likeButton: UIButton!
  @IBAction func likeClicked(_ sender: UIButton) {
    if likeButton.image(for: .normal) == UIImage(named:"bookmark_white.png") {
      likeButton.setImage(UIImage(named:"bookmark_black.png"), for: .normal)
      delegate?.bookmarkAdded(true, forReview: self.review)
    }
    else {
      likeButton.setImage(UIImage(named:"bookmark_white.png"), for: .normal)
      delegate?.bookmarkAdded(false, forReview: self.review)
    }
  }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
