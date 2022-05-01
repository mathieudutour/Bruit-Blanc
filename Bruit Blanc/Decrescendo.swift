//
//  Decrescendo.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 12/04/2022.
//

import SwiftUI
import AVKit
import MediaPlayer

private var formatter: DateComponentsFormatter {
  let formatter = DateComponentsFormatter()
  formatter.unitsStyle = .abbreviated
  formatter.allowedUnits = [.hour, .minute]
  return formatter
}

struct Decrescendo: View {
  @Binding var isPresented: Bool
  @ObservedObject var playState: PlayState
  @AppStorage("decrescendoDuration") var duration: TimeInterval = TimeInterval(15 * 60)

  var body: some View {
    NavigationView {
      ZStack {
        Color.backgroundColor.edgesIgnoringSafeArea(.all)
        VStack {
          Text("Start a decrescendo to progressively lower the master volume over time")
            .font(.subheadline)
            .foregroundColor(.init(white: 0.7))
            .padding()
          DurationPicker(duration: $duration)
          Text("After \(formatter.string(from: duration) ?? ""), the volume of Bruit Blanc will reach 0.")
            .font(.subheadline)
            .foregroundColor(.init(white: 0.7))
            .padding()
          Spacer()
        }
      }
      .navigationBarTitle(Text("Decrescendo"), displayMode: .inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(action: {
            isPresented = false
          }) {
            Text("Cancel")
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(action: {
            playState.startDecrescendo(duration: duration)
            isPresented = false
          }) {
            Text("Start").bold()
          }
        }
      }
    }
  }
}

struct Decrescendo_Previews: PreviewProvider {
  static var previews: some View {
    StatefulPreview(true) {
      Decrescendo(isPresented: $0, playState: PlayState()).preferredColorScheme(.dark)
    }
  }
}
