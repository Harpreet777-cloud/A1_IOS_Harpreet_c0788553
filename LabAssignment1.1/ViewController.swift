//
//  ViewController.swift
//  LabAssignment1.1
//
//  Created by user186844 on 1/25/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionBtn: UIButton!
    
    
    // create location manager
    var locationManager = CLLocationManager()

    
    // create the places array
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        
        directionBtn.isHidden = true
        
        // we assign the delegate property of the location manager to be this class
        locationManager.delegate = self
        
        // we define the accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // rquest for the permission to access the location
        locationManager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationManager.startUpdatingLocation()
        
        //   define latitude and longitude
        let latitude: CLLocationDegrees = 51.2538
        let longitude: CLLocationDegrees = 85.3232
       
        // 2nd step is to display the marker on the map
       displayLocation(latitude: latitude, longitude: longitude, title: "Toronto City", subtitle: "You are here")
       displayLocation(latitude: latitude, longitude: longitude, title: "Brampton", subtitle: "You are here")
       displayLocation(latitude: latitude, longitude: longitude, title: "Missisauga", subtitle: "You are here")
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion))
        mapView.addGestureRecognizer(uilpgr)
        
        // add double tap
        addDoubleTap()
        
        // giving the delegate
        mapView.delegate = self
        
        // add annotations for the places
       addAnnotationsForPlaces()
        
        // add polyline
     //  addPolyline()
        
        // add polygon
       addPolygon()
        
    }
    
    //MARK: - draw route between two places
    @IBAction func drawRoute(_ sender: UIButton) {
        mapView.removeOverlays(mapView.overlays)
    //requesting
        let directionRequest = MKDirections.Request()
        
        // transportation type
        directionRequest.transportType = .automobile
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
       directions.calculate { (response, error) in
           guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
   
        }
    }
    
    
    //MARK: -   using the didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        removePin()
//        print(locations.count)
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "my place", subtitle: "you are here")
    }
    
    //MARK: - add annotations for the places
    func addAnnotationsForPlaces() {
        mapView.addAnnotations(places)
        
      //  mapView.addOverlays(overlays)
    }
    
  
    //MARK: - polygon method
    func addPolygon() {
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
    }
    
    //MARK: - double tap func
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        
        // add annotation
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = "my destination"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
       // destination = coordinate
        directionBtn.isHidden = false
    }
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addLongPressAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // add annotation for the coordinatet
        let annotation = MKPointAnnotation()
        annotation.title = "my favorite"
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    //MARK: - remove pin from map
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
//        map.removeAnnotations(map.annotations)
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 10
        let lngDelta: CLLocationDegrees = 10
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        mapView.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }

}

extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "my location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.systemRed
            return annotationView
        case "my destination":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            return annotationView
        case "my favorite":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        default:
            return nil
        }
    }
    
    //MARK: - callout accessory control tapped
   func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your destination", message: "Favourite of many", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       // if overlay is MKCircle {
        //    let rendrer = MKCircleRenderer(overlay: overlay)
           // rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
           // rendrer.strokeColor = UIColor.green
           // rendrer.lineWidth = 2
           // return rendrer
      //  }
    if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    //create the locations
//
//
//    let manager = CLLocationManager()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//    mapView.isZoomEnabled = false
//    map.showsUserLocation = true
//
//    directionBtn.isHidden = true
//    / we assign the delegate property of the location manager to be this class
//    locationManager.delegate = self
//
//    // we define the accuracy of the location
//    locationMnager.desiredAccuracy = kCLLocationAccuracyBest
//
//    // rquest for the permission to access the location
//    locationMnager.requestWhenInUseAuthorization()
//
//    // start updating the location
//    locationMnager.startUpdatingLocation()
//
//    // 1....define latitude and longitude
//        let latitude:CLLocationDegrees = 51.2538
//        let longitude: CLLocationDegrees = 85.3232
//
//        //2nd step is to display the marker
//       //displayLocation(latitude: latitude, longitude: longitude, title: "Toronto", subtitle: "You are here")
//        //display location
//      //  displayLocation(latitude: latitude, longitude: longitude, title: "Missisauga", subtitle: "You are here")
//      //  displayLocation(latitude: latitude, longitude: longitude, title: "Brampton", subtitle: "You are here")
//        let uilpgr = UILongPressGestureRecognizer(target:self , action:#selector(addLongPressAnnotation))
//     mapView.addGestureRecognizer(uilpgr)
//    // add double tap
//    addDoubleTap()
//
//    // giving the delegate of MKMapViewDelegate to this class
//    map.delegate = self
//
//    // add annotations for the places
////        addAnnotationsForPlaces()
//
//    // add polyline
////        addPolyline()
//
//    // add polygon
////        addPolygon()
//
//
//}
//
//   // addDoubleTap
//    //addDoubleTap()
//
//
//
//    //annotations
//   //addAnnotationsForPlaces()
//
//    //MARK:- add annotations
//
//  //  let places = Place.getPlaces()
//
//   // func addAnnotationsForPlaces() {
//       // mapView.addAnnotation(places as! MKAnnotation)
//
// //   }
//    //function
//        func addDoubleTap() {
//           let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
//            doubleTap.numberOfTapsRequired = 2
//           mapView.addGestureRecognizer(doubleTap)
//        }
//
//    @objc func dropPin(sender: UITapGestureRecognizer) {
//        removePin()
//
//    //add annotation
//        let touchPoint = sender.location(in: mapView)
//        let coordinate = mapView.convert(touchPoint,  toCoordinateFrom: mapView)
//        let annotation = MKPointAnnotation()
//        annotation.title = "New destination"
//        annotation.coordinate = coordinate
//        mapView.addAnnotation(annotation)
//    }
//        //MARK:- long press gesture recognizer
//
//        @objc func addLongPressAnnotation(gestureRecognizer: UIGestureRecognizer)  {
//            let touchPoint = gestureRecognizer.location(in: mapView)
//            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//            //add annotation for coordinates
//            let annotation = MKPointAnnotation()
//            annotation.title = "New destination"
//            annotation.coordinate = coordinate
//            mapView.addAnnotation(annotation)
//        }
//        //MARK: - Remove pin from map
//
//    func removepin() {
//        for annotation in mapView.annotations {
//        mapView.removeAnnotation(annotation)
//    }
//
//    }
//
//    //MARK: - display user location method
//    func displayLocation(latitude: CLLocationDegrees,longitude:CLLocationDegrees,title:String,subtitle:String) {
//
//
//    //2nd step /- define span
//    let latDelta: CLLocationDegrees = 100
//        let lngDelta : CLLocationDegrees = 100
//    let span = MKCoordinateSpan(latitudeDelta:latDelta, longitudeDelta: lngDelta)
//    //3rd step is to use the location
//    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    //4th step is to define the region
//    let region = MKCoordinateRegion(center: location, span: span)
//    //5th step is to set the region for the map
//    mapView.setRegion(region, animated:true)
//    //6th step is to define annotation
//    let annotation = MKPointAnnotation()
//    annotation.title = title
//    annotation.subtitle = subtitle
//    annotation.coordinate = location
//    mapView.addAnnotation(annotation)
//
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

