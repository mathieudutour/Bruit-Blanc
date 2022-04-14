//
//  ContentView.swift
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

struct BuiltInSoundView: View {
  let isPlaying: Bool
  let sound: Sound

  var onStart: (Sound) -> Void
  var onStop: (Sound) -> Void

  var body: some View {
    Button(action: {
      if self.isPlaying {
        self.onStop(self.sound)
      } else {
        self.onStart(self.sound)
      }
    }) {
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .foregroundColor(isPlaying ? .playingColor : .pausedColor)
        VStack(spacing: 0) {
          Spacer()
          if let icon = sound.icon {
            Image(icon)
              .resizable()
              .scaledToFit()
              .foregroundColor(self.isPlaying ? .black : .white)
          }
          Text(sound.title)
            .font(.subheadline)
            .lineLimit(sound.title.split(separator: " ").count > 1 ? 2 : 1)
            .allowsTightening(true)
            .minimumScaleFactor(0.75)
            .foregroundColor(isPlaying ? .black : .white)
            .padding(.horizontal)
            .multilineTextAlignment(.center)
          Spacer()
        }
      }
    }
  }
}

struct RecordedSoundView: View {
  let isPlaying: Bool
  let sound: Sound

  var onStart: (Sound) -> Void
  var onStop: (Sound) -> Void
  var onDelete: (Sound) -> Void
  var onRename: (Sound, String) -> Void

  @State private var showingOptions = false

  var body: some View {
    Button(action: {}) {
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .foregroundColor(isPlaying ? .playingColor : .pausedColor)
        VStack(spacing: 0) {
          Spacer()
          Text(sound.title)
            .font(.subheadline)
            .lineLimit(sound.title.split(separator: " ").count > 1 ? 2 : 1)
            .allowsTightening(true)
            .minimumScaleFactor(0.75)
            .foregroundColor(isPlaying ? .black : .white)
            .padding(.horizontal)
            .multilineTextAlignment(.center)
          Spacer()
        }
      }
      .simultaneousGesture(
        LongPressGesture().onEnded { _ in
          showingOptions = true
        }
      )
      .highPriorityGesture(TapGesture().onEnded { _ in
        if isPlaying {
          onStop(sound)
        } else {
          onStart(sound)
        }
      })
      .actionSheet(isPresented: $showingOptions) {
        ActionSheet(
          title: Text("\"\(sound.title)\" Recording"),
          buttons: [
            .cancel(),

            .default(Text("Share")) {
              let activityController = UIActivityViewController(activityItems: [URL(fileURLWithPath: sound.path)], applicationActivities: nil)

              UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
            },

            .default(Text("Rename")) {
              TextAlert().show(
                title: "Rename \"\(sound.title)\" Recording",
                message: "Pick a new title for the recording.",
                ok: "Rename"
              ) { result in
                if let text = result {
                  onRename(sound, text)
                }
              }
            },

            .destructive(Text("Delete")) {
              onDelete(sound)
            },
          ]
        )
      }
    }
  }
}

struct ContentView: View {
  let height: CGFloat = 100
  let columns = [
    GridItem(.adaptive(minimum: 100))
  ]

  @ObservedObject var playState = PlayState()
  @ObservedObject var audioRecorder = AudioRecorderState()
  @State private var showingEqualizer = false
  @State private var showingRecorder = false

  var body: some View {
    ZStack {
      Color.backgroundColor.edgesIgnoringSafeArea(.all)
      ScrollView {
        HStack {
          Text("Noises")
            .font(.subheadline)
            .foregroundColor(.init(white: 0.7))
            .padding(.leading)
          Spacer()
        }.padding(.top)

        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(NOISES) { sound in
            BuiltInSoundView(
              isPlaying: playState.playing[sound] ?? false,
              sound: sound,
              onStart: playState.play,
              onStop: playState.stop)
              .frame(height: height)
          }
        }.padding(.horizontal)

        HStack {
          Text("Sounds")
            .font(.subheadline)
            .foregroundColor(.init(white: 0.7))
            .padding(.leading)
          Spacer()
        }.padding(.top)

        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(SOUNDS) { sound in
            BuiltInSoundView(
              isPlaying: playState.playing[sound] ?? false,
              sound: sound,
              onStart: playState.play,
              onStop: playState.stop)
              .frame(height: height)
          }
        }.padding(.horizontal)

        HStack {
          Text("Recording")
            .font(.subheadline)
            .foregroundColor(.init(white: 0.7))
            .padding(.leading)
          Spacer()
        }.padding(.top)

        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(audioRecorder.recordings) { sound in
            RecordedSoundView(
              isPlaying: playState.playing[sound] ?? false,
              sound: sound,
              onStart: playState.play,
              onStop: playState.stop,
              onDelete: audioRecorder.deleteSound,
              onRename: audioRecorder.renameSound)
              .frame(height: height)
          }
          Button(action: {
            playState.stopAll()
            showingRecorder = true
          }) {
            ZStack {
              RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.pausedColor)
              VStack(spacing: 0) {
                Spacer()
                Image(systemName: "plus")
                  .resizable()
                  .scaledToFit()
                  .foregroundColor(.white)
                  .padding()
                Spacer()
                Text("New")
                  .font(.subheadline)
                  .allowsTightening(true)
                  .minimumScaleFactor(0.75)
                  .foregroundColor(.white)
                  .padding(.horizontal)
                  .multilineTextAlignment(.center)
                Spacer()
              }
            }
          }
          .frame(height: height)
          .sheet(isPresented: $showingRecorder) {
            Recorder(isPresented: $showingRecorder, audioRecorder: audioRecorder)
          }
        }
        .padding(.horizontal)
        .padding(.bottom, 100)
      }

      if let isPlaying = playState.isPlaying {
        VStack {
          Spacer()
          HStack {
            Spacer()

            Button(action: {
              if isPlaying {
                playState.stopAll()
              } else {
                playState.playAll()
              }
            }) {
              ZStack {
                RoundedRectangle(cornerRadius: 44)
                  .foregroundColor(.pausedColor)
                Label("Audio Control", systemImage: isPlaying ? "pause.fill" : "play.fill")
                  .labelStyle(.iconOnly)
                  .imageScale(.large)
              }
            }
            .padding()
            .offset(x: 44)
            .frame(width: 88, height: 88, alignment: .center)
            .shadow(radius: 10)

            Spacer()

            Button(action: {
              showingEqualizer.toggle()
            }) {
              ZStack {
                RoundedRectangle(cornerRadius: 44)
                  .foregroundColor(.pausedColor)
                Label("Equalizer", systemImage: "slider.horizontal.3")
                  .labelStyle(.iconOnly)
                  .imageScale(.large)
                if let decrescendoTimeLeft = playState.decrescendoTimeLeft {
                  HStack {
                    Spacer()
                    ZStack {
                      RoundedRectangle(cornerRadius: 11)
                        .foregroundColor(.accentColor)
                      HStack {
                        Text("\(formatter.string(from: decrescendoTimeLeft) ?? "")")
                          .foregroundColor(.backgroundColor)
                          .font(.system(size: 10, design: .monospaced))
                          .lineLimit(1)
                          .padding(.all, 0)
                      }
                    }
                  }
                  .frame(height: 22)
                  .offset(x: 6, y: -30)
                }
              }
            }
            .padding()
            .frame(width: 88, height: 88, alignment: .trailing)
            .shadow(radius: 10)
            .sheet(isPresented: $showingEqualizer) {
              Equalizer(isPresented: $showingEqualizer, playState: playState)
            }
          }
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().preferredColorScheme(.dark)
  }
}
