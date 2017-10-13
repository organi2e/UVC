//
//  ViewController.swift
//  etape
//
//  Created by Kota Nakano on 2017/10/13.
//  Copyright © 2017 organi2e. All rights reserved.
//
import Cocoa
import AVFoundation
import UVC

class ViewController: NSViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		do {
			print(AVCaptureDevice.devices(for: .video).map{$0.localizedName})
			guard let device: AVCaptureDevice = AVCaptureDevice.devices(for: .video).filter({$0.localizedName=="Logitech Camera"}).first else {
				throw NSError(domain: #function, code: #line, userInfo: nil)
			}
			let uvc: UVC = try UVC(device: device)
			
			uvc.autoWhitebalance = false
			
			uvc.autoFocus = false
			uvc.autoExposure = false
			uvc.exposure = 0.987
			uvc.focus = 0.53
			
			//			uvc.gain = 0.0627451
			uvc.contrast = 0.5
			uvc.brightness = 0.5
			uvc.saturation = 0.5
			uvc.sharpness = 0.2
			
			print(uvc.brightness)
			print(uvc.contrast)
			print(uvc.gain)
			print(uvc.saturation)
			print(uvc.sharpness)
			
			let layer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: .init())
			layer.videoGravity = .resizeAspectFill
			layer.bounds = view.bounds
			try layer.session?.addInput(AVCaptureDeviceInput(device: device))
			layer.session?.sessionPreset = .hd1280x720
			layer.session?.startRunning()
			
			view.layer = layer
			view.wantsLayer = true
		} catch {
			print(error)
			return
		}
	}
}
