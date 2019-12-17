//
//  StickersViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//  Credit https://github.com/AhmedElassuty/IOS-BottomSheet

import UIKit

class StickersViewController: UIViewController, UIGestureRecognizerDelegate {

  // MARK: - Properties
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var holdView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!

  var collectioView: UICollectionView!
  var emojisCollectioView: UICollectionView!
  var emojisDelegate: EmojisCollectionViewDelegate!
  var stickers: [UIImage] = []
  var stickersViewControllerDelegate: StickersViewControllerDelegate?
  let screenSize = UIScreen.main.bounds.size
  let fullView: CGFloat = 100 // Remainder of screen height

  var partialView: CGFloat {
    return UIScreen.main.bounds.height - 380
  }

  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureCollectionViews()

    scrollView.contentSize = CGSize(width: 2.0 * screenSize.width, height: scrollView.frame.size.height)
    scrollView.isPagingEnabled = true
    scrollView.delegate = self

    pageControl.numberOfPages = 2
    holdView.layer.cornerRadius = 3

    let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
    gesture.delegate = self

    view.addGestureRecognizer(gesture)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    prepareBackgroundView()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 0.6) { [weak self] in
      guard let `self` = self else { return }
      let frame = self.view.frame
      let yComponent = self.partialView
      self.view.frame = CGRect(
        x: 0,
        y: yComponent,
        width: frame.width,
        height: UIScreen.main.bounds.height - self.partialView
      )
    }
  }

  // MARK: - Overrides
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectioView.frame = CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: view.frame.height - 40
    )

    emojisCollectioView.frame = CGRect(
      x: scrollView.frame.size.width,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: view.frame.height - 40
    )

    scrollView.contentSize = CGSize(width: 2.0 * screenSize.width, height: scrollView.frame.size.height)
  }

  // MARK: - Internal Methods
  func configureCollectionViews() {
    let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height - 40)

    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)

    let width = (CGFloat) ((screenSize.width - 30) / 3.0)
    layout.itemSize = CGSize(width: width, height: 100)

    collectioView = UICollectionView(frame: frame, collectionViewLayout: layout)
    collectioView.backgroundColor = .clear
    scrollView.addSubview(collectioView)
    collectioView.delegate = self
    collectioView.dataSource = self

    let stickerBundle = Bundle(for: StickerCollectionViewCell.self)

    collectioView.register(
      UINib(nibName: "StickerCollectionViewCell", bundle: stickerBundle),
      forCellWithReuseIdentifier: "StickerCollectionViewCell"
    )

    let emojisFrame = CGRect(
      x: scrollView.frame.size.width,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: view.frame.height - 40
    )

    let emojislayout = UICollectionViewFlowLayout()
    emojislayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
    emojislayout.itemSize = CGSize(width: 70, height: 70)

    emojisCollectioView = UICollectionView(frame: emojisFrame, collectionViewLayout: emojislayout)
    emojisCollectioView.backgroundColor = .clear
    scrollView.addSubview(emojisCollectioView)
    emojisDelegate = EmojisCollectionViewDelegate()
    emojisDelegate.stickersViewControllerDelegate = stickersViewControllerDelegate
    emojisCollectioView.delegate = emojisDelegate
    emojisCollectioView.dataSource = emojisDelegate

    let emojiBundle = Bundle(for: EmojiCollectionViewCell.self)

    emojisCollectioView.register(
      UINib(nibName: "EmojiCollectionViewCell", bundle: emojiBundle),
      forCellWithReuseIdentifier: "EmojiCollectionViewCell"
    )
  }

  @objc
  func panGesture(_ recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translation(in: self.view)
    let velocity = recognizer.velocity(in: self.view)
    let y = self.view.frame.minY

    if y + translation.y >= fullView {
      let newMinY = y + translation.y
      self.view.frame = CGRect(
        x: 0,
        y: newMinY,
        width: view.frame.width,
        height: UIScreen.main.bounds.height - newMinY
      )
      self.view.layoutIfNeeded()
      recognizer.setTranslation(.zero, in: self.view)
    }

    if recognizer.state == .ended {
      var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y)
      duration = duration > 1.3 ? 1 : duration

      // Velocity is direction of gesture
      UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
        if  velocity.y >= 0 {
          if y + translation.y >= self.partialView  {
            self.removeBottomSheetView()
          } else {
            self.view.frame = CGRect(
              x: 0,
              y: self.partialView,
              width: self.view.frame.width,
              height: UIScreen.main.bounds.height - self.partialView
            )
            self.view.layoutIfNeeded()
          }
        } else {
          if y + translation.y >= self.partialView {
            self.view.frame = CGRect(
              x: 0,
              y: self.partialView,
              width: self.view.frame.width,
              height: UIScreen.main.bounds.height - self.partialView
            )
            self.view.layoutIfNeeded()
          } else {
            self.view.frame = CGRect(
              x: 0,
              y: self.fullView,
              width: self.view.frame.width,
              height: UIScreen.main.bounds.height - self.fullView
            )
            self.view.layoutIfNeeded()
          }
        }
      }, completion: nil)
    }
  }

  func removeBottomSheetView() {
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
      var frame = self.view.frame
      frame.origin.y = UIScreen.main.bounds.maxY
      self.view.frame = frame
    }, completion: { _ in
      self.view.removeFromSuperview()
      self.removeFromParent()
      self.stickersViewControllerDelegate?.stickersViewDidDisappear()
    })
  }

  func prepareBackgroundView(){
    let blurEffect = UIBlurEffect(style: .systemMaterial)
    let visualEffect = UIVisualEffectView(effect: blurEffect)

    let bluredView = UIVisualEffectView(effect: blurEffect)
    bluredView.contentView.addSubview(visualEffect)
    visualEffect.frame = UIScreen.main.bounds
    bluredView.frame = UIScreen.main.bounds

    view.insertSubview(bluredView, at: 0)
  }
}

// MARK: - UIScrollViewDelegate
extension StickersViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.bounds.width
    let pageFraction = scrollView.contentOffset.x / pageWidth
    self.pageControl.currentPage = Int(round(pageFraction))
  }
}

// MARK: - UICollectionViewDataSource
extension StickersViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return stickers.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let identifier = "StickerCollectionViewCell"
    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! StickerCollectionViewCell
    cell.stickerImage.image = stickers[indexPath.item]
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension StickersViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    stickersViewControllerDelegate?.didSelectImage(image: stickers[indexPath.item])
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension StickersViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 4
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}
