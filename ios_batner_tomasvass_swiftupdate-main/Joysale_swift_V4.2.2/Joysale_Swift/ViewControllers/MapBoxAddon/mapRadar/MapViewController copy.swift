

import UIKit
import DropDown
import MapboxMaps
import MapboxGeocoder
import GooglePlaces
import GoogleMaps
import CoreLocation
import RadarSDK

protocol customLocationDelegate : AnyObject{
    func locationAct(city: String, state: String, country: String, countryCode: String,lat: String, long: String, location: String)
}



class MapViewController: UIViewController {

    @IBOutlet weak var markerButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var bottomStackview: UIStackView!
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var removeLocationButton: UIButton!
    @IBOutlet weak var setLocationButton: UIButton!
    var mapView: MapView!
    var geocoder: Geocoder!
    var pointAnnotationManager: PointAnnotationManager?
    let dropDown = DropDown()
    var locationManager = CLLocationManager()
    var selectedCoordinate = CLLocationCoordinate2D()
    var hasUserMovedMap = false
    var latestSearchText = ""
     var delegate: customLocationDelegate?
    var viewType = ""
    var isFromHome = false
    var isProgrammaticTextChange = false
    var city = ""
    var state = ""
    var country = ""
    var countryCode = ""
    var lat = ""
    var long = ""
    var locationString = ""
    var debounceWorkItem: DispatchWorkItem?
    var locationArray = NSMutableArray()
    var didSelectFromDropdown = false
    var addressStrings: [String] = []
    // MARK: - Data
    var results: [RadarAddress] = []
    var autocompleteWorkItem: DispatchWorkItem?
    // MARK: - Location
    let locationManagerradar = CLLocationManager()
    var userLocationradar: CLLocation?

    // MARK: - DropDown
    let dropDownradar = DropDown()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
            setupMapboxMap()
        self.mapView.gestures.delegate = self

    }
    
    func configUI() {
        self.searchTextField.delegate = self
        setupDropDown()
        enableTextChangeListener()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.customRightBarButtonView(title: "", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 14), imageName: "detail_back", isLeft: true, vc: self, transparantView: false)
        self.navigationController?.customNavigationBarView(title: "location", fColor: "whitecolor", fontName: UIFont(name: APP_FONT_REGULAR, size: 20), vc: self)
        self.removeLocationButton.setBorder(color: UIColor(named: "AppThemeColorNew"))
        self.setLocationButton.backgroundColor = UIColor(named: "AppThemeColorNew")
        self.setLocationButton.cornerMiniumRadius()
        self.searchView.cornerViewMiniumRadius()
        self.removeLocationButton.config(color: UIColor(named: "AppThemeColorNew"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "")
        self.setLocationButton.config(color: UIColor(named: "whitecolor"), font: UIFont(name: APP_FONT_REGULAR, size: 15), align: .center, title: "set_location")
        if self.viewType == "chat" {
            self.setLocationButton.setTitle(getLanguage["share_your_location"], for: .normal)
            self.removeLocationButton.isHidden = true
        }
        else if self.viewType == "profile" || self.viewType == "addProduct"{
            self.setLocationButton.setTitle(getLanguage["set_location"], for: .normal)
            self.removeLocationButton.isHidden = true
        }else if self.viewType == "visit"{
            self.removeLocationButton.isHidden = true
            self.searchView.isHidden = true
            self.setLocationButton.isHidden = true
        }
        self.searchTextField.config(color: UIColor(named: "appblackcolor"), align: .left, placeHolder: "search", font: UIFont(name: APP_FONT_REGULAR, size: 14))
        geocoder = Geocoder(accessToken: MAPBOXACCESSTOKEN)
        self.removeLocationButton.setTitle(UserDefaultModule.shared.getcountryname() ?? "", for: .normal)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
       self.currentLocationView.darkElevationEffect()
       debugPrint("locationString -> \(self.locationString)")
        
    }
    func setupDropDown() {
        dropDown.anchorView = searchView
        dropDown.direction = .bottom
        dropDown.cornerRadius = 8
        dropDown.bottomOffset = CGPoint(x: 0, y: searchView.bounds.height)
        dropDown.width = searchView.frame.width
        dropDown.textFont = .systemFont(ofSize: 14)
        dropDown.dismissMode = .automatic
        
        
     

        dropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }

            let selected = self.results[index]

            // 🔐 LOCK autocomplete
            self.didSelectFromDropdown = true

            // ✅ Programmatic text set
            self.searchTextField.text = selected.formattedAddress
            self.searchTextField.resignFirstResponder()
            self.dropDown.hide()

            self.lat = "\(selected.coordinate.latitude)"
            self.long = "\(selected.coordinate.longitude)"
            self.state = selected.state ?? ""
            self.country = selected.country ?? ""
            self.countryCode = selected.countryCode ?? ""
            self.locationString = selected.formattedAddress ?? ""

            print("Dropdown selected → autocomplete locked")
        }

    }

    @objc func textChanged() {

        // ❌ Stop after dropdown select
        if didSelectFromDropdown {
            didSelectFromDropdown = false
            return
        }

        guard
            let text = searchTextField.text,
            text.count >= 3,
            let nearLocation = userLocationradar
        else {
            dropDown.hide()
            return
        }

        // 🛑 Cancel previous pending API call
        autocompleteWorkItem?.cancel()

        // ⏳ Debounce (300ms is sweet spot)
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            Radar.autocomplete(
                query: text,
                near: nearLocation,
                layers: ["place", "locality"],
                limit: 10,
                country: UserDefaultModule.shared.getcountrycode() ?? "IN"
            ) { [weak self] status, addresses in
                guard let self = self else { return }

                // ⚠️ Ignore outdated responses
                guard self.searchTextField.text == text else { return }

                guard status == .success, let addresses = addresses else {
                    self.dropDown.hide()
                    return
                }

                self.results = addresses
                self.dropDown.dataSource = addresses.compactMap { $0.formattedAddress }
                self.dropDown.show()
            }
        }

        autocompleteWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }



    




    
          override var preferredStatusBarStyle : UIStatusBarStyle {
              return self.updateStatusBarStyle()
          }
    
   


    
    
    
    func getLocationFromAddr(_ address: String, isSelected: Bool) {
        let token = Bundle.main.object(forInfoDictionaryKey: "MAPBOXACCESSTOKEN") as? String ?? ""
        let geocoder = Geocoder(accessToken: token)
        
        var options: GeocodeOptions
        if viewType != "visit"{
            options = ForwardGeocodeOptions(query: address)
            options.allowedISOCountryCodes = [UserDefaultModule.shared.getcountrycode() ?? "IN"]
            options.focalLocation = locationManager.location
            options.maximumResultCount = 1
        }else{
            options = ReverseGeocodeOptions(location: CLLocation(latitude: Double(self.lat) ?? 0, longitude: Double(self.long) ?? 0))
            options.allowedISOCountryCodes = [UserDefaultModule.shared.getcountrycode() ?? "IN"]
            options.maximumResultCount = 1
        }

        geocoder.geocode(options) { [weak self] (placemarks, attribution, error) in
            guard let self = self else { return }
            // ✅ No valid result
            guard let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate else {
                DispatchQueue.main.async {
//                    self.searchTextField.text = ""
                    self.setLocationButton.isUserInteractionEnabled = false

                    let alert = UIAlertController(
                        title: "Invalid Address",
                        message: "Please select a location from the dropdown list.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                }
                return
            }

            // ✅ Valid result
            self.lat = "\(coordinate.latitude)"
            self.long = "\(coordinate.longitude)"
            self.city = placemark.postalAddress?.city ?? ""
            self.state = placemark.postalAddress?.state ?? ""
            self.country = placemark.postalAddress?.country ?? ""
            self.countryCode = placemark.postalAddress?.country ?? ""
            self.locationString = placemark.qualifiedName ?? ""

            DispatchQueue.main.async {
                let cameraOptions = CameraOptions(center: coordinate, zoom: 14)
                self.mapView.mapboxMap.setCamera(to: cameraOptions)
                self.addMarker(at: coordinate)
//                self.searchTextField.text = self.locationString
                self.setLocationButton.isUserInteractionEnabled = true
             

            }
        }
    }




    func enableTextChangeListener() {
        searchTextField.addTarget(
              self,
              action: #selector(textChanged),
              for: .editingChanged
          )
    }

    
    func setupMapboxMap() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "MAPBOXACCESSTOKEN") as? String, !token.isEmpty else {
            print("❌ Invalid or missing Mapbox token")
            return
        }
        let resourceOptions = ResourceOptions(accessToken: token)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions, styleURI: .streets)
        // Ensure bounds are valid
        guard mapContainer.bounds != .zero else {
            print("❌ mapContainer.bounds is zero")
            return
        }
        mapView = MapView(frame: mapContainer.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapContainer.addSubview(mapView)
        mapView.ornaments.options.compass.visibility = .hidden
        // Configure location puck
        mapView.location.options.puckType = .puck2D()
        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }

            if self.locationString == UserDefaultModule.shared.getcountryname()?.lowercased() ?? ""{
                self.centerToUserLocation()
            }else{
                if locationString == "" {
                    self.locationString = UserDefaultModule.shared.getcountryname()?.lowercased() ?? ""
                    if self.viewType == "chat" {
                        self.centerToUserLocation()
                    }
                }
                print("laslas",self.locationString)
//                self.getLocationFromAddr(self.locationString, isSelected: true)
          
            }
            
    
        }

        mapView.mapboxMap.onEvery(.cameraChanged) { [weak self] _ in
            guard let self = self else { return }

            guard self.hasUserMovedMap else { return } // Only update if user moved

            let centerCoordinate = self.mapView.mapboxMap.cameraState.center

            self.debounceWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                self.selectedCoordinate = centerCoordinate
                self.addMarker(at: centerCoordinate)
//                self.updateLocationDetails(for: centerCoordinate)
            }
            self.debounceWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
        }


        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
    }

    
        override func viewWillAppear(_ animated: Bool) {
            self.updateTheme(page: "present")
            NotificationCenter.default.addObserver(self, selector: #selector(self.barButtonAction(_:)), name: Notification.Name("BarButtonAction"), object: nil)
        }
        override func viewWillDisappear(_ animated: Bool) {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("BarButtonAction"), object: nil)
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


    func centerToUserLocation() {
        guard let location = locationManager.location else { return }
        let cameraOptions = CameraOptions(center: location.coordinate, zoom: 14)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        addMarker(at: location.coordinate)
//        updateLocationDetails(for: location.coordinate)
    }

    func addMarker(at coordinate: CLLocationCoordinate2D) {
        pointAnnotationManager?.annotations.removeAll()
        var annotation = PointAnnotation(coordinate: coordinate)
        annotation.image = .init(image: UIImage(), name: "locationGreen")
        pointAnnotationManager?.annotations = [annotation]
        selectedCoordinate = coordinate
    }
    

    func updateLocationDetails(for coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let result = response?.firstResult() else { return }
            self.city = result.locality ?? ""
            self.state = result.administrativeArea ?? ""
            self.country = result.country ?? ""
            self.countryCode = result.country ?? ""
            self.lat = "\(coordinate.latitude)"
            self.long = "\(coordinate.longitude)"
            self.locationString = result.lines?.joined(separator: ", ") ?? ""
           
            DispatchQueue.main.async {
//                self.searchTextField.text = self.locationString
            }
        }
    }
    
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

 
    @IBAction func setLocationTapped(_ sender: UIButton) {
        
        guard !lat.isEmpty, !long.isEmpty else {
            showAlert(message: "Invalid location. Please select from the dropdown.")
            return
        }

        guard let searchText = searchTextField.text, !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let alert = UIAlertController(title: nil, message: "Please enter or select a valid location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        let currentCountry = UserDefaultModule.shared.getcountryname()?.lowercased() ?? ""
        print("self.countrytest",self.country)
        print("self.currentCountrytest",currentCountry)
        if self.country.lowercased() == currentCountry {
            print("self.locationStringchk1",self.locationString)
            print("self.locationStringchk2",self.city)
            print("self.locationStringchk3",self.state)
            print("self.locationStringchk4",self.country)
            print("self.locationStringchk5",self.lat)
            print("self.locationStringchk6",self.long)
            DispatchQueue.main.async  { [self] in
                self.delegate?.locationAct(city: city, state: state, country: country, countryCode: countryCode, lat: lat, long: long, location: locationString)
            }
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: nil, message: "Please select a location from your country (\(currentCountry))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
        }
    }
    

    

@IBAction func removeLocationTapped(_ sender: Any) {
        self.locationString = UserDefaultModule.shared.getcountryname() ?? "worldwide"
        self.lat = ""
        self.long = ""
        self.city = ""
        self.state = ""
        self.country = ""
        self.countryCode = ""
        delegate?.locationAct(city: city, state: state, country: country, countryCode: countryCode, lat: lat, long: long, location: locationString)
        navigationController?.popViewController(animated: true)
        
    }
    @IBAction func currentLocationTapped(_ sender: Any) {
        centerToUserLocation()
    }
    
    
}
extension MapViewController: GestureManagerDelegate {
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        hasUserMovedMap = true
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        
    }
    
  
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            let alert = UIAlertController(title: "Permission Required", message: "Please enable location services in settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            present(alert, animated: true)
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userLocationradar = loc
        addMarker(at: loc.coordinate)
//        updateLocationDetails(for: loc.coordinate)
        locationManager.stopUpdatingLocation()
    }
    
    



}



extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        dropDown.hide()
        return true
    }

//    func textFieldDidEndEditing(_ textField: UITextField) {
//        searchForRide(textField: textField)
//        print(textField.text ?? "")
//    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        searchForRide(textField: textField)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent emoji input
        if string.containsEmoji {
            return false
        }
        return true
    }
}








