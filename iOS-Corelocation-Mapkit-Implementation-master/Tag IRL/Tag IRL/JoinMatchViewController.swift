//
//  JoinMatchViewController.swift
//  Tag IRL
//
//  Created by Mohamed Bande on 9/8/17.
//  Copyright © 2017 Real Life Games. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreData

class JoinMatchViewController: UIViewController, UITextFieldDelegate {
	var groupID: String?
	var groupName: String?
	var groupRef: FIRDatabaseReference?{
		didSet {
			joinedGroup()
		}
	}
	

    override func viewDidLoad() {
        super.viewDidLoad()
		  view.backgroundColor = .white
		  
		let backImage = UIImage(named: "leftarrow.png")
		let resizedImage = imageWithImage(image: backImage!, scaledToSize: CGSize(width: (20 * (468/720)), height: 20.0))
		let backButton: UIBarButtonItem = UIBarButtonItem(image: resizedImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonSelected))
		navigationItem.leftBarButtonItem = backButton
		
		setupViews()
		searchField.becomeFirstResponder()
		
	 }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		// testing if group is cached, transition to Tag View Controller
	}
	
	func joinedGroup(){
		// instantiate sign in view and pass it the groupid
		let signInView = JoinSignInView()
		signInView.groupID = groupID
		signInView.groupName = groupName
		signInView.groupRef = groupRef
		let navController = UINavigationController(rootViewController: signInView)
		//UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(navController, animated: true, completion: nil)
		

		self.present(navController, animated: false, completion: nil)
	}
	
	 func checkIfUserCached(){
		guard let appDelegate =
		 UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		
		let managedContext = appDelegate.persistentContainer.viewContext
		let profileFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
		
		do {
		 let user = try managedContext.fetch(profileFetchRequest)
			print("User!", (user.last as AnyObject).value(forKey: "name")!)
	 } catch let error as NSError {
		print("Could not fetch. \(error), \(error.userInfo)")
		}
	}
	
	@objc func backButtonSelected(){
		self.dismiss(animated: true, completion: nil)
	}
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.textAlignment = .center
		label.text = "What is the group name?"
		label.font = UIFont(name: "Arial", size: 25)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	lazy var searchField: UITextField = {
		let field = UITextField()
		field.placeholder = ""
		field.delegate = self
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	let usernameSeparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchTapped()
		return true
	}
	
	
	let searchButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Search", for: .normal)
		button.backgroundColor = .red
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
		return button
	}()
	
	// Collecting Matches
	
	var matchGroups:[NewGroup] = []
	let operation = BlockOperation()
	
	@objc func searchTapped(){
		operation.start()
		collectMatches()
	}
	
	func collectMatches() {
		var handle: UInt = 0
		let ref = FIRDatabase.database().reference().child("groups")
		handle = ref.observe(.childAdded, with: { (snapshot) in
			if let dictionary = snapshot.value as? [String: AnyObject]{
				let myGroup = NewGroup()
				
					try? myGroup.setValuesForKeys(dictionary)
				if let searchName = self.searchField.text{
					if (searchName == myGroup.name){
						self.groupName = myGroup.name
						self.groupID = myGroup.id
						self.groupRef = ref.child(snapshot.key)
						ref.removeObserver(withHandle: handle)
						print("Group", myGroup.name, "found")
						return
					}
				} // end if
				print("not found", myGroup.name )
			}
			
 		})
		
  }
		
	
	
	
	
	
	//
	func setupViews(){
		view.addSubview(titleLabel)
		titleLabel.centerYAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 35).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
		titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		view.addSubview(searchField)
		searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45).isActive = true
		searchField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		searchField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 8/10).isActive = true
		searchField.heightAnchor.constraint(equalToConstant: 25).isActive = true
		
		
		view.addSubview(usernameSeparatorLine)
		usernameSeparatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		usernameSeparatorLine.topAnchor.constraint(equalTo: searchField.bottomAnchor).isActive = true
		usernameSeparatorLine.widthAnchor.constraint(equalTo: searchField.widthAnchor).isActive = true
		usernameSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		
		view.addSubview(searchButton)
		searchButton.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 30).isActive = true
		searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		searchButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
		searchButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
	}
	
	func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
		let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
	
}

class NewGroup: NSObject {
	var id: String?
	var name: String?
	var users: AnyObject?
}

class JoinSignInView: UIViewController, UITextFieldDelegate{
	var groupID: String?
	var groupName: String?
	var groupRef: FIRDatabaseReference?
	
	override func viewDidLoad() {
		view.backgroundColor = .white
		nameField.becomeFirstResponder()
		let backImage = UIImage(named: "leftarrow.png")
		let resizedImage = imageWithImage(image: backImage!, scaledToSize: CGSize(width: (20 * (468/720)), height: 20.0))
		let backButton: UIBarButtonItem = UIBarButtonItem(image: resizedImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonSelected))
		navigationItem.leftBarButtonItem = backButton
		setupViews()
		
	}
	
	@objc func backButtonSelected(){
		let transition = CATransition()
		transition.duration = 0.3
		transition.type = kCATransitionPush
		transition.subtype = kCATransitionFromLeft
		view.window!.layer.add(transition, forKey: kCATransition)
		self.dismiss(animated: false, completion: nil)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let beginning: UITextPosition = textField.beginningOfDocument
		textField.selectedTextRange = textField.textRange(from: beginning, to: beginning)
	}
	
	internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if (textField == nameField){
			return usernameField.becomeFirstResponder()
		}
		else{
			signInButtonSelected()
			return true
		}
	}
	
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.textAlignment = .center
		label.text = "What's your name?"
		label.font = UIFont(name: "Arial", size: 25)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	let nameFieldLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .gray
		label.textAlignment = .left
		label.text = "Name"
		label.font = UIFont(name: "Arial-BoldMT", size: 14)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	
	lazy var nameField: UITextField = {
		let field = UITextField()
		field.backgroundColor = .white
		field.placeholder = ""
		field.delegate = self
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	let separatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let usernameFieldLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .gray
		label.textAlignment = .left
		label.text = "Username"
		label.font = UIFont(name: "Arial-BoldMT", size: 14)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	let usernameSeparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	lazy var usernameField: UITextField = {
		let field = UITextField()
		field.backgroundColor = .white
		field.placeholder = ""
		field.delegate = self
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	
	let signInButton: UIButton = {
		let button = UIButton()
		button.setTitle("Join", for: .normal)
		button.backgroundColor = .red
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(signInButtonSelected), for: .touchUpInside)
		return button
	}()
	
	
	@objc func signInButtonSelected(){
		// Save profile in userdata
		if let name = nameField.text, let username = usernameField.text {
			if name.isEmpty || username.isEmpty{
				return
			}
			// name is given
			guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
				return
			}
			let managedContext = appDelegate.persistentContainer.viewContext
			let entity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)
			let profile = NSManagedObject(entity: entity!, insertInto: managedContext)
			profile.setValue(name, forKeyPath: "name")
			profile.setValue(username, forKeyPath: "username")
			
			do {
				
				try managedContext.save()
				
				// save group in coredata
				if let myGroup = groupID{
					let groupEntity = NSEntityDescription.entity(forEntityName: "Group", in: managedContext)!
					let group = NSManagedObject(entity: groupEntity, insertInto: managedContext)
					group.setValue(myGroup, forKeyPath: "id")
					
					// add user to group in database
					if let groupref = groupRef {
						print("groupref = ",groupref)
						let childRef = groupref.child("users").childByAutoId()
						childRef.updateChildValues(["username": username])
						
						let profileEntity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)!
						let profileGroup = NSManagedObject(entity: profileEntity, insertInto: managedContext)
						profileGroup.setValue(childRef.key, forKey: "userchildkey")
						
						try managedContext.save()
 
					}
				}else{
					print("groupID passing error")
				}
				
				
				
			  // Call tag view controller
					let tagController = TagViewController()
					tagController.groupID = self.groupID
					tagController.myGroupRef = self.groupRef
					let navController = UINavigationController(rootViewController: tagController)
					//UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(navController, animated: true, completion: nil)
					
					let transition = CATransition()
					transition.duration = 0.3
					transition.type = kCATransitionPush
					transition.subtype = kCATransitionFromRight
					self.view.window!.layer.add(transition, forKey: kCATransition)
					self.present(navController, animated: false, completion: nil)
					
				
			}
			catch let error as NSError {
				print("Could not save. \(error), \(error.userInfo)")
			}
			
		}
		
	}
	
	func printOutContext(){
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Group")
		
		do {
			let group = try managedContext.fetch(fetchRequest)
			print("Group!", (group[0] as AnyObject).value(forKey: "id")!)
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
		
		let profileFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
		
		do {
			let user = try managedContext.fetch(profileFetchRequest)
			print("User!", (user.last as AnyObject).value(forKey: "name")!)
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
	}
	
	
	func setupViews(){
		view.addSubview(titleLabel)
		titleLabel.centerYAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 35).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
		titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		view.addSubview(nameField)
		nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45).isActive = true
		nameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/10).isActive = true
		nameField.heightAnchor.constraint(equalToConstant: 25).isActive = true
		
		view.addSubview(nameFieldLabel)
		nameFieldLabel.bottomAnchor.constraint(equalTo: nameField.topAnchor, constant: -8).isActive = true
		nameFieldLabel.leftAnchor.constraint(equalTo: nameField.leftAnchor).isActive = true
		nameFieldLabel.widthAnchor.constraint(equalTo: nameField.widthAnchor, multiplier: 2/6).isActive = true
		nameFieldLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		view.addSubview(separatorLine)
		separatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		separatorLine.topAnchor.constraint(equalTo: nameField.bottomAnchor).isActive = true
		separatorLine.widthAnchor.constraint(equalTo: nameField.widthAnchor).isActive = true
		separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		view.addSubview(usernameField)
		usernameField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 50).isActive = true
		usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/10).isActive = true
		usernameField.heightAnchor.constraint(equalToConstant: 35).isActive = true
		
		view.addSubview(usernameFieldLabel)
		usernameFieldLabel.bottomAnchor.constraint(equalTo: usernameField.topAnchor, constant: -8).isActive = true
		usernameFieldLabel.leftAnchor.constraint(equalTo: usernameField.leftAnchor).isActive = true
		usernameFieldLabel.widthAnchor.constraint(equalTo: usernameField.widthAnchor, multiplier: 2/6).isActive = true
		usernameFieldLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		view.addSubview(usernameSeparatorLine)
		usernameSeparatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		usernameSeparatorLine.topAnchor.constraint(equalTo: usernameField.bottomAnchor).isActive = true
		usernameSeparatorLine.widthAnchor.constraint(equalTo: usernameField.widthAnchor).isActive = true
		usernameSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		
		view.addSubview(signInButton)
		signInButton.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 30).isActive = true
		signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		signInButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
		signInButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
		
	}
	
	func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
		let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
}


