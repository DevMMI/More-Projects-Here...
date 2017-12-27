//
//  ViewController.swift
//  Tag VR
//
//  Created by Mohamed Bande on 9/19/17.
//  Copyright © 2017 Real Life Games. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapKit

@available(iOS 11.0, *)
class ARViewController: UIViewController, ARSCNViewDelegate, SceneLocationViewDelegate {
	
	var sceneView = ARSCNView()
	let sceneLocationView = SceneLocationView()
	var infoLabel = UILabel()
	var updateInfoLabelTimer: Timer?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sceneLocationView.locationDelegate = self
		
		infoLabel.font = UIFont.systemFont(ofSize: 10)
		infoLabel.textAlignment = .left
		infoLabel.textColor = UIColor.white
		infoLabel.numberOfLines = 0
		sceneLocationView.addSubview(infoLabel)
		
		updateInfoLabelTimer = Timer.scheduledTimer(
			timeInterval: 0.1,
			target: self,
			selector: #selector(ARViewController.updateInfoLabel),
			userInfo: nil,
			repeats: true)
		
		
		sceneLocationView.showAxesNode = true
		sceneLocationView.locationDelegate = self
		
		/*
		// Set the view's delegate
		sceneView.delegate = self
		view.addSubview(sceneView)
		sceneView.frame = view.frame
		
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		*/
		// Create a new scene
		//let scene = SCNScene(named: "arts.scnassets/ship.scn")!
		
		// Set the scene to the view
		//sceneView.scene = scene
		
		
		let pinCoordinate = CLLocationCoordinate2D(latitude: 44.997932, longitude: -93.246287)
		let pinLocation = CLLocation(latitude: 236, longitude: pinCoordinate.longitude)
		let pinImage = UIImage(named: "pin")!
		
		let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
		
		//sceneLocationView.addLocationNodeForCurrentPosition(locationNode: pinLocationNode)
		sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
		
		view.addSubview(sceneLocationView)
		
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Create a session configuration
		
	  //let configuration = ARWorldTrackingConfiguration()
		
		// Run the view's session
		//sceneView.session.run(configuration)
		sceneLocationView.run()
		
		//addObject()
	}
	
	func addObject(){
		let myObject = ARObject()
		myObject.loadModel()
		myObject.position = SCNVector3(0, -0.3, -0.9)
		sceneView.scene.rootNode.addChildNode(myObject)
		
		let column = Column()
		column.loadModel()
	   column.position = SCNVector3(0, -0.3, -4.8)
		sceneView.scene.rootNode.addChildNode(column)
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's session
		sceneLocationView.pause()
		//sceneView.session.pause()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		sceneLocationView.frame = CGRect(
			x: 0,
			y: 0,
			width: self.view.frame.size.width,
			height: self.view.frame.size.height)
		
		infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
		
		
		infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
		
		
	}
	/*
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
		guard let hitFeature = results.last else { return }
		let hitTransform = SCNMatrix4FromMat4(hitFeature.worldTransform) // <- if higher than beta 1, use just this -> hitFeature.worldTransform
		let hitPosition = SCNVector3Make(hitTransform.m41,
		                                 hitTransform.m42,
		                                 hitTransform.m43)
		createBall(hitPosition: hitPosition)
	}
	func createBall(hitPosition : SCNVector3) {
		let newBall = SCNSphere(radius: 0.01)
		let newBallNode = SCNNode(geometry: newBall)
		newBallNode.position = hitPosition
		self.sceneView.scene.rootNode.addChildNode(newBallNode)
	}
	*/
	// MARK: - ARSCNViewDelegate
	
	/*
	// Override to create and configure nodes for anchors added to the view's session.
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
	let node = SCNNode()
	
	return node
	}
	*/
	
	@objc func updateInfoLabel() {
		if let position = sceneLocationView.currentScenePosition() {
			infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
		}
		
		if let eulerAngles = sceneLocationView.currentEulerAngles() {
			infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
		}
		
		if let heading = sceneLocationView.locationManager.heading,
			let accuracy = sceneLocationView.locationManager.headingAccuracy {
			infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
		}
		
		let date = Date()
		let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
		
		if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
			infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
		}
	}
	
	func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
		
	}
	
	func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
		
	}
	
	func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
		
	}
	
	func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
		
	}
	
	func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
		
	}
	

}

class ARObject: SCNNode {
	func loadModel(){
		guard let virtualObjectScene = SCNScene(named: "arts.scnassets/ship.scn") else{ return }
		
		let wrapperNode = SCNNode()
		
		for child in virtualObjectScene.rootNode.childNodes{
			wrapperNode.addChildNode(child)
		}
		
		self.addChildNode(wrapperNode)
	}
}

class Column: SCNNode {
	func loadModel(){
		guard let virtualObjectScene = SCNScene(named: "arts.scnassets/column.scn") else{ return }
		
		let wrapperNode = SCNNode()
		
		for child in virtualObjectScene.rootNode.childNodes{
			wrapperNode.addChildNode(child)
		}
		
		self.addChildNode(wrapperNode)
	}
}

extension DispatchQueue {
	func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
		self.asyncAfter(
			deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
	}
}

extension UIView {
	func recursiveSubviews() -> [UIView] {
		var recursiveSubviews = self.subviews
		
		for subview in subviews {
			recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
		}
		
		return recursiveSubviews
	}
}



