//
//  Equalizer.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 08/04/2022.
//

import SwiftUI
import AVKit
import MediaPlayer

struct EqualizerLine: View {
  let sound: Sound

  @Binding var volume: Float

  var body: some View {
    HStack(spacing: 0) {
      VStack {
        Spacer()
        if let icon = sound.icon {
          Image(icon)
            .resizable()
            .scaledToFit()
            .foregroundColor(.white)
            .frame(width: 80)
        }
        Text(sound.title)
          .font(.body)
          .lineLimit(sound.title.split(separator: " ").count > 1 ? 2 : 1)
          .allowsTightening(true)
          .minimumScaleFactor(0.75)
          .foregroundColor(.white)
          .padding(.horizontal)
        Spacer()
      }
      Spacer()
      Slider(value: $volume, in: 0...1)
        .accessibilityIdentifier(sound.title)
    }.padding(.top)
  }
}

struct Equalizer: View {
  @Binding var isPresented: Bool
  @ObservedObject var playState: PlayState

  let columns = [
      GridItem(.fixed(100)),
      GridItem(.flexible()),
  ]

  var body: some View {
    NavigationView {
      ZStack {
        Color.backgroundColor.edgesIgnoringSafeArea(.all)
        ScrollView {
          LazyVGrid(columns: columns) {
            ForEach(playState.sounds) { sound in
              VStack {
                if let icon = sound.icon {
                  Image(icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 44)
                }
                Text(sound.title)
                  .font(.body)
                  .lineLimit(sound.title.split(separator: " ").count > 1 ? 2 : 1)
                  .allowsTightening(true)
                  .minimumScaleFactor(0.75)
                  .foregroundColor(.white)
                  .padding(.horizontal)
                  .offset(y: -10)
                  .multilineTextAlignment(.center)
              }

              Slider(value: playState.volumeBinding(sound), in: 0...1)
            }
          }.padding()
        }
        .navigationBarTitle(Text("Equalizer"), displayMode: .inline)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button(action: {
              isPresented = false
            }) {
              Text("Done").bold()
            }
          }
        }
      }
    }
  }

}

struct Equalizer_Previews: PreviewProvider {
  static var previews: some View {
    Equalizer(isPresented: Binding(get: { true }, set: { _ in }), playState: PlayState()).preferredColorScheme(.dark)
  }
}
