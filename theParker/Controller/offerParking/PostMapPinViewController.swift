
import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

class PostMapPinViewController: UIViewController, GMSMapViewDelegate , CLLocationManagerDelegate{
    
    var timer = Timer()
    var timer1 = Timer()
    var HandleLocation:DatabaseHandle?
    var ref:DatabaseReference?
    var count = 0
    var FetchedArray:Int? = 0
    var flag = 0
    
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var nextBTn: UIButton!
    
    var CurLocationNow:CLLocation?
    var locationManager = CLLocationManager()
    var locationSelected = Located.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var selectedLocation : CLLocationCoordinate2D?
    var longPressRecognizer = UILongPressGestureRecognizer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = HextoUIColor.instance.hexString(hex: "#4C177D")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 50)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "PinLocation"
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handling()
        self.nextBTn.clipsToBounds = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(self.longPress))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delegate = self
        MapView.addGestureRecognizer(longPressRecognizer)
        
        MapView.isMyLocationEnabled = true
        MapView.settings.compassButton = true
        
        self.scheduledTimerWithTimeInterval()
    }
    
    @IBAction func NextButtonClicked(_ sender: Any) {
    
        if count > 0 {
            print(" BUTTO PREESSSESS HERE")
            self.LoadIt()
            self.nextBTn.isEnabled = false
        }
        
    }
 
}

extension PostMapPinViewController{
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.chartload), userInfo: nil, repeats: true)
    }
    
    @objc func chartload(){
        
        if self.CurLocationNow?.coordinate.latitude != nil && self.CurLocationNow?.coordinate.longitude != nil {
            
            let camera2 = GMSCameraPosition.camera(withLatitude: (self.CurLocationNow?.coordinate.latitude)!, longitude: (self.CurLocationNow?.coordinate.longitude)!, zoom: 18.0)
            
            self.MapView.camera = camera2
            self.MapView.delegate = self
            self.MapView.isMyLocationEnabled = true
            self.MapView.settings.myLocationButton = true
            self.MapView.settings.compassButton = true
            self.MapView.settings.zoomGestures = true
            self.stopTimer()
            
        }
    }
    
    func stopTimer(){
        timer.invalidate()
        
    }
    
    func alert(message:String )
    {
        let alertview = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertview.addAction(UIAlertAction(title: "Try Again!", style: .default, handler: {
            action in
            DispatchQueue.main.async {
                
                //  self.UISetup(enable: true)
            }
        }))
        self.present(alertview, animated: true, completion: nil)
        
    }
}

extension PostMapPinViewController{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        self.CurLocationNow = location
        //        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        //        self.googleMaps?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        MapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        MapView.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        MapView.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        MapView.isMyLocationEnabled = true
        MapView.selectedMarker = nil
        return false
    }
    
   
}

extension PostMapPinViewController : UIGestureRecognizerDelegate
{
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        let newMarker = GMSMarker(position: MapView.projection.coordinate(for: sender.location(in: MapView)))
        self.MapView.clear()
        self.selectedLocation = newMarker.position
        newMarker.map = MapView
        self.count += 1
        print(self.selectedLocation!)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}


extension PostMapPinViewController{
    
    func appendArray(completion: @escaping ((_ success:Bool)->())){
        
        let pushedLoc = String(describing: self.selectedLocation!)
        let lat:Double = (self.selectedLocation?.latitude)!
        let lon:Double = (self.selectedLocation?.longitude)!
        let latlongarrat:[Double] = [lat,lon]
        performSegue(withIdentifier: "parkingDetails", sender: nil)
        //self.performSegue(withIdentifier: "sspin", sender: latlongarrat)
        print("PUSHED LOC HERE")
        print(pushedLoc)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let sg = segue.destination as! ScrollPostViewController
        //sg.latlongstring = sender as! [Double]
    }
}

extension PostMapPinViewController{
    
    func handling(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.ref = Database.database().reference()
        //Going deep into firebase hierarchy
        self.HandleLocation = self.ref?.child("user").child(uid).child("ArrayPins").observe(.value, with: { (snapshot) in
            
            guard let value = snapshot.childrenCount as? UInt else { return }
                
                print("VALUE VALUE")
                print(value)
                let vvalue = Int(value)
                self.FetchedArray = vvalue
                
        })
    }
}

extension PostMapPinViewController{
    
    
    func LoadIt(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer1 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.chartload1), userInfo: nil, repeats: true)
    }
    
    @objc func chartload1(){
        
        if self.FetchedArray == 0 {
            alert(message: "Sonething went wrong")
        }
        else{
            self.stopTimer1()
            self.appendArray(completion: { success in
                if success {
                    print("Yahoo Yahoo Yahooo")
                    //self.performSegue(withIdentifier: "sspin", sender: nil)
                }
                else{
                    print("NO NO NO")
                }
            })
        }
        
        }
    
    
    func stopTimer1(){
        timer1.invalidate()
        
    }
}

    

