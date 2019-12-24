//
//  ColorsCollectionViewDelegate.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/1/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

struct Color {
  /**
   Array of Colors that will show while drawing or typing
   */
  var colors: [UIColor] = [
    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
    #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
    #colorLiteral(red: 0.8784313725, green: 0.1803921569, blue: 0.2666666667, alpha: 1),
    #colorLiteral(red: 0.1882352941, green: 0.5176470588, blue: 0.937254902, alpha: 1),
    #colorLiteral(red: 0.4, green: 0.7098039216, blue: 0.2235294118, alpha: 1),
    #colorLiteral(red: 0.9764705882, green: 0.7490196078, blue: 0.262745098, alpha: 1),
    #colorLiteral(red: 0.9607843137, green: 0.462745098, blue: 0.1254901961, alpha: 1),
    #colorLiteral(red: 0.7450980392, green: 0, blue: 0.3411764706, alpha: 1),
    #colorLiteral(red: 0.5450980392, green: 0, blue: 0.6823529412, alpha: 1),
    #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1),
    #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1),
    #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1),
    #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),
    #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1),
    #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
    #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1),
    #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
    #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
  ]
}

class ColorsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

  var color = Color()

  weak var colorDelegate: ColorDelegate?
  weak var stickersViewControllerDelegate: StickersViewControllerDelegate?

  override init() {
    super.init()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return color.colors.count
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    colorDelegate?.didSelectColor(color: color.colors[indexPath.item])
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: ColorCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
    cell.colorView.backgroundColor = color.colors[indexPath.item]
    return cell
  }
}
