//
//  Protocols.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/15/17.
//
//

import UIKit

/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */
public protocol PhotoEditorDelegate: AnyObject {
  /**
   - Parameter image: edited Image
   - Parameter controller: current controller
   */
  func doneEditing(image: UIImage, controller: UIViewController)

  /**
   StickersViewController did Disappear
   */
  func canceledEditing()
}

/**
 - didSelectView
 - didSelectImage
 - stickersViewDidDisappear
 */
protocol StickersViewControllerDelegate: AnyObject {
  /**
   - Parameter view: selected view from StickersViewController
   */
  func didSelectView(view: UIView)

  /**
   - Parameter image: selected Image from StickersViewController
   */
  func didSelectImage(image: UIImage)

  /**
   StickersViewController did Disappear
   */
  func stickersViewDidDisappear()
}

/**
 - didSelectColor
 */
protocol ColorDelegate: AnyObject {
  func didSelectColor(color: UIColor)
}
