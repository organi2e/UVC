//
//  UVC+Processing.swift
//  UVC
//
//  Created by Kota Nakano on 2017/10/12.
//  Copyright © 2017 organi2e. All rights reserved.
//

import Foundation
public extension UVC {
	var brightness: Float {
		get {
			return get2F(unit: unit, selector: 0x2)
		}
		set {
			set2F(unit: unit, selector: 0x2, value: newValue)
		}
	}
}
public extension UVC {
	var contrast: Float {
		get {
			return get2F(unit: unit, selector: 0x3)
		}
		set {
			set2F(unit: unit, selector: 0x3, value: newValue)
		}
	}
}
public extension UVC {
	var gain: Float {
		get {
			return get2F(unit: unit, selector: 0x4)
		}
		set {
			set2F(unit: unit, selector: 0x4, value: newValue)
		}
	}
}
public extension UVC {
	var saturation: Float {
		get {
			return get2F(unit: unit, selector: 0x7)
		}
		set {
			set2F(unit: unit, selector: 0x7, value: newValue)
		}
	}
}
public extension UVC {
	var sharpness: Float {
		get {
			return get2F(unit: unit, selector: 0x8)
		}
		set {
			set2F(unit: unit, selector: 0x8, value: newValue)
		}
	}
}
private let unit: UInt16 = 0x2
