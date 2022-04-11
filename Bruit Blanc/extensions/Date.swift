//
//  Date.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 11/04/2022.
//

import Foundation

extension Date {
  func toString( dateFormat format  : String ) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}
