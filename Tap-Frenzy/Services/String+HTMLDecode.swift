//
//  String+HTMLDecode.swift
//  Tap-Frenzy
//
//  Created by StudentR on 2026-07-12.
//

import Foundation
import UIKit

extension String {
    var htmlDecoded: String {
        self
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&eacute;", with: "é")
    }
}
