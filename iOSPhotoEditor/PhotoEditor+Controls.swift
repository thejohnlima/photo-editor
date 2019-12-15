//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

// MARK: - Control
public enum control {
  case crop
  case sticker
  case draw
  case text
  case save
  case share
  case clear
}

extension PhotoEditorViewController {
  // MARK: - Top Toolbar
  @IBAction func cancelButtonTapped(_ sender: Any) {
    photoEditorDelegate?.canceledEditing()
    self.dismiss(animated: true)
  }

  @IBAction func cropButtonTapped(_ sender: UIButton) {
    let controller = CropViewController()
    controller.delegate = self
    controller.image = image
    let navController = UINavigationController(rootViewController: controller)
    present(navController, animated: true)
  }

  @IBAction func stickersButtonTapped(_ sender: Any) {
    addStickersViewController()
  }

  @IBAction func drawButtonTapped(_ sender: Any) {
    isDrawing = true
    canvasImageView.isUserInteractionEnabled = false
    doneButton.isHidden = false
    colorPickerView.isHidden = false
    hideToolbar(hide: true)
  }

  @IBAction func textButtonTapped(_ sender: Any) {
    isTyping = true

    let frame = CGRect(
      x: 0,
      y: canvasImageView.center.y,
      width: UIScreen.main.bounds.width,
      height: 30
    )

    let textView = UITextView(frame: frame)
    textView.textAlignment = .center
    textView.font = .systemFont(ofSize: 30)
    textView.textColor = textColor
    textView.layer.shadowColor = UIColor.black.cgColor
    textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
    textView.layer.shadowOpacity = 0.2
    textView.layer.shadowRadius = 1.0
    textView.layer.backgroundColor = UIColor.clear.cgColor
    textView.autocorrectionType = .no
    textView.isScrollEnabled = false
    textView.delegate = self

    canvasImageView.addSubview(textView)
    addGestures(view: textView)

    textView.becomeFirstResponder()
  }

  @IBAction func doneButtonTapped(_ sender: Any) {
    view.endEditing(true)
    doneButton.isHidden = true
    colorPickerView.isHidden = true
    canvasImageView.isUserInteractionEnabled = true
    hideToolbar(hide: false)
    isDrawing = false
  }

  //MARK: - Bottom Toolbar
  @IBAction func saveButtonTapped(_ sender: AnyObject) {
    UIImageWriteToSavedPhotosAlbum(
      canvasView.toImage(),
      self,
      #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)),
      nil
    )
  }

  @IBAction func shareButtonTapped(_ sender: UIButton) {
    let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
    present(activity, animated: true)
  }

  @IBAction func clearButtonTapped(_ sender: AnyObject) {
    // clear drawing
    canvasImageView.image = nil
    // clear stickers and textviews
    for subview in canvasImageView.subviews {
      subview.removeFromSuperview()
    }
  }

  @IBAction func continueButtonPressed(_ sender: Any) {
    let img = self.canvasView.toImage()
    photoEditorDelegate?.doneEditing(image: img)
    dismiss(animated: true)
  }

  // MAKR: - helper methods
  @objc
  func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
    let alert = UIAlertController(
      title: "Image Saved",
      message: "Image successfully saved to Photos library",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    present(alert, animated: true)
  }

  func hideControls() {
    for control in hiddenControls {
      switch control {
      case .clear:
        clearButton.isHidden = true
      case .crop:
        cropButton.isHidden = true
      case .draw:
        drawButton.isHidden = true
      case .save:
        saveButton.isHidden = true
      case .share:
        shareButton.isHidden = true
      case .sticker:
        stickerButton.isHidden = true
      case .text:
        stickerButton.isHidden = true
      }
    }
  }
}
