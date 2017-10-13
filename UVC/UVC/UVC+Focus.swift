//
//  UVC+Focus.swift
//  UVC
//
//  Created by Kota Nakano on 2017/10/12.
//  Copyright © 2017 organi2e. All rights reserved.
//
public extension UVC {
	var autoFocus: Bool {
		get {
			return get(unit: unit, selector: auto, target: .cur)
		}
		set {
			set(unit: unit, selector: auto, target: .cur, value: newValue)
		}
	}
}
public extension UVC {
	var focus: Float {
		get {
			return get2F(unit: unit, selector: configure)
		}
		set {
			set2F(unit: unit, selector: configure, value: newValue)
		}
	}
}
private let unit: UInt16 = 0x1
private let auto: UInt16 = 0x8
private let configure: UInt16 = 0x6
