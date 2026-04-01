//
//  HSFloat+Float.swift
//  Hiddy
//
//  Created by APPLE on 04/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import Foundation
extension TimeInterval {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
