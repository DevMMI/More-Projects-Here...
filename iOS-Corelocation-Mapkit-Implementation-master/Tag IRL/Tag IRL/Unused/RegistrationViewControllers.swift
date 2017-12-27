//
//  LoginViewController.swift
//  Village
//
//  Created by Mohamed Bande on 08/27/17.
//  Copyright © 2017 Village. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate{
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Login"
		view.backgroundColor = UIColor(red: 210/256, green: 244/256, blue: 253/256, alpha: 1)
		let item = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(popView))
		navigationItem.leftBarButtonItem = item
		setupViews()
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func popView(){
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
	
	
	let inputsContainer: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		return view
	}()
	
	let usernameField: UITextField = {
		let field = UITextField()
		field.placeholder = "Username"
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	lazy var passwordField: UITextField = {
		let field = UITextField()
		field.placeholder = "Password"
		field.isSecureTextEntry = true
		field.delegate = self
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	let nameSeparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let signInButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Sign In", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.layer.cornerRadius = 5
		button.layer.masksToBounds = true
		button.backgroundColor = UIColor(red: 250/255, green: 46/255, blue: 46/255, alpha: 1)
		button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
		return button
	}()
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		signIn()
		return true
	}
	
	func signIn(){
		
		guard let username = usernameField.text, let password = passwordField.text else{
			print("form is not valid")
			return
		}
		FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: {(user: FIRUser?, error) in
			
			if error != nil {
				print(error!)
				return
			}
			
			//successfully signed in user
			self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
			
		})
	}
	
	
	func setupViews(){
		view.addSubview(inputsContainer)
		view.addSubview(usernameField)
		view.addSubview(passwordField)
		view.addSubview(nameSeparatorLine)
		view.addSubview(signInButton)
		
		inputsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inputsContainer.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
		inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
		inputsContainer.heightAnchor.constraint(equalToConstant: 170).isActive = true
		
		usernameField.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 10).isActive = true
		usernameField.topAnchor.constraint(equalTo: inputsContainer.topAnchor).isActive = true
		usernameField.rightAnchor.constraint(equalTo: inputsContainer.rightAnchor).isActive = true
		usernameField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/2).isActive = true
		
		nameSeparatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nameSeparatorLine.topAnchor.constraint(equalTo: usernameField.bottomAnchor).isActive = true
		nameSeparatorLine.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		nameSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		passwordField.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 10).isActive = true
		passwordField.topAnchor.constraint(equalTo: nameSeparatorLine.bottomAnchor).isActive = true
		passwordField.rightAnchor.constraint(equalTo: inputsContainer.rightAnchor).isActive = true
		passwordField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/2).isActive = true
		
		signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		signInButton.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor).isActive = true
		signInButton.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
	}
	
	
}


import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(red: 210/256, green: 244/256, blue: 253/256, alpha: 1)
		navigationItem.title = "Sign Up"
		let item = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(popView))
		navigationItem.leftBarButtonItem = item
		setupViews()
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func popView(){
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
	
	
	let inputsContainer: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		return view
	}()
	
	let nameField: UITextField = {
		let field = UITextField()
		field.placeholder = "Username"
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	let emailField: UITextField = {
		let field = UITextField()
		field.placeholder = "Email"
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	let passwordField: UITextField = {
		let field = UITextField()
		field.placeholder = "Password"
		field.isSecureTextEntry = true
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	lazy var confirmPasswordField: UITextField = {
		let field = UITextField()
		field.placeholder = "Confirm Password"
		field.isSecureTextEntry = true
		field.delegate = self
		field.translatesAutoresizingMaskIntoConstraints = false
		return field
	}()
	
	let nameSeparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let emailSeparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let passwordSeparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		registerUser()
		return true
	}
	
	
	let registerButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Register", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.layer.cornerRadius = 5
		button.layer.masksToBounds = true
		button.backgroundColor = UIColor(red: 250/255, green: 46/255, blue: 46/255, alpha: 1)
		button.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
		return button
	}()
	
	func registerUser(){
		guard let password = passwordField.text, let confirmPass = confirmPasswordField.text else{
			formNotFilledOut()
			return
		}
		if password != confirmPass{
			formNotFilledOut()
			return
		}
		
		guard let email = emailField.text, let name = nameField.text else{
			print("form is not valid")
			return
		}
		FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
			
			if error != nil {
				print(error as Any)
				return
			}
			
			guard let uid = user?.uid else{
				print("User instance not created")
				return
			}
			//successfully authenticated user
			let ref = FIRDatabase.database().reference(fromURL: "https://tag-irl-105db.firebaseio.com/")
			let usersRef = ref.child("users").child(uid)
			let values = ["user": name, "email": email, "password": password]
			usersRef.updateChildValues(values, withCompletionBlock: {(err, ref) in
				if( err != nil){
					print(err as Any)
					return
				}
				
				self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
				
			})
			
		})
	}
	
	func formNotFilledOut(){
		print("Form is not correct")
	}
	
	
	func setupViews(){
		view.addSubview(inputsContainer)
		view.addSubview(registerButton)
		
		view.addSubview(nameField)
		view.addSubview(emailField)
		view.addSubview(passwordField)
		view.addSubview(confirmPasswordField)
		
		view.addSubview(nameSeparatorLine)
		view.addSubview(emailSeparatorLine)
		view.addSubview(passwordSeparatorLine)
		
		inputsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inputsContainer.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
		inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
		inputsContainer.heightAnchor.constraint(equalToConstant: 150).isActive = true
		
		registerButton.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor).isActive = true
		registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
		registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		nameField.topAnchor.constraint(equalTo: inputsContainer.topAnchor).isActive = true
		nameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nameField.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		nameField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/4).isActive = true
		
		nameSeparatorLine.topAnchor.constraint(equalTo: nameField.bottomAnchor).isActive = true
		nameSeparatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nameSeparatorLine.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		nameSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		emailField.topAnchor.constraint(equalTo: nameSeparatorLine.bottomAnchor).isActive = true
		emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		emailField.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		emailField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/4).isActive = true
		
		emailSeparatorLine.topAnchor.constraint(equalTo: emailField.bottomAnchor).isActive = true
		emailSeparatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		emailSeparatorLine.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		emailSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		passwordField.topAnchor.constraint(equalTo: emailSeparatorLine.bottomAnchor).isActive = true
		passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		passwordField.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		passwordField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/4).isActive = true
		
		passwordSeparatorLine.topAnchor.constraint(equalTo: passwordField.bottomAnchor).isActive = true
		passwordSeparatorLine.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		passwordSeparatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		passwordSeparatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		confirmPasswordField.topAnchor.constraint(equalTo: passwordSeparatorLine.bottomAnchor).isActive = true
		confirmPasswordField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		confirmPasswordField.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
		confirmPasswordField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/4).isActive = true
	}
	
	
	
	
}

struct AppUtility {
	
	static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
		
		if let delegate = UIApplication.shared.delegate as? AppDelegate {
			delegate.orientationLock = orientation
		}
	}
	
	/// OPTIONAL Added method to adjust lock and rotate to the desired orientation
	static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
		
		self.lockOrientation(orientation)
		
		UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
	}
	
}

