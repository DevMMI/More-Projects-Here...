//
//  SetupTagViewController.swift
//  Tag IRL
//
//  Created by Mohamed Bande on 8/31/17.
//  Copyright © 2017 Real Life Games. All rights reserved.
//

import UIKit
import Firebase
import CoreData


class CreateMatchViewController: UIViewController, UITextFieldDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
		  view.backgroundColor = .white
		  let backImage = UIImage(named: "leftarrow.png")
		  let resizedImage = imageWithImage(image: backImage!, scaledToSize: CGSize(width: (20 * (468/720)), height: 20.0))
		  let backButton: UIBarButtonItem = UIBarButtonItem(image: resizedImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonSelected))
		  navigationItem.leftBarButtonItem = backButton
		  setupViews()
		
		groupNameField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		// testing if group is cached, transition to Tag View Controller
	}
	
	@objc func backButtonSelected(){
		self.dismiss(animated: true, completion: nil)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let beginning: UITextPosition = textField.beginningOfDocument
		textField.selectedTextRange = textField.textRange(from: beginning, to: beginning)
	}
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .black
		label.textAlignment = .center
		label.text = "What's your group name?"
		label.font = UIFont(name: "Arial", size: 25)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	let fieldLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .gray
		label.textAlignment = .left
		label.text = "Group Name"
		label.font = UIFont(name: "Arial-BoldMT", size: 14)
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	
	lazy var groupNameField: UITextField = {
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
	
	
	let createButton: UIButton = {
		let button = UIButton()
		button.setTitle("Create", for: .normal)
		button.backgroundColor = .red
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8
		button.addTarget(self, action: #selector(createButtonSelected), for: .touchUpInside)
		return button
	}()
	
	let signInView = SignInView()
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		createButtonSelected()
		return true
	}
	
	@objc func createButtonSelected(){
		// instantiate sign in view and pass it the groupid
		let signInView = SignInView()
		signInView.groupName = groupNameField.text
		let navController = UINavigationController(rootViewController: signInView)
		//UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(navController, animated: true, completion: nil)
		
		let transition = CATransition()
		transition.duration = 0.3
		transition.type = kCATransitionPush
		transition.subtype = kCATransitionFromRight
		view.window!.layer.add(transition, forKey: kCATransition)
		self.present(navController, animated: false, completion: nil)
		
	}
	
	func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
		let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
	
	func setupViews(){
		view.addSubview(titleLabel)
		titleLabel.centerYAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 35).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
		titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
		
		view.addSubview(groupNameField)
		groupNameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 45).isActive = true
		groupNameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		groupNameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/10).isActive = true
		groupNameField.heightAnchor.constraint(equalToConstant: 25).isActive = true

		view.addSubview(fieldLabel)
		fieldLabel.bottomAnchor.constraint(equalTo: groupNameField.topAnchor, constant: -8).isActive = true
		fieldLabel.leftAnchor.constraint(equalTo: groupNameField.leftAnchor).isActive = true
		fieldLabel.widthAnchor.constraint(equalTo: groupNameField.widthAnchor, multiplier: 2/6).isActive = true
		fieldLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		view.addSubview(separatorLine)
		separatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		separatorLine.topAnchor.constraint(equalTo: groupNameField.bottomAnchor).isActive = true
		separatorLine.widthAnchor.constraint(equalTo: groupNameField.widthAnchor).isActive = true
		separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		view.addSubview(createButton)
		createButton.topAnchor.constraint(equalTo: groupNameField.bottomAnchor, constant: 30).isActive = true
		createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		createButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
		createButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
		
	}
	
}


class SignInView: UIViewController, UITextFieldDelegate{
	var groupName: String?
	
	override func viewDidLoad() {
		view.backgroundColor = .white
		//self.managedObjectContext = self.managedObjectContext;
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
		button.setTitle("Create", for: .normal)
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
				
				// Create a group in database
				let groupRef = FIRDatabase.database().reference().child("groups").childByAutoId()
				groupRef.updateChildValues(["name": groupName])
				let groupID = groupRef.childByAutoId().key
				groupRef.updateChildValues(["id": groupID])
				
				
				// save group in coredata
			  let groupEntity = NSEntityDescription.entity(forEntityName: "Group", in: managedContext)!
			  let group = NSManagedObject(entity: groupEntity, insertInto: managedContext)
			  group.setValue(groupID, forKeyPath: "id")
				
				
				// add user to group in database
			  let usersRef = groupRef.child("users").childByAutoId()
			  usersRef.updateChildValues(["username": username])
				
		     let profileEntity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)!
		     let profileGroup = NSManagedObject(entity: profileEntity, insertInto: managedContext)
		     profileGroup.setValue(usersRef.key, forKey: "userchildkey")
		     try managedContext.save()
					
				
				self.dismiss(animated: true, completion: {
					let tagController = TagViewController()
					tagController.groupID = groupID
					tagController.myGroupRef = groupRef
					let navController = UINavigationController(rootViewController: tagController)
					UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(navController, animated: true, completion: nil)
					
					
					//self.present(navController, animated: false, completion: nil)
				})
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
		usernameField.heightAnchor.constraint(equalToConstant: 25).isActive = true
		
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
