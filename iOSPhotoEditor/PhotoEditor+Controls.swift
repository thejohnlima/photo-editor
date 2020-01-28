//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

private var defaultFieldProperties: (font: UIFont?, size: CGSize)?

private func getFontSize(_ textLength: Int, boundingBox: CGRect) -> CGFloat {
  let area: CGFloat = boundingBox.width * boundingBox.height
  return sqrt(area / CGFloat(textLength))
}

public enum Control {
  case crop
  case sticker
  case draw
  case text
  case save
  case share
  case clear
}

enum TextStyle {
  case strong(width: CGFloat, field: AnyObject?)
  case classic(width: CGFloat, field: AnyObject?)
  case typer(width: CGFloat, field: AnyObject?)

  var font: UIFont? {
    switch self {
    case .strong(let width, let object):
      if let field = object as? UITextView, let superview = field.superview {
        field.frame.size = CGSize(width: width, height: superview.bounds.height / 3)
        field.center.x = superview.center.x
        let fontSize = getFontSize(field.text.count, boundingBox: field.frame)
        return UIFont(name: "Helvetica Neue Bold Italic", size: fontSize)
      }
      return defaultFieldProperties?.font
    case .classic(_, let object):
      if let field = object as? UITextView, let superview = field.superview {
        field.frame.size = defaultFieldProperties?.size ?? .zero
      }
      return defaultFieldProperties?.font
    case .typer(_, let object):
      if let field = object as? UITextView, let superview = field.superview {
        field.frame.size = defaultFieldProperties?.size ?? .zero
      }
      return defaultFieldProperties?.font
    }
  }

  var title: String? {
    switch self {
    case .strong:
      return "Strong"
    case .classic:
      return "Classic"
    case .typer:
      return "Typer"
    }
  }
}

extension PhotoEditorViewController {

  // MARK: - Actions
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
    let accessoryView = colorPickerVisualEffectView
    accessoryView.frame.size.height = 48
    accessoryView.frame.origin = .zero

    let textView = self.textView
    textView.inputAccessoryView = accessoryView

    textStyleButton.tag = 1

    isTyping = true
    canvasImageView.addSubview(textView)
    addGestures(view: textView)
    prepareStyle(textStyleButton)

    defaultFieldProperties?.font = textView.font
    defaultFieldProperties?.size = textView.frame.size

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
    let img = canvasView.toImage()
    photoEditorDelegate?.doneEditing(image: img)
    dismiss(animated: true)
  }

  @IBAction func changeTextStyle(_ sender: Any?) {
    guard let button = sender as? UIButton else { return }

    if button.tag == 3 {
      button.tag = 1
    } else {
      button.tag += 1
    }

    prepareStyle(button)

    let style = getTextStyle(button.tag)

    if let font = style?.font {
      activeTextView?.font = font
    }
  }

  // MAKR: - Internal Methods
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

  func getTextStyle(_ fromTag: Int) -> TextStyle? {
    switch fromTag {
    case 2:
      return .strong(width: UIScreen.main.bounds.width - 64, field: activeTextView)
    case 3:
      return .typer(width: activeTextView?.bounds.width ?? 0, field: activeTextView)
    default:
      return .classic(width: activeTextView?.bounds.width ?? 0, field: activeTextView)
    }
  }

  private func prepareStyle(_ button: UIButton) {
    let style = getTextStyle(button.tag)
    button.setTitle(style?.title?.uppercased(), for: .normal)
  }
}
