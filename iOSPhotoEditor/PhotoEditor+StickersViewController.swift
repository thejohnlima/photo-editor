//
//  PhotoEditor+StickersViewController.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

extension PhotoEditorViewController {
  func addStickersViewController() {
    stickersVCIsVisible = true
    hideToolbar(hide: true)
    canvasImageView.isUserInteractionEnabled = false
    stickersViewController.stickersViewControllerDelegate = self

    for image in self.stickers {
      stickersViewController.stickers.append(image)
    }

    self.addChild(stickersViewController)
    self.view.addSubview(stickersViewController.view)

    stickersViewController.didMove(toParent: self)

    let height = view.frame.height
    let width  = view.frame.width

    stickersViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
  }

  func removeStickersView() {
    stickersVCIsVisible = false
    canvasImageView.isUserInteractionEnabled = true

    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
      var frame = self.stickersViewController.view.frame
      frame.origin.y = UIScreen.main.bounds.maxY
      self.stickersViewController.view.frame = frame
    }, completion: { _ in
      self.stickersViewController.view.removeFromSuperview()
      self.stickersViewController.removeFromParent()
      self.hideToolbar(hide: false)
    })
  }
}

extension PhotoEditorViewController: StickersViewControllerDelegate {
  func didSelectView(view: UIView) {
    removeStickersView()
    view.center = canvasImageView.center
    canvasImageView.addSubview(view)
    addGestures(view: view)
  }

  func didSelectImage(image: UIImage) {
    self.removeStickersView()

    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.frame.size = CGSize(width: 150, height: 150)
    imageView.center = canvasImageView.center

    canvasImageView.addSubview(imageView)
    addGestures(view: imageView)
  }

  func stickersViewDidDisappear() {
    stickersVCIsVisible = false
    hideToolbar(hide: false)
  }

  func addGestures(view: UIView) {
    view.isUserInteractionEnabled = true

    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
    panGesture.minimumNumberOfTouches = 1
    panGesture.maximumNumberOfTouches = 1
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
    pinchGesture.delegate = self
    view.addGestureRecognizer(pinchGesture)

    let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action:#selector(rotationGesture(_:)))
    rotationGestureRecognizer.delegate = self
    view.addGestureRecognizer(rotationGestureRecognizer)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
    view.addGestureRecognizer(tapGesture)
  }
}
