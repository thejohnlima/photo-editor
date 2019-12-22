//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public final class PhotoEditorViewController: UIViewController {

  // MARK: - Properties
  /// Holding the 2 imageViews original image and drawing & stickers
  @IBOutlet weak var canvasView: UIView!

  /// To hold the image
  @IBOutlet var imageView: UIImageView!

  /// To hold the drawings and stickers
  @IBOutlet weak var canvasImageView: UIImageView!

  @IBOutlet weak var topToolbar: UIView!
  @IBOutlet weak var bottomToolbar: UIView!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var deleteView: UIView!
  @IBOutlet weak var colorPickerView: UIView!
  @IBOutlet weak var finishButton: UIButton!
  @IBOutlet weak var cropButton: UIButton!
  @IBOutlet weak var stickerButton: UIButton!
  @IBOutlet weak var drawButton: UIButton!
  @IBOutlet weak var textButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var clearButton: UIButton!

  /// Array of Stickers -UIImage- that the user will choose from
  public var stickers: [UIImage] = []

  /// Array of Colors that will show while drawing or typing
  public var colors: [UIColor] = []

  /// List of controls to be hidden
  public var hiddenControls : [control] = []

  public var image: UIImage?
  public var isInitialStickerEnable = false
  public var photoEditorDelegate: PhotoEditorDelegate?

  var stickersVCIsVisible = false
  var drawColor: UIColor = .label
  var textColor: UIColor = .label
  var isDrawing: Bool = false
  var lastPoint: CGPoint!
  var swiped = false
  var lastPanPoint: CGPoint?
  var lastTextViewTransform: CGAffineTransform?
  var lastTextViewTransCenter: CGPoint?
  var lastTextViewFont:UIFont?
  var activeTextView: UITextView?
  var imageViewToPan: UIImageView?
  var isTyping: Bool = false
  var stickersViewController: StickersViewController!
  var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!

  var colorsCollectionView: UICollectionView {
    let frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: 48
    )

    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 30, height: 30)
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0

    let collection = UICollectionView(frame: frame, collectionViewLayout: layout)
    collection.delegate = colorsCollectionViewDelegate
    collection.dataSource = colorsCollectionViewDelegate
    collection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    collection.showsHorizontalScrollIndicator = false
    collection.backgroundColor = .clear
    collection.registerNib(ColorCollectionViewCell.self)

    return collection
  }

  var colorPickerVisualEffectView: UIVisualEffectView {
    let view = UIVisualEffectView(frame: colorPickerView.bounds)
    let blur = UIBlurEffect(style: .systemMaterial)
    view.effect = blur
    view.contentView.addSubview(colorsCollectionView)
    return view
  }

  var textView: UITextView {
    let frame = CGRect(
      x: 0,
      y: canvasImageView.center.y,
      width: UIScreen.main.bounds.width,
      height: 44
    )

    let textView = UITextView(frame: frame)
    textView.textAlignment = .center
    textView.font = .systemFont(ofSize: 36, weight: .medium)
    textView.textColor = textColor
    textView.backgroundColor = .clear
    textView.tintColor = .label
    textView.autocorrectionType = .no
    textView.keyboardAppearance = .dark
    textView.isScrollEnabled = false
    textView.delegate = self

    return textView
  }

  // MARK: - Initializers
  public init() {
    let bundle = Bundle(for: PhotoEditorViewController.self)
    super.init(nibName: PhotoEditorViewController.identifier, bundle: bundle)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: - View LifeCycle
  override public func viewDidLoad() {
    super.viewDidLoad()
    setImageView(image: image!)
    setDeleteView()
    setGestures()
    setPickerColors()
    setInitialSticker()
    setFinishButton()
    hideControls()

    stickersViewController = StickersViewController(
      nibName: StickersViewController.identifier,
      bundle: Bundle(for: StickersViewController.self)
    )
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    addObervers()
  }

  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    removeObervers()
  }

  // MARK: - Overrides
  // Register Custom font before we load XIB
  public override func loadView() {
    registerFont()
    super.loadView()
  }

  // MARK: - Internal Methods
  func setPickerColors() {
    colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
    colorsCollectionViewDelegate.colorDelegate = self

    if !colors.isEmpty {
      colorsCollectionViewDelegate.colors = colors
    }

    colorPickerVisualEffectView.removeFromSuperview()

    colorPickerView.addSubview(colorsCollectionView)
    colorPickerView.isHidden = true
  }

  func setImageView(image: UIImage) {
    imageView.image = image
    imageView.layer.cornerRadius = 10
  }

  func hideToolbar(hide: Bool) {
    topToolbar.isHidden = hide
    bottomToolbar.isHidden = hide
  }

  // MARK: - Private Methods
  private func setDeleteView() {
    deleteView.layer.cornerRadius = deleteView.bounds.height / 2
    deleteView.layer.borderWidth = 2
    deleteView.layer.borderColor = UIColor.systemRed.cgColor
    deleteView.clipsToBounds = true
  }

  private func setInitialSticker() {
    guard isInitialStickerEnable else { return }
    let accessoryView = colorPickerVisualEffectView
    accessoryView.frame.size.height = 48
    accessoryView.frame.origin = .zero

    let textView = self.textView
    textView.text = Date().toText(.medium)?.uppercased().replacingOccurrences(of: ",", with: "")
    textView.font = .systemFont(ofSize: 48)
    textView.frame.origin.y = canvasImageView.bounds.height * 0.7
    textView.frame.size.height = 80
    textView.inputAccessoryView = accessoryView

    addGestures(view: textView)
    canvasView.addSubview(textView)
  }

  private func setFinishButton() {
    finishButton.layer.cornerRadius = finishButton.bounds.height / 2
    finishButton.layer.masksToBounds = true
  }

  private func setGestures() {
    let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
    edgePan.edges = .bottom
    edgePan.delegate = self
    view.addGestureRecognizer(edgePan)
  }

  private func addObervers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDidShow),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(_:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )
  }

  private func removeObervers() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
}

// MARK: - ColorDelegate
extension PhotoEditorViewController: ColorDelegate {
  func didSelectColor(color: UIColor) {
    if isDrawing {
      drawColor = color
    } else if activeTextView != nil {
      activeTextView?.textColor = color
      activeTextView?.tintColor = color
      textColor = color
    }
  }
}
