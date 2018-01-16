//
//  UVC.swift
//  UVC
//
//  Created by Kota Nakano on 2017/10/11.
//  Copyright © 2017 organi2e. All rights reserved.
//
import AVFoundation
import Cocoa
import IOKit.usb.IOUSBLib
import os.log

public class UVC {
	let facility: OSLog
	let interface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>
	let flag: UInt16
	public init(device: AVCaptureDevice, isC615: Bool = true) throws {
		let (vendorID, productID): (NSNumber, NSNumber) = try device.modelID.toVnP()
		let dictionary: NSMutableDictionary = IOServiceMatching("IOUSBDevice") as NSMutableDictionary
		dictionary["idVendor"] = vendorID
		dictionary["idProduct"] = productID
		
		var interfaceRef: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>?
		let camera: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, dictionary)
		defer {
			let code: kern_return_t = IOObjectRelease(camera)
			assert( code == kIOReturnSuccess )
		}
		try camera.ioCreatePluginInterfaceFor(service: kIOUSBDeviceUserClientTypeID) {
			let deviceInterface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>> = try $0.getInterface(uuid: kIOUSBDeviceInterfaceID)
			defer { _ = deviceInterface.pointee.pointee.Release(deviceInterface) }
			let interfaceRequest: IOUSBFindInterfaceRequest = IOUSBFindInterfaceRequest(bInterfaceClass: 0xe,
			                                                                            bInterfaceSubClass: 0x1,
			                                                                            bInterfaceProtocol: UInt16(kIOUSBFindInterfaceDontCare),
			                                                                            bAlternateSetting: UInt16(kIOUSBFindInterfaceDontCare))
			try deviceInterface.iterate(of: interfaceRequest) {
				interfaceRef = try $0.getInterface(uuid: kIOUSBInterfaceInterfaceID)
			}
		}
		guard interfaceRef != nil else { throw NSError(domain: #function, code: #line, userInfo: nil) }
		interface = interfaceRef.unsafelyUnwrapped
		flag = isC615 ? 0x02 : 0x00
		facility = OSLog(subsystem: Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName, category: "UVC")
	}
	deinit { _ = interface.pointee.pointee.Release(interface) }
}
private extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<IOUSBDeviceInterface> {
	func iterate(of: IOUSBFindInterfaceRequest, handle:(UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>>)throws->Void)rethrows {
		var iterator: io_iterator_t = 0
		guard pointee.pointee.CreateInterfaceIterator(self, UnsafeMutablePointer<IOUSBFindInterfaceRequest>(mutating: [of]), &iterator) == kIOReturnSuccess else { return }
		defer {
			let code: kern_return_t = IOObjectRelease(iterator)
			assert( code == kIOReturnSuccess )
		}
		while true {
			let object: io_service_t = IOIteratorNext(iterator)
			defer {
				let code: kern_return_t = IOObjectRelease(object)
				assert( code == kIOReturnSuccess )
			}
			guard 0 < object else { break }
			try object.ioCreatePluginInterfaceFor(service: kIOUSBInterfaceUserClientTypeID, handle: handle)
		}
	}
}
private extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<IOCFPlugInInterface> {
	func getInterface<T>(uuid: CFUUID) throws -> UnsafeMutablePointer<T> {
		var ref: LPVOID?
		guard pointee.pointee.QueryInterface(self, CFUUIDGetUUIDBytes(uuid), &ref) == kIOReturnSuccess,
			let result: UnsafeMutablePointer<T> = ref?.assumingMemoryBound(to: T.self) else {
				throw NSError(domain: #function, code: #line, userInfo: nil)
		}
		return result
	}
}
private extension io_object_t {
	func ioCreatePluginInterfaceFor(service: CFUUID, handle: (UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>>)throws->Void)rethrows{
		var ref: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?
		var score: Int32 = 0
		guard IOCreatePlugInInterfaceForService(self, service, kIOCFPlugInInterfaceID, &ref, &score) == kIOReturnSuccess, score == 0 else { return }
		defer { _ = ref?.pointee?.pointee.Release(ref) }
		try ref?.withMemoryRebound(to: UnsafeMutablePointer<IOCFPlugInInterface>.self, capacity: 1, handle)
	}
}
private extension String {
	func toVnP() throws -> (NSNumber, NSNumber) {
		let regex: NSRegularExpression = try NSRegularExpression(pattern: "^UVC\\s+Camera\\s+VendorID\\_([0-9]+)\\s+ProductID\\_([0-9]+)$", options: [])
		guard
			let match: NSTextCheckingResult = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)), 3 == match.numberOfRanges,
			let vendorIDRange: Range<String.Index> = Range<String.Index>(match.range(at: 1), in: self),
			let vendorID: Int = Int(self[vendorIDRange]),
			let productIDRange: Range<String.Index> = Range<String.Index>(match.range(at: 2), in: self),
			let productID: Int = Int(self[productIDRange]) else {
				throw NSError(domain: #file, code: #line, userInfo: ["query": self])
		}
		return (vendorID as NSNumber, productID as NSNumber)
	}
}
private let kIOUSBInterfaceUserClientTypeID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                     0x2d, 0x97, 0x86, 0xc6,
                                                                                     0x9e, 0xf3, 0x11, 0xD4,
                                                                                     0xad, 0x51, 0x00, 0x0a,
                                                                                     0x27, 0x05, 0x28, 0x61)
private let kIOUSBInterfaceInterfaceID: CFUUID =  CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                 0x73, 0xc9, 0x7a, 0xe8,
                                                                                 0x9e, 0xf3, 0x11, 0xD4,
                                                                                 0xb1, 0xd0, 0x00, 0x0a,
                                                                                 0x27, 0x05, 0x28, 0x61)
private let kIOUSBDeviceUserClientTypeID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                  0x9d, 0xc7, 0xb7, 0x80,
                                                                                  0x9e, 0xc0, 0x11, 0xD4,
                                                                                  0xa5, 0x4f, 0x00, 0x0a,
                                                                                  0x27, 0x05, 0x28, 0x61)
private let kIOCFPlugInInterfaceID: CFUUID =  CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                             0xC2, 0x44, 0xE8, 0x58,
                                                                             0x10, 0x9C, 0x11, 0xD4,
                                                                             0x91, 0xD4, 0x00, 0x50,
                                                                             0xE4, 0xC6, 0x42, 0x6F)
private let kIOUSBDeviceInterfaceID: CFUUID =  CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                              0x5c, 0x81, 0x87, 0xd0,
                                                                              0x9e, 0xf3, 0x11, 0xD4,
                                                                              0x8b, 0x45, 0x00, 0x0a,
                                                                              0x27, 0x05, 0x28, 0x61)
