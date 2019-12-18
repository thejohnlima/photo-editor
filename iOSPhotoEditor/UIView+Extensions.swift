//
//  UIView+Extensions.swift
//  Photo Editor
//
//  Created by John Lima on 12/17/19.
//  Copyright © 2019 thejohnlima. All rights reserved.
//

import UIKit

extension UIView {
  static func hapticFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
    let notification = UINotificationFeedbackGenerator()
    notification.notificationOccurred(type)
  }
  
  static func impactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
    let impact = UIImpactFeedbackGenerator(style: style)
    impact.impactOccurred()
  }
  
  static func selectionFeedback() {
    let selection = UISelectionFeedbackGenerator()
    selection.selectionChanged()
  }
}
