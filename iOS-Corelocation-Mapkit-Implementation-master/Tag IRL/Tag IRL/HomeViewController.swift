//
//  HomeViewController.swift
//  Village
//
//  Created by Mohamed Bande on 08/27/17.
//  Copyright © 2017 Village. All rights reserved.
//


import UIKit
import Firebase
import CoreLocation
import MapKit
import MapKitGoogleStyler

// Implementation of the homepage of a logged in user
class HomeViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, MKMapViewDelegate {
	var locValue:CLLocationCoordinate2D!
	var locManager: CLLocationManager!
	var mapView:  MKMapView!
	var counter = 0
	var timer = Timer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(logOutUser))
		
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
		setupMapView()
		
		
		scheduledTimerWithTimeInterval()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		mapView.removeFromSuperview()
	}
	
	override func viewDidAppear(_ animated: Bool) {
	}
	
	
	
	func scheduledTimerWithTimeInterval(){
		// Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.spitLocation), userInfo: nil, repeats: true)
	}
	
	func spitLocation(){
		let currentPinIsPointingTo = getCoordinatesPinIsPointingTo()
		//print(currentPinIsPointingTo.latitude, currentPinIsPointingTo.longitude)
	}
	

/****************************************************************************************************/
	
	/* Functions and Behaviors  **********************************/

	func logOutUser(){ // Logging out a user, dismissing HomePage
		sleep(1)
		do{
			try FIRAuth.auth()?.signOut()
		} catch let logoutErr {
			print(logoutErr)
			return
		}
		self.dismiss(animated: false, completion: {
			
		})
		
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
	
		if annotation.isKind(of: MKUserLocation.self){
			let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
			return annotationView
		}
		let identifier = "MyCustomAnnotation"
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
		
		if (annotationView != nil){
			annotationView?.annotation = annotation
		}else{
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			annotationView?.canShowCallout = true
			let moreInfoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
			moreInfoButton.backgroundColor = .blue
			moreInfoButton.titleLabel?.text = "more info"
			moreInfoButton.titleLabel?.tintColor = .black
			moreInfoButton.titleLabel?.font = UIFont(name: "Arial", size: 4)
			
			annotationView?.rightCalloutAccessoryView = moreInfoButton
		}
		let annotationImage = UIImage(named: "oilwell.png")
		let newImageSize = CGSize(width: 60, height: 60) //Make sure it's in proportion to above image
		let newImage = annotationImage?.resize(newSize: newImageSize)
		annotationView?.image = newImage
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if (view.annotation?.isKind(of: MKUserLocation.self))!{
			// Go to home page
			print("Going to home page")
		}
		else{
			print("Pretend this is more info *Hides under covers*")
		}
		
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

	
	// Create a pin-post
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
	
	// get coordinates pin is pointing to
	func getCoordinatesPinIsPointingTo()->CLLocationCoordinate2D{
	 	let center = CGPoint(x: centerPin.frame.origin.x + (centerPin.frame.width / 2), y: centerPin.frame.origin.y + centerPin.frame.height)
		let coordinates = mapView.convert(center, toCoordinateFrom: mapView)
		return coordinates
	}
	
	
	//  Functions working together to extract current location and center mapView
	func centerMapOnUserButtonClicked() {
		let myLocation = locManager.location
		if myLocation != nil {
			centerMapOnLocation(location: myLocation!)
		}
	}
	
	func centerMapOnLocation(location: CLLocation) {
		print("Location", location.coordinate.latitude, location.coordinate.longitude)
		let regionRadius: CLLocationDistance = 1000
		let coordinatesRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
		mapView.setRegion(coordinatesRegion, animated: true)
		view.addSubview(mapView)
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let userLocation = locations.last
		centerMapOnLocation(location: userLocation!)
		locManager.stopUpdatingLocation()
		
	}
	
	
	// Set the status bar style to complement night-mode.
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	func createGeoTagSelected(){
		
		menuBar.removeFromSuperview()
		
		view.addSubview(writeGeoTagView)
		writeGeoTagView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -45).isActive = true
		writeGeoTagView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		writeGeoTagView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		writeGeoTagView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		
		
		
		UIView.animate(withDuration: 0.1) {
			self.writeGeoTagView.topAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
			self.writeGeoTagView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
			self.writeGeoTagView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
			self.writeGeoTagView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
			
			self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
			self.mapView.bottomAnchor.constraint(equalTo: self.writeGeoTagView.topAnchor).isActive = true
			self.mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
			self.mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
			
			self.writeGeoTagView.addSubview(self.minimizeGeoTagButton)
			self.minimizeGeoTagButton.topAnchor.constraint(equalTo: self.writeGeoTagView.topAnchor).isActive = true
			self.minimizeGeoTagButton.centerXAnchor.constraint(equalTo: self.writeGeoTagView.centerXAnchor).isActive = true
			self.minimizeGeoTagButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
			self.minimizeGeoTagButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
			
			self.writeGeoTagView.addSubview(self.contentField)
			self.contentField.centerYAnchor.constraint(equalTo: self.writeGeoTagView.centerYAnchor).isActive = true
			self.contentField.centerXAnchor.constraint(equalTo: self.writeGeoTagView.centerXAnchor).isActive = true
			self.contentField.widthAnchor.constraint(equalTo: self.writeGeoTagView.widthAnchor, constant: -30).isActive = true
			self.contentField.heightAnchor.constraint(equalTo: self.writeGeoTagView.widthAnchor, constant: -80).isActive = true
			
			self.writeGeoTagView.addSubview(self.submitButton)
			self.submitButton.bottomAnchor.constraint(equalTo: self.writeGeoTagView.bottomAnchor, constant: -30).isActive = true
			self.submitButton.centerXAnchor.constraint(equalTo: self.writeGeoTagView.centerXAnchor).isActive = true
			self.submitButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
			self.submitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
		}
		
	}
	
	func minimizeGeoTagButtonSelected(){
	
		UIView.animate(withDuration: 0.1) {
			self.setupMapView()
			self.minimizeGeoTagButton.removeFromSuperview()
			self.writeGeoTagView.removeFromSuperview()
			self.contentField.removeFromSuperview()
		}

	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool{
		submitButtonSelected()
		return true
	}
	
	func submitButtonSelected(){
		let uid = FIRAuth.auth()?.currentUser?.uid
		let ref = FIRDatabase.database().reference().child("users").child(uid!).child("GeoPost").childByAutoId()
		
		ref.updateChildValues(["text": contentField.text!])
		createPinPost(text: contentField.text!)
		contentField.text = ""
		minimizeGeoTagButtonSelected()
	}
	
/****************************************************************************************************/

	/* Initializing different UIView Objects and Views ****/
	
	
	
	// Main View
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
	
	let centerPin: UIImageView = { // Needs to be a subview of mapView for pinLocation to work
		let image = UIImage(named: "blackpin.png")
		let imageView = UIImageView(image: image)
		imageView.layer.shadowColor = UIColor.black.cgColor
		imageView.layer.shadowOffset = CGSize(width: 3, height: 4)
		imageView.layer.shadowOpacity = 0.8
		imageView.layer.shadowRadius = 13
		
		imageView.layer.masksToBounds = false
	 	imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	
	let menuBar: UIView = {
		let bar = UIView(frame: .zero)
		bar.translatesAutoresizingMaskIntoConstraints = false
		bar.backgroundColor = UIColor(red: 210/256, green: 244/256, blue: 253/256, alpha: 1)
		
		let createGeoTagButton: UIButton = {
			let button = UIButton()
			button.translatesAutoresizingMaskIntoConstraints = false
			button.setTitle("+", for: .normal)
			button.backgroundColor = .gray
			button.titleLabel?.font =  UIFont(name: "Arial", size: 30)
			button.setTitleColor(.black, for: .normal)
			button.layer.cornerRadius = 8.0
			button.showsTouchWhenHighlighted = true
			button.addTarget(self, action: #selector(createGeoTagSelected), for: .touchUpInside)
			return button
		}()
		
		bar.addSubview(createGeoTagButton)
		createGeoTagButton.heightAnchor.constraint(equalTo: bar.heightAnchor, constant: -5).isActive = true
		createGeoTagButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor).isActive = true
		createGeoTagButton.centerXAnchor.constraint(equalTo: bar.centerXAnchor).isActive = true
		createGeoTagButton.widthAnchor.constraint(equalTo: bar.heightAnchor).isActive = true
		return bar
	}()
	
	// Write Geo Tag View
	let writeGeoTagView: UIView = {
		let view = UIView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor(red: 210/256, green: 244/256, blue: 253/256, alpha: 1)
		return view
	}()
	
	let minimizeGeoTagButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("-", for: .normal)
		button.backgroundColor = .gray
		button.titleLabel?.font =  UIFont(name: "Arial", size: 30)
		button.setTitleColor(.black, for: .normal)
		button.showsTouchWhenHighlighted = true
		button.addTarget(self, action: #selector(minimizeGeoTagButtonSelected), for: .touchUpInside)
		return button
	}()
	
	lazy var contentField: UITextField = {
		let field = UITextField()
		field.placeholder = "Content"
		field.backgroundColor = UIColor.gray
		field.beginFloatingCursor(at: CGPoint(x: field.frame.origin.x + 10, y:  field.frame.origin.y + 10))
		field.translatesAutoresizingMaskIntoConstraints = false
		field.delegate = self
		return field
	}()
	
	let submitButton: UIButton = {
		let button = UIButton()
		button.setTitle("Submit", for: .normal)
		button.backgroundColor = UIColor.darkText
		button.addTarget(self, action: #selector(submitButtonSelected), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	
/****************************************************************************************************/

	/* Setting up the different views *********************/
	func setupMapView(){
		view.addSubview(mapView)
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		
		mapView.addSubview(centerToLocationButton)
		centerToLocationButton.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
		centerToLocationButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
		centerToLocationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
		centerToLocationButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -10).isActive = true
		
		mapView.addSubview(centerPin) // Needs to be a subview of mapView for pinLocation to work
		centerPin.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
		centerPin.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
		centerPin.widthAnchor.constraint(equalToConstant: 23).isActive = true
		centerPin.heightAnchor.constraint(equalToConstant: 34.5).isActive = true
		
		configureTileOverlay()

		setupViews()
	}
	
	func setupViews(){
		mapView.addSubview(menuBar)
		menuBar.heightAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 1/16).isActive = true
		menuBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		menuBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		menuBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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





extension UIImage {

	// resize a UIImage
	func resize(newSize : CGSize) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
		let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
}






