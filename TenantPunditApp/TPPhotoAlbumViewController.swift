//
//  TPPhotoAlbumViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 11/12/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import Photos

struct HouseImage {
  var image: UIImage
  var name: String
}

protocol TPPhotoAlbumDelegate: class {
  func didFinishSelectingImages(images: [HouseImage?])
}

private extension UICollectionView {
  func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
    let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
    return allLayoutAttributes.map { $0.indexPath }
  }
}

class TPPhotoAlbumViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  let maximumSelection = 4
  var imageArray = [HouseImage]()
  var selectedAssets = [PHAsset]()
  weak var delegate:TPPhotoAlbumDelegate?
  var fetchResult: PHFetchResult<PHAsset>!
  fileprivate let imageManager = PHCachingImageManager()
  fileprivate var thumbnailSize: CGSize!
  fileprivate var previousPreheatRect = CGRect.zero
  var isAccessGranted = false
  
  override func viewDidLoad()
  {
    self.collectionView?.allowsMultipleSelection = true
    
    // Get the current authorization state.
    let status = PHPhotoLibrary.authorizationStatus()
    
    if (status == PHAuthorizationStatus.denied) {
      return
    }
    isAccessGranted = true
//    else if (status == PHAuthorizationStatus.authorized) {
//      // Access has been denied.
//    }
    
    resetCachedAssets()
    // Notify view controller when images are changes in photo library
    PHPhotoLibrary.shared().register(self as! PHPhotoLibraryChangeObserver)
    // Grab photos from device
    self.grabPhotos()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateItemSize()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    updateItemSize()
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self as! PHPhotoLibraryChangeObserver)
  }
  
  func grabPhotos()
  {
    let imageManager = PHCachingImageManager()
    
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true
    requestOptions.deliveryMode = .opportunistic
    
    if fetchResult == nil {
      let fetchOptions = PHFetchOptions()
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
//    if fetchResult != nil {
//      if fetchResult.count > 0 {
//        for i in 0..<fetchResult.count {
//          imageManager.requestImage(for: fetchResult[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) in
//            let resources = PHAssetResource.assetResources(for: self.fetchResult[i])
//            let imageName = resources[0].originalFilename
//            let houseImage = HouseImage(image: image!, name: imageName)
//            self.imageArray.append(houseImage)
//          })
//        }
//        DispatchQueue.main.async {
//          self.collectionView?.reloadData()
//        }
//      }
//      else {
//        print("No photos found.")
//        // This is done to reload the view after the pop up asking for permission of photos is dismissed
//        DispatchQueue.main.async {
//          self.collectionView?.reloadData()
//        }
//      }
//    }
  }
  
  private func updateItemSize() {
    
    let viewWidth = self.view.bounds.size.width
    
    let desiredItemWidth: CGFloat = 100
    let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
    let padding: CGFloat = 1
    let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
    let itemSize = CGSize(width: itemWidth, height: itemWidth)
    
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = itemSize
      layout.minimumInteritemSpacing = padding
      layout.minimumLineSpacing = padding
    }
    
    // Determine the size of the thumbnails to request from the PHCachingImageManager
    let scale = UIScreen.main.scale
    thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
  }

  // MARK: UIScrollView
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    updateCachedAssets()
  }
  
  fileprivate func updateCachedAssets() {
    // Update only if the view is visible.
    guard isViewLoaded && view.window != nil else { return }
    
    // The preheat window is twice the height of the visible rect.
    let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
    let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
    
    // Update only if the visible area is significantly different from the last preheated area.
    let delta = abs(preheatRect.midY - previousPreheatRect.midY)
    guard delta > view.bounds.height / 3 else { return }
    
    // Compute the assets to start caching and to stop caching.
    let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
    let addedAssets = addedRects
      .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
      .map { indexPath in fetchResult.object(at: indexPath.item) }
    let removedAssets = removedRects
      .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
      .map { indexPath in fetchResult.object(at: indexPath.item) }
    
    // Update the assets the PHCachingImageManager is caching.
    imageManager.startCachingImages(for: addedAssets,
                                    targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    imageManager.stopCachingImages(for: removedAssets,
                                   targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
    
    // Store the preheat rect to compare against in the future.
    previousPreheatRect = preheatRect
  }
  
  fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
    if old.intersects(new) {
      var added = [CGRect]()
      if new.maxY > old.maxY {
        added += [CGRect(x: new.origin.x, y: old.maxY,
                         width: new.width, height: new.maxY - old.maxY)]
      }
      if old.minY > new.minY {
        added += [CGRect(x: new.origin.x, y: new.minY,
                         width: new.width, height: old.minY - new.minY)]
      }
      var removed = [CGRect]()
      if new.maxY < old.maxY {
        removed += [CGRect(x: new.origin.x, y: new.maxY,
                           width: new.width, height: old.maxY - new.maxY)]
      }
      if old.minY < new.minY {
        removed += [CGRect(x: new.origin.x, y: old.minY,
                           width: new.width, height: new.minY - old.minY)]
      }
      return (added, removed)
    } else {
      return ([new], [old])
    }
  }
  
  @IBAction func donePhotoSelection(_ sender: UIBarButtonItem)
  {
    if selectedAssets.count > 0 {
      fetchHouseImages(fromAsset: selectedAssets, completionHandler: { (selectedImages) in
        self.delegate?.didFinishSelectingImages(images: selectedImages)
        // Dismiss the controller using main thread
        DispatchQueue.main.async {
          self.navigationController?.popViewController(animated: true)
        }
      })
    }
  }
  
  fileprivate func fetchHouseImages(fromAsset assetList: [PHAsset], completionHandler: @escaping ([HouseImage])->())
  {
    var selectedImages = [HouseImage]()
    for asset in assetList {
      let options = PHImageRequestOptions()
      options.deliveryMode = .highQualityFormat
      PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
        let resources = PHAssetResource.assetResources(for: asset)
        let imageName = resources[0].originalFilename
        let houseImage = HouseImage(image: image!, name: imageName)
        selectedImages.append(houseImage)
        
        // Call the completion handler when all the images are obtained from the assets.
        if selectedImages.count == assetList.count {
          completionHandler(selectedImages)
        }
      })
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (isAccessGranted ? fetchResult.count : 0)
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! TPGridViewCell
//    let imageView = cell.viewWithTag(1) as! UIImageView
//    imageView.image = imageArray[indexPath.row].image
    
    let asset = fetchResult.object(at: indexPath.item)
    let okBtn = cell.viewWithTag(2) as! UIButton

    if selectedAssets.contains(asset) {
      okBtn.isHidden = false
    }
    else {
      okBtn.isHidden = true
    }
    // Request an image for the asset from the PHCachingImageManager.
    cell.representedAssetIdentifier = asset.localIdentifier
    imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
      // The cell may have been recycled by the time this handler gets called;
      // set the cell's thumbnail image only if it's still showing the same asset.
      if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
        cell.thumbnailImage = image
      }
    })
   
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if selectedAssets.count < maximumSelection {
      let cell = collectionView.cellForItem(at: indexPath)
      let fetchedAsset = fetchResult.object(at: indexPath.item)
      let okBtn = cell?.viewWithTag(2) as! UIButton
      okBtn.isHidden = false
      // Add the asset to the selection list.
      selectedAssets.append(fetchedAsset)
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath)
    let okBtn = cell?.viewWithTag(2) as! UIButton
    okBtn.isHidden = true
    let fetchedAsset = fetchResult.object(at: indexPath.item)
    // Retain the asset in the selection list if the asset is not equal to current selection in collection view.
    // Filter out the asset from the selection list if it matches the current selection in collection view.
    selectedAssets = selectedAssets.filter{ $0 != fetchedAsset }
  }
  
  // MARK: Asset Caching
  fileprivate func resetCachedAssets() {
    imageManager.stopCachingImagesForAllAssets()
    previousPreheatRect = .zero
  }

}

// MARK: PHPhotoLibraryChangeObserver
extension TPPhotoAlbumViewController: PHPhotoLibraryChangeObserver {
  
  func photoLibraryDidChange(_ changeInstance: PHChange)
  {
    guard let changes = changeInstance.changeDetails(for: self.fetchResult)
      else { return }
    // Change notifications may be made on a background queue. Re-dispatch to the
    // main queue before acting on the change as we'll be updating the UI.
    DispatchQueue.main.async {
      self.fetchResult = changes.fetchResultAfterChanges
      if changes.hasIncrementalChanges {
        // If we have incremental diffs, animate them in the collection view.
        guard let collectionView = self.collectionView else { fatalError() }
        collectionView.performBatchUpdates({
          // For indexes to make sense, updates must be in this order:
          // delete, insert, reload, move
          if let removed = changes.removedIndexes, !removed.isEmpty {
            collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
          }
          if let inserted = changes.insertedIndexes, !inserted.isEmpty {
            collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
          }
          if let changed = changes.changedIndexes, !changed.isEmpty {
            collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
          }
          changes.enumerateMoves({ (fromIndex, toIndex) in
            collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0), to: IndexPath(item: toIndex, section: 0))
          })
        })
      }
      else {
        // Reload the collection view if incremental diffs are not available.
        self.collectionView!.reloadData()
      }
      
      self.resetCachedAssets()
    }
  }
}
