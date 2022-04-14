//
//  Equalizer.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 08/04/2022.
//

import SwiftUI
import AVKit
import MediaPlayer

private var formatter: DateComponentsFormatter {
  let formatter = DateComponentsFormatter()
  formatter.allowedUnits = [.hour, .minute, .second]
  return formatter
}

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
  @State private var showingDecrescendo = false

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
            Text("Master Volume")
              .font(.body)
              .lineLimit(2)
              .allowsTightening(true)
              .minimumScaleFactor(0.75)
              .foregroundColor(.white)
              .padding(.horizontal)
              .multilineTextAlignment(.center)
            Slider(value: $playState.masterVolume, in: 0...1)
          }.padding()

          Divider()

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
          }
          .padding()
          .padding(.bottom, 100)
        }

        VStack {
          Spacer()
          HStack {
            Spacer()

            Button(action: {
              if playState.decrescendoTimeLeft != nil {
                playState.stopDecrescendo()
              } else {
                showingDecrescendo.toggle()
              }
            }) {
              ZStack {
                RoundedRectangle(cornerRadius: 44)
                  .foregroundColor(.pausedColor)
                if let decrescendoTimeLeft = playState.decrescendoTimeLeft {
                  HStack {
                    Text("\(formatter.string(from: decrescendoTimeLeft) ?? "")")
                      .font(Font.system(size:16, design: .monospaced))
                      .lineLimit(1)
                      .padding(.all, 0)
                    Image(systemName: "stop.fill")
                  }.padding(.all, 12)
                } else {
                  HStack {
                    Image(systemName: "arrow.down.right")
                    Text("Decrescendo").font(Font.system(size:16).italic())
                  }.padding(.all, 12)
                }
              }
            }
            .padding()
            .frame(width: (playState.decrescendoTimeLeft != nil ? (formatter.string(from: playState.decrescendoTimeLeft ?? TimeInterval(0)) ?? "") + "000": "Decrescendo").sizeUsingFont(usingFont: UIFont.systemFont(ofSize: 16)).width + 88, height: 88)
            .shadow(radius: 10)
            .sheet(isPresented: $showingDecrescendo) {
              Decrescendo(isPresented: $showingDecrescendo, playState: playState)
            }
          }
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
    StatefulPreview(true) {
      Equalizer(isPresented: $0, playState: PlayState()).preferredColorScheme(.dark)
    }
  }
}
