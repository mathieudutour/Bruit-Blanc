//
//  DurationPicker.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 12/04/2022.
//

import SwiftUI

struct DurationPicker: UIViewRepresentable {
  @Binding var duration: TimeInterval

  func makeUIView(context: Context) -> UIDatePicker {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .countDownTimer
    datePicker.addTarget(context.coordinator, action: #selector(Coordinator.updateDuration), for: .valueChanged)
    // workaround https://stackoverflow.com/questions/63011877/uidatepicker-mode-countdowntimer-value-changed-callback-not-calling-first-time
    DispatchQueue.main.async {
      datePicker.countDownDuration = duration
    }
    return datePicker
  }

  func updateUIView(_ datePicker: UIDatePicker, context: Context) {
    datePicker.countDownDuration = duration
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    let parent: DurationPicker

    init(_ parent: DurationPicker) {
      self.parent = parent
    }

    @objc func updateDuration(datePicker: UIDatePicker) {
      parent.duration = datePicker.countDownDuration
    }
  }
}

struct DurationPicker_Previews: PreviewProvider {
  static var previews: some View {
    StatefulPreview(TimeInterval(30 * 60)) {
      DurationPicker(duration: $0).preferredColorScheme(.dark)
    }
  }
}
