//
//  UVC+Exposure.swift
//  UVC
//
//  Created by Kota Nakano on 2017/10/12.
//  Copyright © 2017 organi2e. All rights reserved.
//
public extension UVC {
	var autoExposure: Bool {
		get {
			let value: UInt8 = get(unit: unit, selector: auto, target: .cur)
			return value == 0x8
		}
		set {
			let value: UInt8 = newValue ? 0x8 : 0x1
			set(unit: unit, selector: auto, target: .cur, value: value)
		}
	}
}
public extension UVC {
	var exposure: Float {
		get {
			return 1 - get2F(unit: unit, selector: configure)
		}
		set {
			set2F(unit: unit, selector: configure, value: 1 - newValue)
		}
	}
}
private let unit: UInt16 = 0x1
private let auto: UInt16 = 0x2
private let configure: UInt16 = 0x4
