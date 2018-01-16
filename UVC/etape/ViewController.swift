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
			let allDevies: [AVCaptureDevice] = AVCaptureDevice.devices(for: .video)
			let aDevice: AVCaptureDevice = choose aDevie from allDevices
			
			let uvc: UVC = try UVC(device: aDevice)
			
			uvc.autoFocus = false
			uvc.focus = 0.5
			
			uvc.autoExposure = false
			uvc.exposure = 0.9
			
			uvc.autoWhitebalance = false
			uvc.whitebalance = 0.9
			
			print(uvc.brightness)
			print(uvc.contrast)
			print(uvc.gain)
			print(uvc.saturation)
			print(uvc.sharpness)
			
			let layer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: .init())
			layer.videoGravity = .resizeAspectFill
			layer.bounds = view.bounds
			
			try layer.session?.addInput(AVCaptureDeviceInput(device: aDevice))
			layer.session?.sessionPreset = .hd1280x720
			layer.session?.startRunning()
			
			view.layer = layer
			view.wantsLayer = true
			
		} catch {
			print(error)
		}
	}
}
