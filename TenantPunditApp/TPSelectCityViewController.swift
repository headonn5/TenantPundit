//
//  TPSelectCityViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 05/02/18.
//  Copyright © 2018 TechViews. All rights reserved.
//

import UIKit

protocol TPSelectCityDelegate: class {
  func didSelectCity(cityName: String)
}

class TPSelectCityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  @IBOutlet weak var collectionView: UICollectionView!
  let cityList = TPConstants.CityList
  weak var delegate: TPSelectCityDelegate?
  
  override func viewDidLoad() {
        super.viewDidLoad()

  //        self.collectionView
    }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cityList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TPConstants.SelectCityCellID, for: indexPath)
    
    let cityImageView = cell.viewWithTag(1) as! UIImageView
    let cityNameLabel = cell.viewWithTag(2) as! UILabel
    
    cityImageView.image = UIImage(named: TPConstants.CityImagesList[indexPath.row])
    cityNameLabel.text = cityList[indexPath.row]
    
    customizeCellAppearance(forCell: cell)
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    return CGSize(width: self.view.frame.size.width/3.5, height: self.view.frame.size.height/5)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    delegate?.didSelectCity(cityName: cityList[indexPath.row])
    self.navigationController?.popViewController(animated: true)
  }
  
}

extension TPSelectCityViewController {
  
  func customizeCellAppearance(forCell cell: UICollectionViewCell)
  {
    cell.contentView.layer.cornerRadius = 2.0
    cell.contentView.layer.borderWidth = 1.0
    cell.contentView.layer.borderColor = UIColor.clear.cgColor
    cell.contentView.layer.masksToBounds = true
    cell.layer.shadowColor = UIColor.lightGray.cgColor
    cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    cell.layer.shadowRadius = 2.0
    cell.layer.shadowOpacity = 1.0
    cell.layer.masksToBounds = false
    cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
  }
}
