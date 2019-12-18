//
//  UICollectionView+Extensions.swift
//  Photo Editor
//
//  Created by John Lima on 12/17/19.
//  Copyright © 2019 thejohnlima. All rights reserved.
//

import UIKit

extension UICollectionView {
  func register<T: UICollectionViewCell>(_: T.Type) {
    register(T.self, forCellWithReuseIdentifier: T.identifier)
  }

  func registerNib<T: UICollectionViewCell>(_: T.Type) {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.identifier, bundle: bundle)
    register(nib, forCellWithReuseIdentifier: T.identifier)
  }

  func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
      fatalError("\(errorDequeueReusableCell): \(T.identifier)")
    }
    return cell
  }
}
