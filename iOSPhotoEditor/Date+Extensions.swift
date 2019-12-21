//
//  Date+Extensions.swift
//  Photo Editor
//
//  Created by John Lima on 12/21/19.
//  Copyright © 2019 thejohnlima. All rights reserved.
//

import Foundation

extension Date {
  func toText(_ format: DateFormatter.Style) -> String? {
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.dateStyle = format
    let text = formatter.string(from: self)
    return text
  }
}
