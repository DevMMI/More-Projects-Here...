//
//  SignUpViewController.swift
//  Village
//
//  Created by Mohamed Bande on 08/30/17.
//  Copyright © 2017 Village. All rights reserved.
// View when you're actually playing tag

import UIKit
import MapKit
import MapKitGoogleStyler
import CoreLocation
import CoreData
import Firebase

class TagViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
	var groupID: String?
	var myGroupRef: FIRDatabaseReference?
	var name: String?
	var username: String?
	var userChildKey: String?
	var locValue:CLLocationCoordinate2D!
	var locManager: CLLocationManager!
	var mapView:  MKMapView!
	var mapJustOpened = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		
		
		// Setting up Location Services
		locManager = CLLocationManager()
		
		if CLLocationManager.locationServicesEnabled() {
			print("Location services enabled")
			locManager.delegate = self
			locManager.desiredAccuracy = kCLLocationAccuracyBest
			locManager.distanceFilter = 500
			locManager.requestWhenInUseAuthorization()
			locManager.startUpdatingLocation()
			locValue = locManager.location?.coordinate
		}else{ return}
	 
	 // Initializing and setting up default locations for MapView
		let initialLocation = CLLocation(latitude: 40.2659, longitude: -96.7467)
		mapView = MKMapView(frame: .zero)
		centerMapOnLocation(location: initialLocation)
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.showsPointsOfInterest = false
		mapView.delegate = self
		mapView.showsUserLocation = true
		mapView.tintColor = .black
		configureTileOverlay()
		setupMapView()
		setupGroup()
		setupLocationChangeListener()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func centerMapOnLocation(location: CLLocation) {
		print("Location", location.coordinate.latitude, location.coordinate.longitude)
		let regionRadius: CLLocationDistance = 1000
		let coordinatesRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
		mapView.setRegion(coordinatesRegion, animated: true)
		view.addSubview(mapView)
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if annotation.isKind(of: MKUserLocation.self){
			let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
			annotationView.canShowCallout = true
			
			let label = UILabel(frame: .zero)
			label.text = annotation.title!
			label.backgroundColor = .black
			label.textColor = .white
			label.adjustsFontSizeToFitWidth = true
			let labelView: UIView = {
				let view = UIView(frame: .zero)
				view.addSubview(label)
				view.backgroundColor = .white
				label.frame = view.frame
				label.translatesAutoresizingMaskIntoConstraints = false
				return view
			}()
			annotationView.image = UIImage(named: "run.png")
			annotationView.detailCalloutAccessoryView = labelView
			return annotationView
		}
		
		let identifier = "MyCustomAnnotation"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
		
		if (annotationView != nil){
			annotationView?.annotation = annotation
		}else{
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			annotationView?.canShowCallout = true
			let label = UILabel(frame: .zero)
			label.text = annotation.title!
			label.backgroundColor = .white
			label.textColor = .black
			label.translatesAutoresizingMaskIntoConstraints = false
			let labelView: UIView = {
				let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
				view.addSubview(label)
				label.frame = view.frame
				return view
			}()
			annotationView?.detailCalloutAccessoryView = labelView
			
			// Resize image
			let pinImage = UIImage(named: "run.png")
			let size = CGSize(width: 50, height: 50)
			UIGraphicsBeginImageContext(size)
			
			pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
			let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			annotationView?.image = resizedImage
		}
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		let userLocation = locations.last
		let coordinate = userLocation?.coordinate
		if (mapJustOpened){
			centerMapOnLocation(location: userLocation!)
			mapJustOpened = false
		}
		let latitude = NSNumber(value: (coordinate?.latitude)! as Double)
		let longitude = NSNumber(value: (coordinate?.longitude)! as Double)
		let latString = latitude.stringValue
		let longString = longitude.stringValue

		let myRef = myGroupRef?.child("users").child(userChildKey!).child("location")
		myRef?.updateChildValues(["latitude": latString])
		myRef?.updateChildValues(["longitude": longString])
	}
	
	var users: [User] = []
	var firstListenDone = false
	var notFirst = false
	
	func setupLocationChangeListener(){
		var handle: UInt = 0
		let ref = myGroupRef?.child("users")
		var getIn = false
		handle = ref!.observe(.childAdded, with: { (snapshot) in
			if(getIn){
				// end else, watch for location change
				self.updateLocations(users: self.users)
				ref?.observe(.childChanged, with: { (snapshot) in
					if let dictionary = snapshot.value as? [String: AnyObject]{
						let user = User()
						try? user.setValuesForKeys(dictionary)
						if(user.username == self.username){
							
						}
						else{
							
							let changedUser = self.users.first(where: { (myUser) -> Bool in
								if(myUser.username == user.username){
									return true
								}
								return false
							})
							if((changedUser) != nil){
								let index = self.users.index(of: changedUser!)
								self.users[index!] = user
								
								self.updateLocations(users: self.users)
								
							}
						}
						
					}
				})
			}
			else{
				 if let dictionary = snapshot.value as? [String: AnyObject]{
					 let user = User()
					
					 try? user.setValuesForKeys(dictionary)
					 print("\n\n\n\n\nuser", user.username)
					 self.users.append(user)
					 let isEmpty = self.users.isEmpty
					
					if(self.notFirst && !isEmpty && self.users[0].username == user.username){
						self.firstListenDone = true
						getIn = true
						
						 }
					self.notFirst = true
					
				}
				
				}
			self.updateLocations(users: self.users)
	})
		
		
		
 }
	
	func updateLocations(users: [User]){
		let allAnnotations = self.mapView.annotations
		self.mapView.removeAnnotations(allAnnotations)
		users.forEach { (user) in
			
			if(user == users.last){
				
			}
			else{
				
				// Create annotation
				let pointAnnotation = MKPointAnnotation()
				
				let userlocation = Location()
				userlocation.setValuesForKeys(user.location)
				
				let latitude = NumberFormatter().number(from: userlocation.latitude!)?.doubleValue
				let longitude = NumberFormatter().number(from: userlocation.longitude!)?.doubleValue
				pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
				pointAnnotation.title = user.username
				
				// Set what the map will snap to, coordinates and region
				let currentRadius = mapView.currentRadius()
				print(currentRadius)
				//let coordinatesRegion = MKCoordinateRegionMakeWithDistance(pointAnnotation.coordinate, currentRadius, currentRadius)
				//mapView.setRegion(coordinatesRegion, animated: true)
				
				// Add annotation
				mapView.addAnnotation(pointAnnotation)
				
			}
			
		}
	}
	
	func updateOneLocation(user: User){
		// Create annotation
		let pointAnnotation = MKPointAnnotation()
		
		pointAnnotation.title = user.username
		let userlocation = Location()
		userlocation.setValuesForKeys(user.location)
		
		let latitude = NumberFormatter().number(from: userlocation.latitude!)?.doubleValue
		let longitude = NumberFormatter().number(from: userlocation.longitude!)?.doubleValue
		pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
		
		// Set what the map will snap to, coordinates and region
		let currentRadius = mapView.currentRadius()
		print(currentRadius)
		//let coordinatesRegion = MKCoordinateRegionMakeWithDistance(pointAnnotation.coordinate, currentRadius, currentRadius)
		//mapView.setRegion(coordinatesRegion, animated: true)
		
		// Add annotation
		mapView.addAnnotation(pointAnnotation)
	}
		
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		// This is the final step. This code can be copied and pasted into your project
		// without thinking on it so much. It simply instantiates a MKTileOverlayRenderer
		// for displaying the tile overlay.
		if let tileOverlay = overlay as? MKTileOverlay {
			return MKTileOverlayRenderer(tileOverlay: tileOverlay)
		} else {
			return MKOverlayRenderer(overlay: overlay)
		}
	}
	
	func setupGroup(){
		
		// Find specific group we're in
	  var handle: UInt = 0
	  let ref = FIRDatabase.database().reference().child("groups")
	  handle = ref.observe(.childAdded, with: { (snapshot) in
		  if let dictionary = snapshot.value as? [String: AnyObject]{
			  let myGroup = NewGroup()
			
			  try? myGroup.setValuesForKeys(dictionary)
			  if let searchName = self.groupID{
				  if (searchName == myGroup.id){
					  self.myGroupRef = ref.child(snapshot.key)
					  ref.removeObserver(withHandle: handle)
					  self.groupLabel.text = myGroup.name
					  return
				  }
			  } // end if
			  print("not found", myGroup.name )
		  }
		
	  })
		
		
		// fetch userchildref from coredata
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
		
		do {
			let group = try managedContext.fetch(fetchRequest)
			let value = (group.last as AnyObject).value(forKey: "userchildkey")
			userChildKey = value as! String
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
		
		
	} // end setup group
	
	
	let groupLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.font = UIFont(name: "Arial", size: 30)
		label.backgroundColor = .white
		label.textAlignment = .center
		label.layer.shadowRadius = 6
		label.layer.shadowOffset = CGSize(width: 3, height: 3)
		label.layer.shadowColor = UIColor.black.cgColor
		label.layer.shadowOpacity = 1
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let centerToLocationButton: UIButton = {
		let button = UIButton(type: .system) as UIButton
		button.frame = .zero
		let image = UIImage(named: "location.png")
		button.setImage(image, for: .normal)
		button.backgroundColor = .clear
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(HomeViewController.centerMapOnUserButtonClicked), for:.touchUpInside)
		return button
	}()
	
	func centerMapOnUserButtonClicked() {
		let myLocation = locManager.location
		if myLocation != nil {
			centerMapOnLocation(location: myLocation!)
		}
	}
	
	
	/*
	// Create Map Location for a given user
	func createPinPost(text: String){
		// Create annotation
		let pointAnnotation = MKPointAnnotation()
		pointAnnotation.title = text
		pointAnnotation.coordinate = getCoordinatesPinIsPointingTo()
		
		// Set what the map will snap to, coordinates and region
		let currentRadius = mapView.currentRadius()
		print(currentRadius)
		let coordinatesRegion = MKCoordinateRegionMakeWithDistance(pointAnnotation.coordinate, currentRadius, currentRadius)
		mapView.setRegion(coordinatesRegion, animated: true)
		
		// Add annotation
		mapView.addAnnotation(pointAnnotation)
	}

*/
	
	/* Setting up the different views *********************/
	func setupMapView(){
		view.addSubview(mapView)
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		
		mapView.addSubview(groupLabel)
		groupLabel.centerYAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 35).isActive = true
		groupLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		groupLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
		groupLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		
		mapView.addSubview(centerToLocationButton)
		centerToLocationButton.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
		centerToLocationButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
		centerToLocationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
		centerToLocationButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -10).isActive = true
		
		
	 }
	
	private func configureTileOverlay() {
		// We first need to have the path of the overlay configuration JSON
		guard let overlayFileURLString = Bundle.main.path(forResource: "base", ofType: "json") else {
			return
		}
		let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
		
		// After that, you can create the tile overlay using MapKitGoogleStyler
		guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else {
			return
		}
		
		// And finally add it to your MKMapView
		mapView.add(tileOverlay)
	}
	
}

extension MKMapView {
	
	func topCenterCoordinate() -> CLLocationCoordinate2D {
		return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
	}
	
	func currentRadius() -> Double {
		let centerCoordinate = self.centerCoordinate
		let centerLocation: CLLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
		let topCenterCoordinate = self.topCenterCoordinate()
		let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
		let radius = centerLocation.distance(from: topCenterLocation)
		return radius
	}
	
}

class User: NSObject{
   var location = [String: String]()
	var username: String?
}

class Location: NSObject {
	var latitude: String?
	var longitude: String?
}



