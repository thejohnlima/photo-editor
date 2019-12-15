//
//  PhotoEditor+Crop.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

// MARK: - CropView
extension PhotoEditorViewController: CropViewControllerDelegate {
  public func cropViewController(_ controller: CropViewController,
                                 didFinishCroppingImage image: UIImage,
                                 transform: CGAffineTransform,
                                 cropRect: CGRect) {
    controller.dismiss(animated: true)
    setImageView(image: image)
  }

  public func cropViewControllerDidCancel(_ controller: CropViewController) {
    controller.dismiss(animated: true)
  }
}
