//
//  TPInitialViewController.swift
//  TenantPunditApp
//
//  Created by NishantFL on 27/12/17.
//  Copyright © 2017 TechViews. All rights reserved.
//

import UIKit
import CoreLocation

class TPInitialViewController: UIViewController, CLLocationManagerDelegate {

  var locationManager: CLLocationManager!
  
  override func viewDidLoad() {
      super.viewDidLoad()
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    // Store the default location in the user preferences
    UserDefaults.standard.set(TPConstants.DefaultCityPref, forKey: TPConstants.CityPreference)
    UserDefaults.standard.synchronize()

    DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
      self.performSegue(withIdentifier: TPConstants.SegueShowLogin, sender: nil)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let currentLocation = locations[0]
    manager.stopUpdatingLocation()
    
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
      if (error != nil) {
        print("Geocode failed with error : \(error?.localizedDescription)")
        return
      }
      let placemark = placemarks![0]
      
      // Save the city location of the user from the main thread
      DispatchQueue.main.async {
        if placemark.locality == nil {
          return
        }
        if (placemark.locality!.components(separatedBy: " ").count > 0) {
          UserDefaults.standard.set(placemark.locality!.components(separatedBy: " ").first!, forKey: TPConstants.CityPreference)
          UserDefaults.standard.synchronize()
        }
        else {
          UserDefaults.standard.set(placemark.locality, forKey: TPConstants.CityPreference)
          UserDefaults.standard.synchronize()
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Not able to fetch user's location. Error: \(error.localizedDescription)")
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
