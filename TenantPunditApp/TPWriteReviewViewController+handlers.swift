//
//  TPWriteReviewViewController+handlers.swift
//  TenantPunditApp
//
//  Created by NishantFL on 23/07/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import FirebaseStorage
import FBSDKCoreKit

extension TPWriteReviewViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func selectImages()
  {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    
    self.present(pickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
  {
//    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
//    [self.capturedImages addObject:image];
    let image = info[UIImagePickerControllerOriginalImage];
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
  {
    dismiss(animated: true, completion: nil)
  }
  
  func uploadImages(images: [HouseImage?], completionHandler: @escaping (([String]) -> ()))
  {
    if (FBSDKAccessToken.current() != nil) {
      let userID = FBSDKAccessToken.current().userID as String
//      var uploadedImageUrls = [String]()
      var uploadedImageLocation = [String]()
      var uploadCount = 0
      let storageRef = Storage.storage().reference().child("\(userID)")
      for houseImage in images {
        let imageName = houseImage!.name
        let image = houseImage!.image
        
        let childStorageRef = storageRef.child(imageName)
        guard let uplodaData = UIImagePNGRepresentation(image) else{
          return
        }
        childStorageRef.putData(uplodaData, metadata: nil, completion: { (metadata, error) in
          if error != nil{
            print(error!.localizedDescription)
            return
          }
          if (metadata?.downloadURL()?.absoluteString) != nil{
//            uploadedImageUrls.append(imageUrl)
            uploadedImageLocation.append("\(userID)/\(imageName)")
            
            uploadCount += 1

            if uploadCount == images.count {
              completionHandler(uploadedImageLocation)
            }
          }
        })
      }
    }
  }
  
}
