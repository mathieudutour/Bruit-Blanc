//
//  Recorder.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 11/04/2022.
//

import SwiftUI
import AVKit
import MediaPlayer
import Combine

struct Recorder: View {
  @Binding var isPresented: Bool
  @ObservedObject var audioRecorder: AudioRecorderState

  let columns = [
      GridItem(.fixed(100)),
      GridItem(.flexible()),
  ]

  @State private var uuid: UUID = UUID()
  @State private var didRecord: Bool = false
  @State private var title: String = ""

  @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common)
  @State private var connectedTimer: Cancellable? = nil

  @State private var level: CGFloat = 88
  @State private var maxWidth = UIScreen.main.bounds.width / 2.2

  var body: some View {
    NavigationView {
      ZStack {
        Color.backgroundColor.edgesIgnoringSafeArea(.all)
        VStack {
          Text("Record a custom sound to add to the existing noises and sounds")
            .font(.subheadline)
            .foregroundColor(.init(white: 0.7))
            .padding()

          HStack {
            Text("Title")
            TextField("My Shhhh", text: $title)
          }.padding()

          Spacer()

          ZStack {
            ZStack {
              Circle()
                .fill(Color.accentColor.opacity(0.05))

              Circle()
                .fill(Color.accentColor.opacity(0.08))
                .frame(width: level / 2, height: level / 2)
            }.frame(width: level, height: level)

            Button(action: {
              if audioRecorder.recording {
                audioRecorder.stopRecording()
                connectedTimer?.cancel()
              } else {
                audioRecorder.startRecording(uuid: uuid)
                connectedTimer = timer.connect()
                didRecord = true
              }
            }) {
              ZStack {
                RoundedRectangle(cornerRadius: 88)
                  .foregroundColor(.pausedColor)
                Label("Record", systemImage: audioRecorder.recording ? "stop.fill" : "circle.fill")
                  .labelStyle(.iconOnly)
                  .imageScale(.large)
                  .foregroundColor(.red)
              }.frame(width: 88, height: 88)
            }
          }
          .frame(width: maxWidth, height: maxWidth)
          .padding(.bottom, 40)
          .onReceive(timer) { _ in
            let value = self.audioRecorder.getLevel()
            let animated = CGFloat(value) * ((UIScreen.main.bounds.width / 2.2) / 88)

            withAnimation(Animation.linear(duration: 0.01)) {
              self.level = animated + 88
            }
          }
        }
      }.navigationBarTitle(Text("Recorder"), displayMode: .inline)
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
            audioRecorder.saveRecording(uuid: uuid, title: title)
            isPresented = false
          }) {
            Text("Save").bold()
          }.disabled(!didRecord || audioRecorder.recording || title.isEmpty)
        }
      }
      .onAppear() {
        uuid = UUID()
      }.onDisappear() {
        audioRecorder.clearRecording(uuid: uuid)
      }
    }
  }
}

struct Recorder_Previews: PreviewProvider {
  static var previews: some View {
    Recorder(isPresented: Binding(get: { true }, set: { _ in }), audioRecorder: AudioRecorderState()).preferredColorScheme(.dark)
  }
}

