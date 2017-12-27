//
//  CenterViewController.swift
//  Tag IRL
//
//  Created by Mohamed Bande on 9/3/17.
//  Copyright © 2017 Real Life Games. All rights reserved.
// The launcher-logged in view controller

import UIKit
import Firebase

class LaunchViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(logOutUser))
		navigationItem.title = "Home"
		navigationItem.backBarButtonItem?.title = "Back"
		
		view.backgroundColor = UIColor(red: 210/256, green: 244/256, blue: 253/256, alpha: 1)
		view.layer.borderWidth = 1
		setupViews()
	}
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Name"
		label.backgroundColor = UIColor.clear
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.textColor = .black
		label.adjustsFontSizeToFitWidth = true
		label.font = UIFont(name: "AppleSDGothicNeo-Light", size: 20)
		return label
	}()
	
	let profileImageView: UIView = {
		let view = UIView()
		view.backgroundColor = .gray
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let profileImageButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(profileImageButtonPressed), for: .touchUpInside)
		return button
	}()
	
	func profileImageButtonPressed(){
		print("profile image button pressed")
	}
	
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
	
	let createAMatchButton: UIButton = {
		let button = UIButton()
		button.setTitle("Create A Match", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.layer.cornerRadius = 3
		button.backgroundColor = UIColor(red: 83/256, green: 170/256, blue: 246/256, alpha: 1)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(createAMatch), for: .touchUpInside)
		return button
	}()
	
	let joinAMatchButton: UIButton = {
		let button = UIButton()
		button.setTitle("Join A Match", for: .normal)
		button.layer.cornerRadius = 3
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = UIColor(red: 83/256, green: 170/256, blue: 246/256, alpha: 1)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(joinAMatch), for: .touchUpInside)
		return button
	}()
	
	
	func createAMatch(){
		print("Creating a match")
		let createAMatch = CreateMatchViewController()
		let navController = UINavigationController(rootViewController: createAMatch)
		UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(navController, animated: true, completion: nil)
	}
	
	func joinAMatch(){
		print("Join a match")
	}
	
	
	func setupViews(){

		view.addSubview(titleLabel)
		
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 20).isActive = true
		titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/5).isActive = true
		titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
	
		view.addSubview(createAMatchButton)
		createAMatchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		createAMatchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30).isActive = true
		createAMatchButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
		createAMatchButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
		
		view.addSubview(joinAMatchButton)
		joinAMatchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		joinAMatchButton.topAnchor.constraint(equalTo: createAMatchButton.bottomAnchor, constant: 70).isActive = true
		joinAMatchButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
		joinAMatchButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
		
		view.addSubview(profileImageView)
		profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
		
		profileImageView.addSubview(profileImageButton)
		profileImageButton.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
		profileImageButton.rightAnchor.constraint(equalTo: profileImageView.rightAnchor).isActive = true
		profileImageButton.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
		profileImageButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
		
		
		
		
	}
}
