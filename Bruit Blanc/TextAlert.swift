//
//  TextAlert.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 11/04/2022.
//

import UIKit
import SwiftUI

struct TextAlert {
  public func show(title: String, message: String, ok: String = "OK", _ handler: @escaping ((String?) -> Void)) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addTextField() { textField in

    }
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in handler(nil) })
    alert.addAction(UIAlertAction(title: ok, style: .default) { _ in handler(alert.textFields?[0].text) })
    showAlert(alert: alert)
  }

  private func showAlert(alert: UIAlertController) {
    if let controller = topMostViewController() {
      controller.present(alert, animated: true)
    }
  }

  private func keyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
    .filter {$0.activationState == .foregroundActive}
    .compactMap {$0 as? UIWindowScene}
    .first?.windows.filter {$0.isKeyWindow}.first
  }

  private func topMostViewController() -> UIViewController? {
    guard let rootController = keyWindow()?.rootViewController else {
      return nil
    }
    return topMostViewController(for: rootController)
  }

  private func topMostViewController(for controller: UIViewController) -> UIViewController {
    if let presentedController = controller.presentedViewController {
        return topMostViewController(for: presentedController)
    }

    if let navigationController = controller as? UINavigationController {
      guard let topController = navigationController.topViewController else {
        return navigationController
      }
      return topMostViewController(for: topController)
    }

    if let tabController = controller as? UITabBarController {
      guard let topController = tabController.selectedViewController else {
        return tabController
      }
      return topMostViewController(for: topController)
    }
    return controller
  }

}
