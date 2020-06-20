//
//  PhotoEditor+Font.swift
//
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

extension PhotoEditorViewController {
  /// Resources don't load in main bundle we have to register the font
  func registerFont() {
    let bundle = Bundle(for: PhotoEditorViewController.self)
    let url =  bundle.url(forResource: "icomoon", withExtension: "ttf")

    guard let fontDataProvider = CGDataProvider(url: url! as CFURL) else {
      return
    }

    guard let font = CGFont(fontDataProvider) else {return}
    var error: Unmanaged<CFError>?
    guard CTFontManagerRegisterGraphicsFont(font, &error) else {
      return
    }
  }
}

extension UIFont {
  /// Returns a new font with the weight specified
  /// - Parameter weight: The new font weight
  func withWeight(_ weight: UIFont.Weight) -> UIFont {
    let newDescriptor = fontDescriptor.addingAttributes([.traits: [
      UIFontDescriptor.TraitKey.weight: weight]
    ])
    return UIFont(descriptor: newDescriptor, size: pointSize)
  }

  func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    let descriptor = fontDescriptor.withSymbolicTraits(traits)
    return UIFont(descriptor: descriptor!, size: 0)
  }

  func bold() -> UIFont {
    return withTraits(traits: .traitBold)
  }

  func italic() -> UIFont {
    return withTraits(traits: .traitItalic)
  }
}
