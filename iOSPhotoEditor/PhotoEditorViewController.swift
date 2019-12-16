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
  /** holding the 2 imageViews original image and drawing & stickers */
  @IBOutlet weak var canvasView: UIView!

  /// To hold the image
  @IBOutlet var imageView: UIImageView!
  @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

  /// To hold the drawings and stickers
  @IBOutlet weak var canvasImageView: UIImageView!
  @IBOutlet weak var topToolbar: UIView!
  @IBOutlet weak var bottomToolbar: UIView!
  @IBOutlet weak var topGradient: UIView!
  @IBOutlet weak var bottomGradient: UIView!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var deleteView: UIView!
  @IBOutlet weak var colorPickerView: UIView!

  // Controls
  @IBOutlet weak var cropButton: UIButton!
  @IBOutlet weak var stickerButton: UIButton!
  @IBOutlet weak var drawButton: UIButton!
  @IBOutlet weak var textButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var clearButton: UIButton!

  public var image: UIImage?

  /**
   Array of Stickers -UIImage- that the user will choose from
   */
  public var stickers: [UIImage] = []

  /**
   Array of Colors that will show while drawing or typing
   */
  public var colors: [UIColor] = []
  public var photoEditorDelegate: PhotoEditorDelegate?

  /// list of controls to be hidden
  public var hiddenControls : [control] = []

  var stickersVCIsVisible = false
  var drawColor: UIColor = UIColor.black
  var textColor: UIColor = UIColor.white
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

    collection.register(
      UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
      forCellWithReuseIdentifier: "ColorCollectionViewCell"
    )

    return collection
  }

  var colorPickerVisualEffectView: UIVisualEffectView {
    let view = UIVisualEffectView(frame: colorPickerView.bounds)
    let blur = UIBlurEffect(style: .regular)
    view.effect = blur
    view.contentView.addSubview(colorsCollectionView)
    return view
  }

  var textView: UITextView {
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
    textView.keyboardAppearance = .dark
    textView.isScrollEnabled = false
    textView.delegate = self

    return textView
  }

  // MARK: - Initializers
  public init() {
    let bundle = Bundle(for: PhotoEditorViewController.self)
    super.init(nibName: "PhotoEditorViewController", bundle: bundle)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: - View LifeCycle
  override public func viewDidLoad() {
    super.viewDidLoad()
    setImageView(image: image!)

    deleteView.layer.cornerRadius = deleteView.bounds.height / 2
    deleteView.clipsToBounds = true

    let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
    edgePan.edges = .bottom
    edgePan.delegate = self

    view.addGestureRecognizer(edgePan)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardDidShow),
                                           name: UIResponder.keyboardDidShowNotification,
                                           object: nil)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillChangeFrame(_:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification,
                                           object: nil)

    let bundle = Bundle(for: StickersViewController.self)

    configurePickerColors()
    hideControls()

    stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: bundle)
  }

  // MARK: - Overrides
  // Register Custom font before we load XIB
  public override func loadView() {
    registerFont()
    super.loadView()
  }

  // MARK: - Internal Methods
  func configurePickerColors() {
    colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
    colorsCollectionViewDelegate.colorDelegate = self

    if !colors.isEmpty {
      colorsCollectionViewDelegate.colors = colors
    }

    colorPickerVisualEffectView.removeFromSuperview()

    colorPickerView.addSubview(colorPickerVisualEffectView)
    colorPickerView.isHidden = true
  }

  func setImageView(image: UIImage) {
    imageView.image = image
    let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
    imageViewHeightConstraint.constant = (size?.height)!
  }

  func hideToolbar(hide: Bool) {
    topToolbar.isHidden = hide
    topGradient.isHidden = hide
    bottomToolbar.isHidden = hide
    bottomGradient.isHidden = hide
  }
}

// MARK: - ColorDelegate
extension PhotoEditorViewController: ColorDelegate {
  func didSelectColor(color: UIColor) {
    if isDrawing {
      drawColor = color
    } else if activeTextView != nil {
      activeTextView?.textColor = color
      textColor = color
    }
  }
}
