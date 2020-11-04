//
//  ProfileViewController.swift
//  OnboardingLottie
//
//  Created by Sai Raghu Varma Kallepalli on 6/11/19.
//  Copyright © 2019 Brian Advent. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ProfileViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, DatabaseListener {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var otherCardLabel: UILabel!
    @IBOutlet weak var userOneImg: UIImageView!
    @IBOutlet weak var userOneLabel: UILabel!
    @IBOutlet weak var userTwoImg: UIImageView!
    @IBOutlet weak var userTwoLabel: UILabel!
    @IBOutlet weak var userThreeImg: UIImageView!
    @IBOutlet weak var userThreeLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    
    var locationMgr: CLLocationManager = CLLocationManager()
    
    weak var databaseController: DatabaseProtocol?
    var dataList: [Sensor] = [Sensor]()
    
    var prevPoints = 1500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKitInitializers()
        
        moveLabels(y: -170)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate!.databaseController
        // Do any additional setup after loading the view.
    }
    
    var listenerType = ListenerType.data

    func onDataListChange(change: DatabaseChange, dataList: [Sensor]) {
        mapView.removeAnnotations(mapView.annotations)
        self.dataList = dataList
        
        let focusLocation = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: dataList[0].gps.curLat, longitude: dataList[0].gps.curLong), 50, 50)
        let cam = MKMapCamera()
        cam.centerCoordinate = CLLocationCoordinate2D(latitude: dataList[0].gps.curLat, longitude: dataList[0].gps.curLong)
        cam.pitch = 80
        cam.altitude = 100
        cam.heading = 0
        mapView.setRegion(focusLocation, animated: true)
        mapView.setCamera(cam, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: dataList[0].gps.curLat, longitude: dataList[0].gps.curLong)
        annotation.title = "Car"
        mapView.addAnnotation(annotation)
        
    }
    
    func getPoints(change: DatabaseChange, points: Int){
        print("Prev ",prevPoints,"Curr ", points,"In profile View ")
        self.scoreLabel.text = "\(points)"
        if(prevPoints > points)
        {
            self.progressLabel.text = "Down"
        }
        else if(prevPoints < points)
        {
            self.progressLabel.text = " Up "
        }
        prevPoints = points
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }

        let reuseId = "test"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.image = UIImage(named: "racing-4.png")
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        databaseController?.addListener(listener: self)
    }
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        databaseController?.removeListener(listener: self)
    }
    
    
    func moveLabels(y: CGFloat) {
        UIView.animate(withDuration: 2, animations: {
            self.profileView.transform = CGAffineTransform(translationX: 0, y: 460)
            self.profileLabel.transform = CGAffineTransform(translationX: 0, y: 460)
            self.mapView.transform = CGAffineTransform(translationX: 0, y: 210)
        })
        UIView.animate(withDuration: 1, animations: {
            self.score.transform = CGAffineTransform(translationX: 150, y: 0)
            self.scoreLabel.transform = CGAffineTransform(translationX: 150, y: 0)
            self.progress.transform = CGAffineTransform(translationX: -150, y: 0)
            self.progressLabel.transform = CGAffineTransform(translationX: -150, y: 0)
            self.bgImage.transform = CGAffineTransform(translationX: 0, y: y)
            self.otherCardLabel.transform = CGAffineTransform(translationX: 0, y: y)
            self.userOneImg.transform = CGAffineTransform(translationX: 0, y: y)
            self.userOneLabel.transform = CGAffineTransform(translationX: 0, y: y)
            self.userTwoImg.transform = CGAffineTransform(translationX: 0, y: y)
            self.userTwoLabel.transform = CGAffineTransform(translationX: 0, y: y)
            self.userThreeImg.transform = CGAffineTransform(translationX: 0, y: y)
            self.userThreeLabel.transform = CGAffineTransform(translationX: 0, y: y)
            self.bgImage.layer.cornerRadius = (self.bgImage.frame.size.width)/10
//            self.bgImage.layer.borderWidth = 5
//            self.bgImage.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.bgImage.clipsToBounds = true
        })
    }
    
    
    func mapKitInitializers() {
        mapView.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationMgr.distanceFilter = 10
        locationMgr.delegate = self
        locationMgr.startUpdatingHeading()
        locationMgr.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        locationMgr.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        let location: CLLocation = locations.last!
    
        let focusLocation = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), 50, 50)
        let cam = MKMapCamera()
        cam.centerCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        cam.pitch = 80
        cam.altitude = 100
        cam.heading = 0
        mapView.setRegion(focusLocation, animated: true)
        mapView.setCamera(cam, animated: true)
        let source = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if(dataList[0].gps.curLat != 0){
            let dest = CLLocationCoordinate2D(latitude: dataList[0].gps.curLat, longitude: dataList[0].gps.curLong)
            drawRoutes(sourceLocation: source, destinationLocation: dest)
        }
    }
    
    func drawRoutes(sourceLocation:CLLocationCoordinate2D , destinationLocation:CLLocationCoordinate2D)
    {

        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile


        let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                guard let directionResonse = response else {
                    if let error = error {
                        print("we have error getting directions==\(error.localizedDescription)")
                    }
                    return
                }
                
                let route = directionResonse.routes[0]
                self.mapView.add(route.polyline, level: .aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }

        }
        
        //MARK:- MapKit delegates

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 4.0
        return renderer
    }
    

}
