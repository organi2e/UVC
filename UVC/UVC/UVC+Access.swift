//
//  UVC+Access.swift
//  UVC
//
//  Created by Kota Nakano on 2017/10/12.
//  Copyright © 2017 organi2e. All rights reserved.
//
import IOKit.usb.IOUSBLib
import Foundation
import os.log
internal extension UVC {
	enum GetTarget: UInt8 {
		case cur = 0b10000001
		case min = 0b10000010
		case max = 0b10000011
	}
	func get<T>(unit: UInt16, selector: UInt16, target: GetTarget) -> T {
		return Data(count: MemoryLayout<T>.size).withUnsafeBytes { (ref: UnsafePointer<T>) in
			var request: IOUSBDevRequest = IOUSBDevRequest(bmRequestType: UInt8(kUSBTypeIn),
			                                               bRequest: target.rawValue,
			                                               wValue: (selector<<8)|flag,
			                                               wIndex: (unit<<8)|flag,
			                                               wLength: UInt16(MemoryLayout<T>.size),
			                                               pData: UnsafeMutablePointer<T>(mutating: ref),
			                                               wLenDone: 0)
			guard
				interface.pointee.pointee.USBInterfaceOpen(interface) == kIOReturnSuccess,
				interface.pointee.pointee.ControlRequest(interface, 0, &request) == kIOReturnSuccess,
				interface.pointee.pointee.USBInterfaceClose(interface) == kIOReturnSuccess else {
					os_log("%@, %@", log: facility, type: .fault, #function, #line)
					return ref.pointee
			}
			return ref.pointee
		}
	}
}
internal extension UVC {
	func get1F(unit: UInt16, selector: UInt16) -> Float {
		let min: UInt8 = get(unit: unit, selector: selector, target: .min)
		let max: UInt8 = get(unit: unit, selector: selector, target: .max)
		let cur: UInt8 = get(unit: unit, selector: selector, target: .cur)
		return Float(cur-min) / Float(max-min)
	}
	func get2F(unit: UInt16, selector: UInt16) -> Float {
		let min: UInt16 = get(unit: unit, selector: selector, target: .min)
		let max: UInt16 = get(unit: unit, selector: selector, target: .max)
		let cur: UInt16 = get(unit: unit, selector: selector, target: .cur)
		return Float(cur-min) / Float(max-min)
	}
	func get4F(unit: UInt16, selector: UInt16) -> Float {
		let min: UInt32 = get(unit: unit, selector: selector, target: .min)
		let max: UInt32 = get(unit: unit, selector: selector, target: .max)
		let cur: UInt32 = get(unit: unit, selector: selector, target: .cur)
		return Float(cur-min) / Float(max-min)
	}
}
internal extension UVC {
	enum SetTarget: UInt8 {
		case cur = 0b00000001
	}
	func set<T>(unit: UInt16, selector: UInt16, target: SetTarget, value: T) {
		var ref: T = value
		var request: IOUSBDevRequest = IOUSBDevRequest(bmRequestType: UInt8(kUSBTypeOut),
		                                               bRequest: target.rawValue,
		                                               wValue: (selector<<8)|flag,
		                                               wIndex: (unit<<8)|flag,
		                                               wLength: UInt16(MemoryLayout<T>.size),
		                                               pData: &ref,
		                                               wLenDone: 0)
		guard
			interface.pointee.pointee.USBInterfaceOpen(interface) == kIOReturnSuccess,
			interface.pointee.pointee.ControlRequest(interface, 0, &request) == kIOReturnSuccess,
			interface.pointee.pointee.USBInterfaceClose(interface) == kIOReturnSuccess else {
				os_log("%@, %@", log: facility, type: .fault, #function, #line)
				return
		}
	}
}
internal extension UVC {
	func set1F(unit: UInt16, selector: UInt16, value: Float) {
		let min: UInt8 = get(unit: unit, selector: selector, target: .min)
		let max: UInt8 = get(unit: unit, selector: selector, target: .max)
		let cur: UInt8 = min + UInt8(Float(max-min)*value)
		set(unit: unit, selector: selector, target: .cur, value: cur)
	}
	func set2F(unit: UInt16, selector: UInt16, value: Float) {
		let min: UInt16 = get(unit: unit, selector: selector, target: .min)
		let max: UInt16 = get(unit: unit, selector: selector, target: .max)
		let cur: UInt16 = min + UInt16(Float(max-min)*value)
		set(unit: unit, selector: selector, target: .cur, value: cur)
	}
	func set4F(unit: UInt16, selector: UInt16, value: Float) {
		let min: UInt32 = get(unit: unit, selector: selector, target: .min)
		let max: UInt32 = get(unit: unit, selector: selector, target: .max)
		let cur: UInt32 = min + UInt32(Float(max-min)*value)
		set(unit: unit, selector: selector, target: .cur, value: cur)
	}
}
private let kUSBTypeIn: Int = ((kUSBIn&kUSBRqDirnMask)<<kUSBRqDirnShift)|((kUSBClass&kUSBRqTypeMask)<<kUSBRqTypeShift)|(kUSBInterface&kUSBRqRecipientMask)
private let kUSBTypeOut: Int = ((kUSBOut&kUSBRqDirnMask)<<kUSBRqDirnShift)|((kUSBClass&kUSBRqTypeMask)<<kUSBRqTypeShift)|(kUSBInterface&kUSBRqRecipientMask)
