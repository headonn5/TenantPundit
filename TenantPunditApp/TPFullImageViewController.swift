//
//  TPImageViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 20/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import SDWebImage

class TPFullImageViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  var imageIndex: Int = 0
  var imageUrl: URL?
  
    override func viewDidLoad() {
        super.viewDidLoad()

      if imageUrl != nil {
        imageView.sd_setImage(with: imageUrl!, placeholderImage: UIImage(named: "no-image-placeholder.jpg"))
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
