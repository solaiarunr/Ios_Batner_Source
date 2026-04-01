  //
  //  LocationViewController.swift
  //  Joysale_Swift
  //
  //  Created by Hitasoft on 18/06/20.
  //  Copyright © 2020 Hitasoft. All rights reserved.
  //
  
  import UIKit
  import GoogleMaps
  import GooglePlaces
  import DropDown

  protocol customLocationDelegate1 {
    func locationAct(city: String, state: String, country: String, countryCode: String, lat: String, long: String, location: String)
    
  }
  class LocationViewController: UIViewController {
    @IBOutlet weak var markerButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    // @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var setLocationButton: UIButton!
    @IBOutlet weak var removeLocationButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var bottomStackview: UIStackView!
    var locationManager = CLLocationManager()
    var fetcher: GMSAutocompleteFetcher?
    var session_token = GMSAutocompleteSessionToken()
    var locationArray = NSMutableArray()
    var placesClient: GMSPlacesClient!
    var SelectedCoordination = CLLocationCoordinate2D()
    let dropDown = DropDown()
    var viewType = ""
    var delegate: customLocationDelegate?
    let appDelegete = UIApplication.shared.delegate as! AppDelegate
    var getLocation = ""
    // Location Data
    var city = ""
    var state = ""
    var country = ""
    var countryCode = ""
    var lat = ""
    var long = ""
    var locationString = ""
    var coordinate = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    func configUI() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.navigationController?.customNavigationBarView(title: "location", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.removeLocationButton.setBorder(color: UIColor(named: "AppThemeColor"))
        self.setLocationButton.backgroundColor = UIColor(named: "AppThemeColor")
        self.setLocationButton.cornerMiniumRadius()
        self.searchView.cornerViewMiniumRadius()
        self.removeLocationButton.config(color: UIColor(named: "AppThemeColor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "remove_location")
        self.setLocationButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "set_location")
        if self.viewType == "chat" {
            self.setLocationButton.setTitle(getLanguage["share_your_location"], for: .normal)
            self.removeLocationButton.isHidden = true
        }
        else if self.viewType == "profile" || self.viewType == "addProduct"{
            self.setLocationButton.setTitle(getLanguage["set_location"], for: .normal)
            self.removeLocationButton.isHidden = true
        }
        
        self.searchTextField.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "search", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        self.loadMapView()
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        if !checkLocationPermission() {
            let alertController = UIAlertController(title: getLanguage["alert"] ?? "alert", message: getLanguage["location_permission"] ?? "location_permission", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        // code to execute
    }
    func loadMapView() {
        self.mapView.isHidden = true
        self.markerButton.isHidden = true
        if checkLocationPermission() {
            self.currentLocationView.darkElevationEffect()
            self.mapView.isMyLocationEnabled = true
            self.mapView.delegate = self
            placesClient = GMSPlacesClient.shared()
            locationManager = CLLocationManager()
            locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            if self.locationString == "" || self.locationString.lowercased() == "worldwide" || self.locationString.lowercased() == UserDefaultModule.shared.getcountryname()?.lowercased() {
                self.locationManager.startUpdatingLocation()
            }
            else {
                self.searchTextField.text = self.locationString
                self.getLocationFromAddr(self.searchTextField.text!)
            }
            fetcher = GMSAutocompleteFetcher.init()
            fetcher?.delegate = self
            session_token = GMSAutocompleteSessionToken.init()
            fetcher?.provide(session_token)
            let fetcherFilter = GMSAutocompleteFilter()
            // MARK: Single Country Personalization
//            fetcherFilter.country = "IN"
            fetcherFilter.type = .city
            fetcher?.autocompleteFilter = fetcherFilter
            //            self.fetcher?.autocompleteFilter?.type = .city
        }
        else {
            let alertController = UIAlertController(title: getLanguage["alert"] ?? "alert", message: getLanguage["location_permission"] ?? "location_permission", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: getLanguage["ok"] ?? "ok", style: .default, handler: { (UIAlertAction) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    func checkLocationPermission()->Bool {
        var status = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                self.locationManager.requestWhenInUseAuthorization()
                self.mapView.isHidden = true
                self.markerButton.isHidden = true
            case .authorizedAlways, .authorizedWhenInUse:
                status = true
                self.mapView.isHidden = false
                self.markerButton.isHidden = false
                print("Access")
            @unknown default:
                break
            }
        } else {
            self.locationManager.requestWhenInUseAuthorization()
            print("Location services are not enabled")
        }
        return status
    }

    override func viewWillAppear(_ animated: Bool) {
        self.updateTheme(page: "present")
        NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
    }
      override var preferredStatusBarStyle : UIStatusBarStyle {
          return self.updateStatusBarStyle()
      }
    
    @objc func barButtonAction(_ notification: Notification) {
        print(notification)
        if let isLeft = notification.userInfo?["isLeft"] as? Int {
            print(isLeft)
            if isLeft == 1 {
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @IBAction func currentLocationButtonAct(_ sender: UIButton) {
        self.locationString = ""
        self.locationManager.startUpdatingLocation()
    }
    @IBAction func locationButtonAct(_ sender: UIButton) {
        if sender == removeLocationButton {
            
            self.locationString = "worldwide"
            self.lat = ""
            self.long = ""
            // MARK: Single Country Personalization
//            self.locationString = CURRENT_LOCATION
            self.city = ""
            self.state = ""
            self.country = ""
            self.countryCode = ""
            self.delegate?.locationAct(city: self.city, state: self.state, country: self.country, countryCode: self.countryCode, lat: self.lat, long: self.long, location: self.locationString)
            self.navigationController?.popViewController(animated: true)
            
        }
        else {
            if self.lat != "" && self.long != "" {
                self.delegate?.locationAct(city: self.city, state: self.state, country: self.country, countryCode: self.countryCode, lat: self.lat, long: self.long, location: self.searchTextField.text!)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                let alert = UIAlertController(title: nil, message: getLanguage["select_location_from_dropdown"] ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLanguage["ok"] ?? "", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
  }
  extension LocationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.session_token = GMSAutocompleteSessionToken.init()
        self.fetcher?.provide(self.session_token)
        self.locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        self.dropDown.hide()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchForRide(textField: textField)
        print(textField.text!)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //        textField.resignFirstResponder()
        self.searchForRide(textField: textField)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if string.containsEmoji {
            return false
        }
        self.city = ""
        self.state = ""
        self.country = ""
        self.lat = ""
        self.long = ""
        fetcher?.sourceTextHasChanged(textField.text!+string)
        return true
        
    }
    func searchForRide(textField:UITextField)  {
        textField.resignFirstResponder()
    }
  }
  extension LocationViewController: CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("your Auto Complete Error is \(error)")
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let camera = GMSCameraPosition.camera(withLatitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude), zoom: 16.0)
        self.mapView.animate(to: camera)
        self.lat = "\(location.coordinate.latitude)"
        self.long = "\(location.coordinate.longitude)"
        //        self.marker.position = location.coordinate
        //        self.marker.map = self.mapView
        // Set Current Location
        self.updateLocation(location.coordinate) { (location) in
            if self.locationString != "" && self.locationString.lowercased() != "worldwide" || self.locationString.lowercased() == UserDefaultModule.shared.getcountryname()?.lowercased() {
                self.searchTextField.text = self.locationString
                self.getLocationFromAddr(self.searchTextField.text!)
            }
            else {
                if self.viewType == "profile" {
                    self.searchTextField.text = "\(self.city), \(self.state), \(self.country)"
                }
                else {
                    self.searchTextField.text = location
                }
            }
            self.mapView.isHidden = false
            self.markerButton.isHidden = false
        }
        
        self.locationManager.stopUpdatingLocation()
    }
    func updateLocation(_ coordinate: CLLocationCoordinate2D, location: @escaping (String) -> Void) {
        let geocoder = GMSGeocoder()
        var locString = ""
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                self.city = address.locality ?? ""
                self.state = address.administrativeArea ?? ""
                self.country = address.country ?? ""
                locString = lines.joined(separator: "\n")
            }
            location(locString)
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture){
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                let point = mapView.center
                let coordinates = mapView.projection.coordinate(for: CGPoint(x: point.x, y: point.y))
                
                self.lat = "\(coordinates.latitude)"
                self.long = "\(coordinates.longitude)"
                self.updateLocation(coordinates) { (location) in
                    self.searchTextField.text = location
                }
            }
        }
    }
    
    func getLocationFromAddr(_ location: String) {
        ADMIN_VIEW_MODEL.loadLocationData(address: location, onSuccess: { (result) in
            if result["status"].stringValue == "OK" {
                for addressDict in result["results",0,"address_components"].arrayValue {
                    let type = addressDict["types"].arrayValue
                    if type.contains("locality") {
                        self.city = addressDict["long_name"].stringValue
                    }
                    else if type.contains("administrative_area_level_1") {
                        self.state = addressDict["long_name"].stringValue
                    }
                    else if type.contains("country") {
                        self.country = addressDict["long_name"].stringValue
                    }
                }
                self.locationString = self.searchTextField.text!
                self.lat = result["results",0,"geometry","location","lat"].stringValue
                self.long = result["results",0,"geometry","location","lng"].stringValue
                let camera = GMSCameraPosition.camera(withLatitude: result["results",0,"geometry","location","lat"].doubleValue, longitude: result["results",0,"geometry","location","lng"].doubleValue, zoom: 16.0)
                self.mapView.isHidden = false
                self.markerButton.isHidden = false
                self.mapView.animate(to: camera)
                self.setLocationButton.isUserInteractionEnabled = true
                //                self.mapView.camera = camera
                //                self.marker.position = CLLocationCoordinate2D(latitude: result["results",0,"geometry","location","lat"].doubleValue, longitude: result["results",0,"geometry","location","lng"].doubleValue)
                //                self.marker.map = self.mapView
            }
        }) { (failure) in
        }
    }
    func reverseGeoCoding(location: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                return
            }
        }
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
  }
  //MARK: Location auto complete fetcher
  extension LocationViewController: GMSAutocompleteFetcherDelegate {
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("Did Fail Auto Complete With Error :\(error.localizedDescription)")
        
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        self.locationArray.removeAllObjects()
        for prediction in predictions{
            let mutableDict = NSMutableDictionary()
            print("prediction value in predictions : \(prediction)")
            mutableDict.setValue(prediction.attributedPrimaryText.string, forKey: "address_first")
            mutableDict.setValue(prediction.attributedSecondaryText?.string, forKey: "address_second")
            mutableDict.setValue(prediction.placeID, forKey: "placeID")
            mutableDict.setValue(prediction.attributedFullText.string, forKey: "address_full")
            self.locationArray.addObjects(from: [mutableDict])
        }
        if self.locationArray.count == 0
        {
            self.dropDown.hide()
        }
        else
        {
            configDropDownView()
            DispatchQueue.main.async {
                self.dropDown.show()
            }
        }
    }
    func configDropDownView() {
        dropDown.anchorView = self.searchView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.width = self.searchView.frame.width
        dropDown.semanticContentAttribute = .unspecified
        _ = self.locationArray
        var countryArray = [String]()
        for country in self.locationArray {
            let countryDict = country as! Dictionary<String, Any>
            countryArray.append(countryDict["address_full"] as? String ?? "")
        }
        dropDown.dataSource = countryArray
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.setLocationButton.isUserInteractionEnabled = false
            self.searchTextField.text = item
            self.searchTextField.endEditing(true)
            //            let countryDict = self.locationArray[index] as! Dictionary<String, Any>
            self.getLocationFromAddr(item)
            print("Selected item: \(item) at index: \(index)")
        }
    }
  }
  
  
