//
//  FutureIntegration.swift
//  DemoSwiftyCam
//
//  Created by Mohamed Bande on 10/1/17.
//  Copyright © 2017 Cappsule. All rights reserved.
//

import UIKit
import AVFoundation




// MARK: AVCaptureFileOutputRecordingDelegate

/*extension SwiftyCamViewController : AVCaptureFileOutputRecordingDelegate { // changed

/// Process newly captured video and write it to temporary directory

public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
if let currentBackgroundRecordingID = backgroundRecordingID {
backgroundRecordingID = UIBackgroundTaskInvalid

if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
}
}
if error != nil {
print("[SwiftyCam]: Movie file finishing error: \(error)")
DispatchQueue.main.async {
self.cameraDelegate?.swiftyCam(self, didFailToRecordVideo: error)
}
} else {
//Call delegate function with the URL of the outputfile
DispatchQueue.main.async {
self.cameraDelegate?.swiftyCam(self, didFinishProcessVideoAt: outputFileURL)
}
}
}
} */

