//
//  String.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 14/04/2022.
//

import UIKit

extension String {
  func sizeUsingFont(usingFont font: UIFont) -> CGSize {
    let fontAttributes = [NSAttributedString.Key.font: font]
    return self.size(withAttributes: fontAttributes)
  }
}
