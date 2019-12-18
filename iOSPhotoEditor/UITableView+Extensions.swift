//
//  UITableView+Extensions.swift
//  Photo Editor
//
//  Created by John Lima on 12/17/19.
//  Copyright © 2019 thejohnlima. All rights reserved.
//

import UIKit

let errorDequeueReusableCell = "Could not dequeue cell with identifier"

extension UITableView {
  func register<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: T.identifier)
  }

  func registerNib<T: UITableViewCell>(_: T.Type) {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.identifier, bundle: bundle)
    register(nib, forCellReuseIdentifier: T.identifier)
  }

  func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("\(errorDequeueReusableCell): \(T.identifier)")
    }
    return cell
  }
}
