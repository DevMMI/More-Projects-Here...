//
//  ViewController.swift
//  Village
//
//  Created by Mohamed Bande on 08/27/17.
//  Copyright © 2017 Village. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreData


class MyHomeViewController: UIViewController {
	var GroupID: String?
	var name: String?
	var username: String?
	var userchildkey: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
			AppUtility.lockOrientation(.portrait)
			if #available(iOS 11.0, *) {
				let ARController = ARViewController()
				let navController = UINavigationController(rootViewController: ARController)
				self.present(navController, animated: false, completion: nil)
			} else {
				// Fallback on earlier versions
			}
		
		
		
		/*
		let testing = true
		if( !testing && userIsCached()){
			// Call tag view controller
			let tagController = TagViewController()
			tagController.groupID = GroupID
			tagController.name = name
			tagController.username = username
			tagController.userChildKey = userchildkey
			let navController = UINavigationController(rootViewController: tagController)
			//UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(navController, animated: true, completion: nil)
			
			let transition = CATransition()
			transition.duration = 0.3
			transition.type = kCATransitionPush
			transition.subtype = kCATransitionFromRight
			self.view.window!.layer.add(transition, forKey: kCATransition)
			self.present(navController, animated: false, completion: nil)
		}
		else{
			AppUtility.lockOrientation(.portrait)
			setupViews()
			navigationItem.title = "Home"
			//navigationController?.navigationBar.barTintColor = UIColor.white
			view.backgroundColor = UIColor(red: 254/256, green: 254/256, blue: 254/256, alpha: 1)
			view.layer.borderWidth = 1
			setupViews()
		}
		*/
		
	}

	let titleLabel: UILabel = {
		let label = UILabel()
		label.text = " Tag "
		label.backgroundColor = UIColor.clear
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.textColor = .black
		//label.adjustsFontSizeToFitWidth = true
		label.font = UIFont(name: "Cochin-Bold", size: 60)
		return label
	}()
	
	let subtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "Keep track of your life,\n with none of the hassle!"
		label.backgroundColor = UIColor.clear
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.textColor = .black
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		label.font = UIFont(name: "Cochin", size: 22)
		return label
	}()
	
	let separatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = .black
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let aseparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(red: 215/256, green: 215/256, blue: 216/256, alpha: 1)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let bseparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(red: 215/256, green: 215/256, blue: 216/256, alpha: 1)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let cseparatorLine: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(red: 215/256, green: 215/256, blue: 216/256, alpha: 1)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	

	
	let createAMatchButton: UIButton = {
		let button = UIButton()
		button.setTitle("Create A group", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.layer.cornerRadius = 9
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 1
		button.titleLabel?.textColor = .black
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 0, height: 0)
		button.layer.shadowRadius = 4
		button.layer.shadowOpacity = 0.35
		//button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.titleLabel?.font = UIFont(name: "Arial", size: 16)
		button.backgroundColor = UIColor(red: 200/256, green: 200/256, blue: 200/256, alpha: 1)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(createAMatch), for: .touchUpInside)
		return button
	}()
	
	let joinAMatchButton: UIButton = {
		let button = UIButton()
		button.setTitle("Join A group", for: .normal)
		button.layer.cornerRadius = 9
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 1
		button.titleLabel?.textColor = .black
		button.adjustsImageWhenHighlighted = true
		button.titleLabel?.font = UIFont(name: "Arial", size: 16)
		button.setTitleColor(.black, for: .normal)
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = CGSize(width: 0, height: 0)
		button.layer.shadowRadius = 4
		//button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.layer.shadowOpacity = 0.35
		button.backgroundColor = UIColor(red: 200/256, green: 200/256, blue: 200/256, alpha: 1)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(joinAMatch), for: .touchUpInside)
		return button
	}()
	
	let squareView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(red: 239/256, green: 239/256, blue: 239/256, alpha: 1)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.shadowColor = UIColor.black.cgColor
  		view.layer.shadowOffset = CGSize(width: 0, height: 0)
		view.layer.shadowRadius = 6
		view.layer.shadowOpacity = 0.3
		view.frame = .zero
		return view
	}()
	
	
	func createAMatch(){
		print("Creating a group")
		let createAMatch = CreateMatchViewController()
		let navController = UINavigationController(rootViewController: createAMatch)
		self.present(navController, animated: true, completion: nil)
	}
	
	func joinAMatch(){
		let createAMatch = JoinMatchViewController()
		let navController = UINavigationController(rootViewController: createAMatch)
		self.present(navController, animated: true, completion: nil)
	}
	
	// Check is a user is cached, pull from cache
	func userIsCached()->Bool{
	  guard let appDelegate =
		  UIApplication.shared.delegate as? AppDelegate else {
			  return false
	  }
		
	  let managedContext = appDelegate.persistentContainer.viewContext
	  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Group")
		
	  do {
		  let group = try managedContext.fetch(fetchRequest)
		GroupID = (group[0] as AnyObject).value(forKey: "id") as? String
		  print("Group!", (group[0] as AnyObject).value(forKey: "id")!)
	  } catch let error as NSError {
		  print("Could not fetch. \(error), \(error.userInfo)")
		  return false
	  }
		
	  let profileFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
		
	  do {
		  let user = try managedContext.fetch(profileFetchRequest)
	     username = (user.last as AnyObject).value(forKey: "username") as? String
		  name = (user.last as AnyObject).value(forKey: "name") as? String
		  userchildkey = (user.last as AnyObject).value(forKey: "userchildkey") as? String
		return true
	  } catch let error as NSError {
		  print("Could not fetch. \(error), \(error.userInfo)")
		  return false
	  }
		
	}
	
	
	func setupViews(){
		view.addSubview(squareView)
		squareView.addSubview(titleLabel)
		squareView.addSubview(subtitleLabel)

		
		squareView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		squareView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 20).isActive = true
		squareView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
		squareView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/10).isActive = true

		
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: squareView.centerYAnchor, constant: -185).isActive = true
		titleLabel.widthAnchor.constraint(equalTo: squareView.widthAnchor, multiplier: 4/6).isActive = true
		titleLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
		
		subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 70).isActive = true
		subtitleLabel.centerXAnchor.constraint(equalTo: squareView.centerXAnchor).isActive = true
		subtitleLabel.widthAnchor.constraint(equalTo: squareView.widthAnchor, multiplier: 9/10).isActive = true
		subtitleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
		
		
		squareView.addSubview(separatorLine)
		separatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true
		separatorLine.widthAnchor.constraint(equalTo: squareView.widthAnchor, constant: -50 ).isActive = true
		separatorLine.heightAnchor.constraint(equalToConstant: 3).isActive = true
		
		squareView.addSubview(aseparatorLine)
		aseparatorLine.leftAnchor.constraint(equalTo: squareView.leftAnchor).isActive = true
		aseparatorLine.topAnchor.constraint(equalTo: squareView.topAnchor).isActive = true
		aseparatorLine.bottomAnchor.constraint(equalTo: separatorLine.topAnchor).isActive = true
		aseparatorLine.widthAnchor.constraint(equalToConstant: 8).isActive = true
		
		squareView.addSubview(bseparatorLine)
		bseparatorLine.rightAnchor.constraint(equalTo: squareView.rightAnchor).isActive = true
		bseparatorLine.topAnchor.constraint(equalTo: squareView.topAnchor).isActive = true
		bseparatorLine.bottomAnchor.constraint(equalTo: separatorLine.topAnchor).isActive = true
		bseparatorLine.widthAnchor.constraint(equalToConstant: 8).isActive = true
		
		squareView.addSubview(cseparatorLine)
		cseparatorLine.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		cseparatorLine.topAnchor.constraint(equalTo: squareView.topAnchor).isActive = true
		cseparatorLine.widthAnchor.constraint(equalTo: squareView.widthAnchor, constant: -50 ).isActive = true
		cseparatorLine.heightAnchor.constraint(equalToConstant: 8).isActive = true
		
		squareView.addSubview(createAMatchButton)
		createAMatchButton.centerXAnchor.constraint(equalTo: squareView.centerXAnchor).isActive = true
		createAMatchButton.centerYAnchor.constraint(equalTo: squareView.centerYAnchor, constant: 30).isActive = true
		createAMatchButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
		createAMatchButton.widthAnchor.constraint(equalTo: squareView.widthAnchor, multiplier: 1/2).isActive = true
		
		squareView.addSubview(joinAMatchButton)
		joinAMatchButton.centerXAnchor.constraint(equalTo: squareView.centerXAnchor).isActive = true
		joinAMatchButton.topAnchor.constraint(equalTo: createAMatchButton.bottomAnchor, constant: 70).isActive = true
		joinAMatchButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
		joinAMatchButton.widthAnchor.constraint(equalTo: squareView.widthAnchor, multiplier: 1/2).isActive = true
		
		
	}
	
}


