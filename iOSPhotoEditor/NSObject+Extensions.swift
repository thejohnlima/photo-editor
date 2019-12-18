//
//  NSObject+Extensions.swift
//  Photo Editor
//
//  Created by John Lima on 12/17/19.
//  Copyright © 2019 thejohnlima. All rights reserved.
//

import Foundation

extension NSObject {
  var identifier: String {
    return String(describing: type(of: self))
  }

  static var identifier: String {
    return String(describing: self)
  }
}
