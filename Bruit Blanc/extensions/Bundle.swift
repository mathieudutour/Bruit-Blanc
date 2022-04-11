//
//  Bundle.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 09/04/2022.
//

import UIKit

extension Bundle {

  var icon: UIImage? {

    if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
       let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
       let files = primary["CFBundleIconFiles"] as? [String],
       let icon = files.last
    {
      return UIImage(named: icon)
    }

    return nil
  }
}
