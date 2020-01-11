//
//  PhotoEditor+Keyboard.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

extension PhotoEditorViewController {
  @objc
  func keyboardDidShow(notification: NSNotification) {
    if isTyping {
      textStyleButton.isHidden = false
      doneButton.isHidden = false
      colorPickerView.isHidden = false
      hideToolbar(hide: true)
    }
  }

  @objc
  func keyboardWillHide(notification: NSNotification) {
    isTyping = false
    textStyleButton.isHidden = true
    doneButton.isHidden = true
    hideToolbar(hide: false)
    colorPickerView.isHidden = true
  }

  @objc
  func keyboardWillChangeFrame(_ notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

      UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: { self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
}
