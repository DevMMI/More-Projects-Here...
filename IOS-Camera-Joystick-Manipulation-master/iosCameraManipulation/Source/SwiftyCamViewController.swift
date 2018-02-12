import UIKit
import Foundation
import AVFoundation
import MobileCoreServices
// MARK: View Controller Declaration

/// A UIViewController Camera View Subclass

open class SwiftyCamViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
	var move = true
	var animate = false
	var ctxData: UnsafeMutableRawPointer! // My Code
	var pixelVals:[UInt8] = []
	var capturePic = true
	var customPreviewLayer: CALayer!
	var img: UIImage!{
		didSet{
			displayImage()
		}
	}
	var zoomflag = false
	var oldZoomHeight = 0.0 // Will hold previous frame's zoom ratio
	let cameraProperties = CameraProperties()
	
	fileprivate var phoneOrientation = PhoneOrientation.Portrait
	var timer = Timer()
	public enum CameraSelection {
		case rear
		case front
	}
	/// Enumeration for video quality of the capture session. Corresponds to a AVCaptureSessionPreset
	public enum VideoQuality {
		case high
		case medium
		case low
		case resolution352x288
		case resolution640x480
		case resolution1280x720
		case resolution1920x1080
		case resolution3840x2160
		case iframe960x540
		case iframe1280x720
	}
	fileprivate enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}
	fileprivate enum PhoneOrientation{
		case Landscape
		case Portrait
	}
	public weak var cameraDelegate: SwiftyCamViewControllerDelegate?
	public var maximumVideoDuration: Double = 0.0
	public var videoQuality : VideoQuality = .high
	public var flashEnabled = false
	public var pinchToZoom = true
	public var maxZoomScale	= CGFloat.greatestFiniteMagnitude
	public var tapToFocus = true
	public var lowLightBoost = true
	public var allowBackgroundAudio = true
	public var doubleTapCameraSwitch = true
	public var swipeToZoom = true
	public var swipeToZoomInverted = false
	public var defaultCamera = CameraSelection.rear
	public var shouldUseDeviceOrientation = false
	public var allowAutoRotate = false
	public var videoGravity: SwiftyCamVideoGravity = .resizeAspect
   public var audioEnabled = true
   fileprivate(set) public var pinchGesture: UIPinchGestureRecognizer!
   fileprivate(set) public var panGesture: UIPanGestureRecognizer!
	private(set) public var isVideoRecording = false
   private(set) public var isSessionRunning = false
	private(set) public var currentCamera = CameraSelection.rear
	public let session = AVCaptureSession()
	fileprivate let sessionQueue = DispatchQueue(label: "session queue", attributes: [])
	fileprivate var zoomScale = CGFloat(1.0)
	fileprivate var beginZoomScale = CGFloat(1.0)
	fileprivate var isCameraTorchOn = false
	fileprivate var setupResult = SessionSetupResult.success
	fileprivate var backgroundRecordingID: UIBackgroundTaskIdentifier? = nil
	fileprivate var videoDeviceInput: AVCaptureDeviceInput!
	fileprivate var videoDeviceOutput: AVCaptureVideoDataOutput!
	//fileprivate var movieFileOutput: AVCaptureMovieFileOutput? //changed
	//fileprivate var photoFileOutput: AVCaptureStillImageOutput?
	fileprivate var videoDevice: AVCaptureDevice?
	fileprivate var previewLayer: PreviewView!
	fileprivate var flashView: UIView?
   fileprivate var previousPanTranslation: CGFloat = 0.0
	fileprivate var deviceOrientation: UIDeviceOrientation?
	override open var shouldAutorotate: Bool {
		return allowAutoRotate
	}

	// MARK: ViewDidLoad

	override open func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		//cameraProperties.addObserver(self, forKeyPath: "zoom", options: .new, context: nil)
		
		previewLayer = PreviewView(frame: view.frame, videoGravity: videoGravity)
		//view.addSubview(previewLayer)
		//view.sendSubview(toBack: previewLayer)
		
		previewLayer.session = session
		switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo){
		case .authorized:
			// already authorized
			break
		case .notDetermined:
			// not yet determined
			sessionQueue.suspend()
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
				if !granted {
					self.setupResult = .notAuthorized
				}
				self.sessionQueue.resume()
			})
		default:
			// already been asked. Denied access
			setupResult = .notAuthorized
		}
		
		sessionQueue.async { [unowned self] in
			self.configureSession()
			self.setupViews()
		}
		
	} // End viewDidLoad
	
	
/*	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if (keyPath == "zoom"){
			
		}
	} */
	
    /// ViewDidLayoutSubviews()
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        previewLayer.frame = self.view.bounds
        
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer?.videoPreviewLayer.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                }
            }
        }
    }
	
	
	let leftMagnitude: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = true
		label.frame = CGRect(x: 10, y: 10, width: 70, height: 20)
		label.textColor = .blue
		label.text = "0.0"
		return label
	}()
	
	let leftTheta: UILabel = {
		let label = UILabel()
		label.frame = CGRect(x: 10, y: 35, width: 70, height: 20)
		label.translatesAutoresizingMaskIntoConstraints = true
		label.text = "0.0"
		return label
	}()
	
	let rightMagnitude: UILabel = {
		let label = UILabel()
		label.frame = CGRect(x: 10, y: 60, width: 70, height: 20)
		label.translatesAutoresizingMaskIntoConstraints = true
		label.text = "0.0"
		return label
	}()
	
	let rightTheta: UILabel = {
		let label = UILabel()
		label.frame = CGRect(x: 10, y: 85, width: 70, height: 20)
		label.translatesAutoresizingMaskIntoConstraints = true
		label.text = "0.0"
		return label
	}()
	
	let zoomButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = .white
		button.titleLabel?.textColor = .black
		button.titleLabel?.text = "Zoom"
		button.addTarget(self, action: #selector(zoomTapped), for: .touchUpInside)
		return button
	}()
	
	func zoomTapped(){
		if(zoomflag){
			zoomflag = false
			return
		}
		zoomflag = true
	}
	
	func setupViews(){
		// Setup Zoom Button
		DispatchQueue.main.async {
			self.view.addSubview(self.zoomButton)
			self.zoomButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
			self.zoomButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
			self.zoomButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
			self.zoomButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
		
		/*
			Setup Joysticks
		   Create 'fixed' joystick
		*/
	   self.view.addSubview(self.leftTheta)
		self.view.addSubview(self.leftMagnitude)
	   self.view.addSubview(self.rightTheta)
	   self.view.addSubview(self.rightMagnitude)
		let rect = self.view.frame
		let size = CGSize(width: 80.0, height: 80.0)
		let joystick1Frame = CGRect(origin: CGPoint(x: 40.0,
		                                            y: (rect.height - size.height - 40.0)),
		                            size: size)
		let joystick1 = JoyStickView(frame: joystick1Frame)
		joystick1.monitor = { angle, displacement in
			self.leftTheta.text = "\(angle)"
			self.leftMagnitude.text = "\(displacement)"
			
			self.cameraProperties.updateHeading(heading: Double(angle))
		}
		
		self.view.addSubview(joystick1)
		
		joystick1.movable = false
		joystick1.alpha = 1.0
		joystick1.baseAlpha = 0.5 // let the background bleed thru the base
		joystick1.handleTintColor = UIColor.green // Colorize the handle
		
		let joystick2Frame = CGRect(origin: CGPoint(x: (rect.width - size.width - 40.0),
		                                            y: (rect.height - size.height - 40.0)),
		                            size: size)
		let joystick2 = JoyStickView(frame: joystick2Frame)
		joystick2.monitor = { angle, displacement in
			self.rightTheta.text = "\(angle)"
			self.rightMagnitude.text = "\(displacement)"
			
			self.cameraProperties.updateZoom(newZoom: Double(displacement))
			
		}
		
		self.view.addSubview(joystick2)
		
		joystick2.movable = false
		joystick2.alpha = 1.0
		joystick2.baseAlpha = 0.5 // let the background bleed thru the base
		joystick2.handleTintColor = UIColor.blue // Colorize the handle
		}
	}
	
	func orientationChanged()
	{
		if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
			phoneOrientation = PhoneOrientation.Landscape
			DispatchQueue.main.async {
				 self.customPreviewLayer.bounds = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
				 self.customPreviewLayer.position = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
				 self.customPreviewLayer.affineTransform().rotated(by: CGFloat(Double.pi/2))
				}
		}
		
		else if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
			phoneOrientation = PhoneOrientation.Portrait
			DispatchQueue.main.async {
			self.customPreviewLayer.bounds = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
			self.customPreviewLayer.position = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
			self.customPreviewLayer.affineTransform().rotated(by: CGFloat(Double.pi/2))
				}
		}
		
	}
	
	// MARK: ViewDidAppear

	/// ViewDidAppear(_ animated:) Implementation


	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Subscribe to device rotation notifications

		if shouldUseDeviceOrientation {
			subscribeToDeviceOrientationChangeNotifications()
		}

		// Set background audio preference

		setBackgroundAudioPreference()

		sessionQueue.async {
			switch self.setupResult {
			case .success:
				// Begin Session
				self.session.startRunning()
				self.isSessionRunning = self.session.isRunning
                
                // Preview layer video orientation can be set only after the connection is created
                DispatchQueue.main.async {
                    self.previewLayer.videoPreviewLayer.connection?.videoOrientation = self.getPreviewLayerOrientation()
                }
                
			case .notAuthorized:
				// Prompt to App Settings
				self.promptToAppSettings()
			case .configurationFailed:
				// Unknown Error
				DispatchQueue.main.async(execute: { [unowned self] in
					let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
					let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
					alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
					self.present(alertController, animated: true, completion: nil)
				})
			}
		}
	}

	// MARK: ViewDidDisappear

	/// ViewDidDisappear(_ animated:) Implementation


	override open func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		// If session is running, stop the session
		if self.isSessionRunning == true {
			self.session.stopRunning()
			self.isSessionRunning = false
		}

		//Disble flash if it is currently enabled
		disableFlash()

		// Unsubscribe from device rotation notifications
		if shouldUseDeviceOrientation {
			unsubscribeFromDeviceOrientationChangeNotifications()
		}
	}

	// MARK: Public Functions

	/**

	Capture photo from current session

	UIImage will be returned with the SwiftyCamViewControllerDelegate function SwiftyCamDidTakePhoto(photo:)

	*/

	public func takePhoto() { // changed

		guard let device = videoDevice else {
			return
		}

		//self.capturePhotoAsyncronously(completionHandler: { (success) in
			
		//})

	}

	/**

	Begin recording video of current session

	SwiftyCamViewControllerDelegate function SwiftyCamDidBeginRecordingVideo() will be called

	*/

/*	public func startVideoRecording() { // changed
		guard let movieFileOutput = self.movieFileOutput else {
			return
		}

		if currentCamera == .rear && flashEnabled == true {
			enableFlash()
		}

		if currentCamera == .front && flashEnabled == true {
			flashView = UIView(frame: view.frame)
			flashView?.backgroundColor = UIColor.white
			flashView?.alpha = 0.85
			previewLayer.addSubview(flashView!)
		}

		sessionQueue.async { [unowned self] in
			if !movieFileOutput.isRecording {
				if UIDevice.current.isMultitaskingSupported {
					self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
				}

				// Update the orientation on the movie file output video connection before starting recording.
				let movieFileOutputConnection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo)


				//flip video output if front facing camera is selected
				if self.currentCamera == .front {
					movieFileOutputConnection?.isVideoMirrored = true
				}

				movieFileOutputConnection?.videoOrientation = self.getVideoOrientation()

				// Start recording to a temporary file.
				let outputFileName = UUID().uuidString
				let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
				movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
				self.isVideoRecording = true
				DispatchQueue.main.async {
					self.cameraDelegate?.swiftyCam(self, didBeginRecordingVideo: self.currentCamera)
				}
			}
			else {
				movieFileOutput.stopRecording()
			}
		}
	} */

	/**

	Stop video recording video of current session

	SwiftyCamViewControllerDelegate function SwiftyCamDidFinishRecordingVideo() will be called

	When video has finished processing, the URL to the video location will be returned by SwiftyCamDidFinishProcessingVideoAt(url:)

	*/

 /* public func stopVideoRecording() { // changed
		if self.movieFileOutput?.isRecording == true {
			self.isVideoRecording = false
			movieFileOutput!.stopRecording()
			disableFlash()

			if currentCamera == .front && flashEnabled == true && flashView != nil {
				UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
					self.flashView?.alpha = 0.0
				}, completion: { (_) in
					self.flashView?.removeFromSuperview()
				})
			}
			DispatchQueue.main.async {
				self.cameraDelegate?.swiftyCam(self, didFinishRecordingVideo: self.currentCamera)
			}
		}
	} */

	/**

	Switch between front and rear camera

	SwiftyCamViewControllerDelegate function SwiftyCamDidSwitchCameras(camera:  will be return the current camera selection

	*/


	public func switchCamera() {
	/*	guard isVideoRecording != true else {
			//TODO: Look into switching camera during video recording
			print("[SwiftyCam]: Switching between cameras while recording video is not supported")
			return
		}
        
        guard session.isRunning == true else {
            return
        }
        
		switch currentCamera {
		case .front:
			currentCamera = .rear
		case .rear:
			currentCamera = .front
		}

		session.stopRunning()

		sessionQueue.async { [unowned self] in

			// remove and re-add inputs and outputs

			for input in self.session.inputs {
				self.session.removeInput(input as! AVCaptureInput)
			}

			self.addInputs()
			DispatchQueue.main.async {
				self.cameraDelegate?.swiftyCam(self, didSwitchCameras: self.currentCamera)
			}

			self.session.startRunning()
		}

		// If flash is enabled, disable it as the torch is needed for front facing camera
		disableFlash() */
	}

	// MARK: Private Functions

	/// Configure session, add inputs and outputs

	fileprivate func configureSession() {
		guard setupResult == .success else {
			return
		}

		// Set default camera

		currentCamera = defaultCamera

		// begin configuring session

		session.beginConfiguration()
		configureVideoPreset()
		
		//addAudioInput()
		//configureVideoOutput() // changed
		//configurePhotoOutput()
		DispatchQueue.main.async{
			self.customPreviewLayer = CALayer()
			self.customPreviewLayer.bounds = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
			
			
			self.customPreviewLayer.position = CGPoint(x: self.view.frame.size.width/2.0, y: self.view.frame.size.height/2.0)
			//self.customPreviewLayer.affineTransform().rotated(by: CGFloat(Double.pi/2))
			//self.customPreviewLayer.transform = CATransform3DMakeRotation(CGFloat(Double.pi/2), 0, 0, 0)
			self.view.layer.addSublayer(self.customPreviewLayer)
			self.customPreviewLayer.addSublayer(self.titleLayer)
		}
	
		addVideoInput()
		session.commitConfiguration()
		session.startRunning()
		
	}

	/// Add inputs after changing camera()

	fileprivate func addInputs() {
		session.beginConfiguration()
		configureVideoPreset()
		addVideoInput()
		addAudioInput()
		session.commitConfiguration()
	}


	// Front facing camera will always be set to VideoQuality.high
	// If set video quality is not supported, videoQuality variable will be set to VideoQuality.high
	/// Configure image quality preset

	fileprivate func configureVideoPreset() {
		if currentCamera == .front {
			session.sessionPreset = videoInputPresetFromVideoQuality(quality: .high)
		} else {
			if session.canSetSessionPreset(videoInputPresetFromVideoQuality(quality: videoQuality)) {
				session.sessionPreset = videoInputPresetFromVideoQuality(quality: videoQuality)
			} else {
				session.sessionPreset = videoInputPresetFromVideoQuality(quality: .high)
			}
		}
	}
	
	private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
		guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
		let ciImage = CIImage(cvPixelBuffer: imageBuffer)
		let context = CIContext()
		guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
		let myImg = UIImage(cgImage: cgImage, scale: 1.0, orientation: UIImageOrientation.right)
		return myImg
	}
	
	struct Pixel {
		var value: UInt32
	}

	let titleLayer: CATextLayer = {
		let titleLayer = CATextLayer()
		titleLayer.backgroundColor = UIColor.clear.cgColor
		titleLayer.foregroundColor = UIColor.black.cgColor
		titleLayer.string = "Dummy text"
		titleLayer.font = UIFont(name: "Helvetica", size: 28)
		titleLayer.shadowOpacity = 0.5
		titleLayer.alignmentMode = kCAAlignmentCenter
		titleLayer.bounds = CGRect(x: 0, y: 0, width: 200, height: 110);
		titleLayer.frame = CGRect(x: 50, y: 50, width: 200, height: 110)
		return titleLayer
	}()
	
	let textField: UITextField = {
		let field = UITextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.placeholder = "future is the past which is greatfuture is the past which is greatfuture is the past which is great"
		field.font = UIFont(name: "Arial", size: 20)
		return field
	}()

/*	enum animateSwitch {
		case vibrate, low, high
		mutating func next() {
			switch self {
			case .off:
				self = .low
			case .low:
				self = .high
			case .high:
				self = .off
			}
		}
	} */
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: view)
		
		if(titleLayer.frame.contains(location)){
			vibrateTitleLayer()
		}
	}
	
	 func vibrateTitleLayer(){
		print("HEllo")
		var bounceDist: CGFloat = -20.0
		var it  = 0
		while(it < 3000){
	   bounceDist = -bounceDist
		UIView.animate(withDuration: 1) {
			CATransaction.begin()
			CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
			
			var pos = self.titleLayer.position
			self.titleLayer.position = CGPoint(x: pos.x + bounceDist, y: pos.y)
			CATransaction.commit()
			it = it + 1
		}
	  }
	
	}
	
	func loopTitleLayer(){
		print("Yess")
		var bounceDist: CGFloat = -20.0
		var it  = 0
		while(it < 3000){
			bounceDist = -bounceDist
			UIView.animate(withDuration: 1) {
				CATransaction.begin()
				CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
				
				var pos = self.titleLayer.position
				self.titleLayer.position = CGPoint(x: pos.x + bounceDist, y: pos.y)
				CATransaction.commit()
				it = it + 1
			}
		}
		
	}
	/*
	
	var follow:Bool = false;
	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		
		let location = touch.location(in: view)
		if(view.frame.contains(location)){
			print("yes")
			
			}
		
		if(titleLayer.frame.contains(location)){
			follow = true
		}
		if(follow){
			titleLayer.frame = CGRect(x: location.x, y: location.y, width: 200, height: 110)
		}
	}
	
	*/
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
	
	/*
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		follow = false
	}
	*/
	var oldTime:DispatchTime!
	var newTime:DispatchTime!
	public func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
	
		
		// Checking phone Orientation, adjusting for it
		if (phoneOrientation == PhoneOrientation.Landscape){
			connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
		}else if (phoneOrientation == PhoneOrientation.Portrait){
			connection.videoOrientation = AVCaptureVideoOrientation.portrait
		}
		
		// localizing sample buffer, Read-Write locking the pixel buffer
		let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
		CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
		
		// Preparing values to build a CGContext, a buffer and descriptive values
		let buffer: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
		let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
		let w = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
		let h = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
		
		// Describing and instantializing a CGContext
		let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
		guard let context = CGContext.init(data: buffer, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
			// cannot create context - handle error
			sleep(2)
			exit(0)
		}
		
		if let b = oldTime {
			newTime = DispatchTime.now()
			let nanoTime = newTime.uptimeNanoseconds - b.uptimeNanoseconds
			print(nanoTime)
			oldTime = newTime
			// a not nil, do some stuff
		} else {
			// a is null
			oldTime = DispatchTime.now()
		}
		
		// Make the image
		let dstImage = context.makeImage()
		
		if(!self.zoomflag){
			DispatchQueue.main.async {
				self.customPreviewLayer.contents = dstImage
			}
			return
		}
		
		// Create buffer called imageData, setup values for new CGContext
		let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: w * h)
		let proportion = Double((dstImage?.width)!) / Double((dstImage?.height)!)
		let newBytesPerPixel = 4
		let newBytesPerRow = w * newBytesPerPixel
		
		
		/* Zooming and Translating Section.......................*/
		
		// Retrieve Zoom Ratio
		let oldZoom = cameraProperties.oldZoom
		let newZoom = cameraProperties.zoom
		
		let imageHeight = Double((dstImage?.height)!)
		let imageWidth = Double((dstImage?.width)!)
		var oldHeight: Double = cameraProperties.oldImageHeight
		var newHeight: Double = oldHeight
		if(!(oldZoom == newZoom)){
			
			if(oldHeight == 0.0){ // this is first frame
				oldHeight = imageHeight
			}
			
			if(newZoom < 0){
				newHeight = 0.98 * Double(oldHeight)
			}
			else if (newZoom == 0){
				newHeight = oldHeight
			}
			else{
				newHeight = min(1.03 * Double(oldHeight), imageHeight)
			}
			
		}
		
		// Retrieve camera view origin, transform stickheading into x,y transformation
		let oldOriginX = cameraProperties.oldOriginX
		let oldOriginY = cameraProperties.oldOriginY
		let newHeading = cameraProperties.stickHeading
		
		var newOriginX = oldOriginX
		var newOriginY = oldOriginY

		
		if(newHeading != 0.0){
			 let polarCoordinate = -(newHeading - 90) // converting compass heading into polar coordinate
			 let radCoordinate = polarCoordinate * (Double.pi / 180) //getting it in radians
			 let xChange = cos(radCoordinate) // calculating change in x value, to achieve directionality
			 let yChange = sin(radCoordinate) // calculating change in y value
			 let newXValue = (oldOriginX) + 10.0 * xChange
			 let newYValue = (oldOriginY) + 10.0 * yChange
			 print("x change", xChange)
  			 print("y change", yChange)
		
			 let boundaryX = (imageWidth - (newHeight * proportion))
			 let viewX = oldOriginX + newXValue
			 let boundaryY = (imageHeight - (newHeight))
			 let viewY = oldOriginY + newYValue

			 if (viewX ==  min(boundaryX, viewX)){
				newOriginX = newXValue
				}else{
				newOriginX = boundaryX
			}
		
			if(viewY == min(boundaryY, viewY)){
				newOriginY = newYValue
				}else{
					newOriginY = boundaryY
			}
		newOriginX = newXValue
		newOriginY = newYValue
			
			 newOriginX = max(0, newOriginX)
			 newOriginY = max(0, newOriginY)
		}
		// updating Camera Properties values
		cameraProperties.oldImageHeight = newHeight
		cameraProperties.oldOriginX = newOriginX
		cameraProperties.oldOriginY = newOriginY
			
		
		// Crop the previously created image
		let smallerImage: CGImage = ((dstImage)?.cropping(to: CGRect(x: newOriginX, y: newOriginY, width: newHeight * proportion, height: newHeight)))!
		
		
		// Describing and instantializing a new CGContext
		let newBitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
		guard let contextRef = CGContext.init(data: imageData, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: newBytesPerRow, space: colorSpace, bitmapInfo: newBitmapInfo.rawValue) else {
			print("Cannot create context 2")
			sleep(2)
			exit(0)
		}
		
		// Add text
		

		
		
		// Using that context to redraw the smaller image to the same size as the original
		contextRef.draw(smallerImage, in: CGRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(h)))
		
		// Adding the resized image to the Preview Layer
		DispatchQueue.main.async {
			self.customPreviewLayer.contents = smallerImage
			
		}
		
		// Cleanup
		CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
		imageData.deallocate(capacity: 1)
	
		
		/*
		
		guard let contextRef = CGContext.init(data: ptrr, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: smallerImage.bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
		// cannot create context - handle error
		print("Cannot create context 2")
		sleep(2)
		exit(0)
		}
		CGContextDrawImage(contextRef, CGRect(0, 0, w, h), smallerImage)
		
		//UIGraphicsPopContext()
		DispatchQueue.main.async{
		self.customPreviewLayer.contents = smallerImage
		}
		CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
		
		*/
		/*
		
		print("bytes per row", (4 * w))
		
		let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.last.rawValue)
		guard let context = CGContext.init(data: buffer, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: 4 * w, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
		// cannot create context - handle error
		print("Cannot Create Context")
		sleep(2)
		exit(0)
		}
		
		// Create a Quartz image from the pixel data in the bitmap graphics context
		let quartzImage: CGImage = context.makeImage()!;
		
		/*
		
		UIGraphicsBeginImageContext(CGSize(width: w, height: h));
		let c: CGContext = UIGraphicsGetCurrentContext()!
		ctxData = c.data!
		
		memcpy(ctxData, buffer, 4 * w * h); */
		
		CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0));
		
		/*
		print("Hello World")
		
		let uint32Pointer = ctxData.bindMemory(to: UInt32.self, capacity: 1)
		let dataBuffer = UnsafeBufferPointer(start: uint32Pointer, count: w * h)
		let data = Array(dataBuffer)
		
		data.forEach { (rgbArr) in
		let b: UInt8 = UInt8((rgbArr >> 3) & 0xFF)
		let g: UInt8 = UInt8((rgbArr >> 2) & 0xff)
		let r: UInt8 = UInt8((rgbArr >> 1) & 0xff)
		let rgb: UInt8 = ((r&0x0ff)<<16)|((g&0x0ff)<<8)|(b&0x0ff)
		pixelVals += [rgb]
		}
		
		capturePic = true
		
		let image: CGImage = imageFromPixelValues(pixelValues: pixelVals, width: w, height: h)!
		img = UIImage(cgImage: image)
		} */
		// Free up the context and color space
		
		// Create an image object from the Quartz image
		
		img = UIImage(cgImage: quartzImage, scale: CGFloat(1.0), orientation: UIImageOrientation.right)
		*/
		//}

	}
	

	/*
	public func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
		print("buffered")
		let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
		CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
		let width: size_t = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
		let height: size_t = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
		let bytesPerRow: size_t = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
		let lumaBuffer: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
		let grayColorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
		let context: CGContext = CGContext(data: lumaBuffer, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: grayColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!//problematic
		
		let dstImageFilter: CGImage = context.makeImage()!
	   img = UIImage(cgImage: dstImageFilter)
		
		CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
		CIContext *temporaryContext = [CIContext contextWithOptions:nil];
		CGImageRef videoImage = [temporaryContext
			createCGImage:ciImage
			fromRect:CGRectMake(0, 0,
			CVPixelBufferGetWidth(imageBuffer),
			CVPixelBufferGetHeight(imageBuffer))];
		
		UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
		[self doSomethingWithOurUIImage:image];
		CGImageRelease(videoImage);
		
	} */
	
	
	
	func displayImage(){
		DispatchQueue.main.async {
			let imageView: UIImageView = {
				let view = UIImageView(image: self.img)
				view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
				view.translatesAutoresizingMaskIntoConstraints = true
				return view
			}()
			
			self.view.addSubview(imageView)
		}
	}
	
	func timerFired(){
		capturePic = false
	}
	
	func imageFromPixelValues(pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage?
	{
		var imageRef: CGImage?
		if pixelValues != nil {
			let imageDataPointer = UnsafeMutablePointer<UInt8>(mutating: pixelValues!)
			
			let colorSpaceRef = CGColorSpaceCreateDeviceGray()
			
			let bitsPerComponent = 8
			let bytesPerPixel = 1
			let bitsPerPixel = bytesPerPixel * bitsPerComponent
			let bytesPerRow = bytesPerPixel * width
			let totalBytes = height * bytesPerRow
			
			let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
				.union([])
			let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
				// https://developer.apple.com/reference/coregraphics/cgdataproviderreleasedatacallback
				// N.B. 'CGDataProviderRelease' is unavailable: Core Foundation objects are automatically memory managed
				return
			}
			let providerRef = CGDataProvider(dataInfo: nil, data: imageDataPointer, size: totalBytes, releaseData: releaseMaskImagePixelData)
			imageRef = CGImage(width: width,
			                   height: height,
			                   bitsPerComponent: bitsPerComponent,
			                   bitsPerPixel: bitsPerPixel,
			                   bytesPerRow: bytesPerRow,
			                   space: colorSpaceRef,
			                   bitmapInfo: bitmapInfo,
			                   provider: providerRef!,
			                   decode: nil,
			                   shouldInterpolate: false,
			                   intent: CGColorRenderingIntent.defaultIntent)
		}
		
		return imageRef
	}

	/// Add Video Inputs

	fileprivate func addVideoInput() {
		switch currentCamera {
		case .front:
			videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .front)
		case .rear:
			videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .back)
		}

		if let device = videoDevice {
			do {
				try device.lockForConfiguration()
				if device.isFocusModeSupported(.continuousAutoFocus) {
					device.focusMode = .continuousAutoFocus
					if device.isSmoothAutoFocusSupported {
						device.isSmoothAutoFocusEnabled = true
					}
				}

				if device.isExposureModeSupported(.continuousAutoExposure) {
					device.exposureMode = .continuousAutoExposure
				}

				if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
					device.whiteBalanceMode = .continuousAutoWhiteBalance
				}

				if device.isLowLightBoostSupported && lowLightBoost == true {
					device.automaticallyEnablesLowLightBoostWhenAvailable = true
				}

				device.unlockForConfiguration()
			} catch {
				print("[SwiftyCam]: Error locking configuration")
			}
		}

		do {
			let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
			
			let videoDeviceOutput = try AVCaptureVideoDataOutput()
			videoDeviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)]
			
			let outputQueue: DispatchQueue  = DispatchQueue(label: "session queue")
			videoDeviceOutput.setSampleBufferDelegate(self, queue: outputQueue)
			videoDeviceOutput.alwaysDiscardsLateVideoFrames = true;
			//videoDeviceOutput.videoSettings = nil;
			
			if session.canAddInput(videoDeviceInput) {
				session.addInput(videoDeviceInput)
				self.videoDeviceInput = videoDeviceInput
				
			} else {
				print("[SwiftyCam]: Could not add video device input to the session")
				print(session.canSetSessionPreset(videoInputPresetFromVideoQuality(quality: videoQuality)))
				setupResult = .configurationFailed
				session.commitConfiguration()
				return
			}
			
			if session.canAddOutput(videoDeviceOutput){
				session.addOutput(videoDeviceOutput)
				self.videoDeviceOutput = videoDeviceOutput
			}
		} catch {
			print("[SwiftyCam]: Could not create video device input: \(error)")
			setupResult = .configurationFailed
			return
		}
		
		// Preview

			/*
			let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
			
			if session.canAddInput(videoDeviceInput) {
				session.addInput(videoDeviceInput)
				self.videoDeviceInput = videoDeviceInput
			} else {
				print("[SwiftyCam]: Could not add video device input to the session")
				print(session.canSetSessionPreset(videoInputPresetFromVideoQuality(quality: videoQuality)))
				setupResult = .configurationFailed
				
				let output = AVCaptureVideoDataOutput()
				
				let queue = DispatchQueue(label: "myQueue")
				
				
				output.setSampleBufferDelegate(self, queue: queue)
				output.alwaysDiscardsLateVideoFrames = false
				
				output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)]
				session.addOutput(output)
				
				
				self.session.startRunning()
				
				session.commitConfiguration()
				return
			}
		} catch {
			print("[SwiftyCam]: Could not create video device input: \(error)")
			setupResult = .configurationFailed
			return
		} */
	}

	/// Add Audio Inputs

	fileprivate func addAudioInput() {
        guard audioEnabled == true else {
            return
        }
		do {
			let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
			let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)

			if session.canAddInput(audioDeviceInput) {
				session.addInput(audioDeviceInput)
			}
			else {
				print("[SwiftyCam]: Could not add audio device input to the session")
			}
		}
		catch {
			print("[SwiftyCam]: Could not create audio device input: \(error)")
		}
	}

	/// Configure Movie Output, target

	fileprivate func configureVideoOutput() { // changed
		/*
		let movieFileOutput = AVCaptureMovieFileOutput()

		if self.session.canAddOutput(movieFileOutput) {
			self.session.addOutput(movieFileOutput)
			if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
				if connection.isVideoStabilizationSupported {
					connection.preferredVideoStabilizationMode = .auto
				}
			}
			self.movieFileOutput = movieFileOutput
		}
*/
	}

	/// Configure Photo Output

	/*fileprivate func configurePhotoOutput() {
		let photoFileOutput = AVCaptureStillImageOutput()

		if self.session.canAddOutput(photoFileOutput) {
			photoFileOutput.outputSettings  = [AVVideoCodecKey: AVVideoCodecJPEG]
			self.session.addOutput(photoFileOutput)
			self.photoFileOutput = photoFileOutput
		}
	} */

	/// Orientation management

	fileprivate func subscribeToDeviceOrientationChangeNotifications() {
		self.deviceOrientation = UIDevice.current.orientation
		NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
	}

	fileprivate func unsubscribeFromDeviceOrientationChangeNotifications() {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		self.deviceOrientation = nil
	}

	@objc fileprivate func deviceDidRotate() {
		if !UIDevice.current.orientation.isFlat {
			self.deviceOrientation = UIDevice.current.orientation
		}
	}
    
    fileprivate func getPreviewLayerOrientation() -> AVCaptureVideoOrientation {
        // Depends on layout orientation, not device orientation
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .unknown:
            return AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        }
    }

	fileprivate func getVideoOrientation() -> AVCaptureVideoOrientation {
		guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return previewLayer!.videoPreviewLayer.connection.videoOrientation }

		switch deviceOrientation {
		case .landscapeLeft:
			return .landscapeRight
		case .landscapeRight:
			return .landscapeLeft
		case .portraitUpsideDown:
			return .portraitUpsideDown
		default:
			return .portrait
		}
	}

	fileprivate func getImageOrientation(forCamera: CameraSelection) -> UIImageOrientation {
		guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return forCamera == .rear ? .right : .leftMirrored }

		switch deviceOrientation {
		case .landscapeLeft:
			return forCamera == .rear ? .up : .downMirrored
		case .landscapeRight:
			return forCamera == .rear ? .down : .upMirrored
		case .portraitUpsideDown:
			return forCamera == .rear ? .left : .rightMirrored
		default:
			return forCamera == .rear ? .right : .leftMirrored
		}
	}

	/**
	Returns a UIImage from Image Data.

	- Parameter imageData: Image Data returned from capturing photo from the capture session.

	- Returns: UIImage from the image data, adjusted for proper orientation.
	*/

	fileprivate func processPhoto(_ imageData: Data) -> UIImage { // target
		let dataProvider = CGDataProvider(data: imageData as CFData)
		let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)

		// Set proper orientation for photo
		// If camera is currently set to front camera, flip image

		let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: self.getImageOrientation(forCamera: self.currentCamera))

		return image
	}

	// target
/*	fileprivate func capturePhotoAsyncronously(completionHandler: @escaping(Bool) -> ()) {
		if let videoConnection = photoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {

			photoFileOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
				if (sampleBuffer != nil) {
					let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
					let image = self.processPhoto(imageData!)

					// Call delegate and return new image
					DispatchQueue.main.async {
						self.cameraDelegate?.swiftyCam(self, didTake: image)
					}
					completionHandler(true)
				} else {
					completionHandler(false)
				}
			})
		} else {
			completionHandler(false)
		}
	} */

	/// Handle Denied App Privacy Settings

	fileprivate func promptToAppSettings() {
		// prompt User with UIAlertView

		DispatchQueue.main.async(execute: { [unowned self] in
			let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
			let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
				if #available(iOS 10.0, *) {
					UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
				} else {
					if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
						UIApplication.shared.openURL(appSettings)
					}
				}
			}))
			self.present(alertController, animated: true, completion: nil)
		})
	}

	/**
	Returns an AVCapturePreset from VideoQuality Enumeration

	- Parameter quality: ViewQuality enum

	- Returns: String representing a AVCapturePreset
	*/

	fileprivate func videoInputPresetFromVideoQuality(quality: VideoQuality) -> String {
		switch quality {
		case .high: return AVCaptureSessionPresetHigh
		case .medium: return AVCaptureSessionPresetMedium
		case .low: return AVCaptureSessionPresetLow
		case .resolution352x288: return AVCaptureSessionPreset352x288
		case .resolution640x480: return AVCaptureSessionPreset640x480
		case .resolution1280x720: return AVCaptureSessionPreset1280x720
		case .resolution1920x1080: return AVCaptureSessionPreset1920x1080
		case .iframe960x540: return AVCaptureSessionPresetiFrame960x540
		case .iframe1280x720: return AVCaptureSessionPresetiFrame1280x720
		case .resolution3840x2160:
			if #available(iOS 9.0, *) {
				return AVCaptureSessionPreset3840x2160
			}
			else {
				print("[SwiftyCam]: Resolution 3840x2160 not supported")
				return AVCaptureSessionPresetHigh
			}
		}
	}

	/// Get Devices

	fileprivate class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
		if let devices = AVCaptureDevice.devices(withMediaType: mediaType) as? [AVCaptureDevice] {
			return devices.filter({ $0.position == position }).first
		}
		return nil
	}

	/// Enable or disable flash for photo

	fileprivate func changeFlashSettings(device: AVCaptureDevice, mode: AVCaptureFlashMode) {
		do {
			try device.lockForConfiguration()
			device.flashMode = mode
			device.unlockForConfiguration()
		} catch {
			print("[SwiftyCam]: \(error)")
		}
	}

	/// Enable flash

	fileprivate func enableFlash() {
		if self.isCameraTorchOn == false {
			toggleFlash()
		}
	}

	/// Disable flash

	fileprivate func disableFlash() {
		if self.isCameraTorchOn == true {
			toggleFlash()
		}
	}

	/// Toggles between enabling and disabling flash

	fileprivate func toggleFlash() {
		guard self.currentCamera == .rear else {
			// Flash is not supported for front facing camera
			return
		}

		let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		// Check if device has a flash
		if (device?.hasTorch)! {
			do {
				try device?.lockForConfiguration()
				if (device?.torchMode == AVCaptureTorchMode.on) {
					device?.torchMode = AVCaptureTorchMode.off
					self.isCameraTorchOn = false
				} else {
					do {
						try device?.setTorchModeOnWithLevel(1.0)
						self.isCameraTorchOn = true
					} catch {
						print("[SwiftyCam]: \(error)")
					}
				}
				device?.unlockForConfiguration()
			} catch {
				print("[SwiftyCam]: \(error)")
			}
		}
	}

	/// Sets whether SwiftyCam should enable background audio from other applications or sources

	fileprivate func setBackgroundAudioPreference() {
		guard allowBackgroundAudio == true else {
			return
		}
        
        guard audioEnabled == true else {
            return
        }

		do{
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
			                                                with: [.duckOthers, .defaultToSpeaker])

			session.automaticallyConfiguresApplicationAudioSession = false
		}
		catch {
			print("[SwiftyCam]: Failed to set background audio preference")

		}
	}
}

class CameraProperties: NSObject {
	var oldZoom: Double = 0.0
	var zoom: Double = 0.0
	var oldImageHeight = 0.0
	var newImageHeight = 0.0
	
	var stickHeading = 0.0
	var oldOriginX = 0.0
	var oldOriginY = 0.0
	func updateZoom(newZoom: Double){
		oldZoom = zoom
		zoom = newZoom
	}
	func updateHeading(heading: Double){
		stickHeading = heading
	}
}

extension SwiftyCamViewController : SwiftyCamButtonDelegate {
	public func buttonDidEndLongPress() {
		
	}
	
	public func longPressDidReachMaximumDuration() {
		
	}
	

	/// Sets the maximum duration of the SwiftyCamButton

	public func setMaxiumVideoDuration() -> Double {
		return maximumVideoDuration
	}

	/// Set UITapGesture to take photo

	public func buttonWasTapped() {
		takePhoto()
	}

	/// Set UILongPressGesture start to begin video

	public func buttonDidBeginLongPress() {
		//startVideoRecording()
	}


}


