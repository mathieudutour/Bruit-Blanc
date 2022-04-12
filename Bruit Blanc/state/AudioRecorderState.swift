//
//  AudioRecorderState.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 11/04/2022.
//

import SwiftUI
import Combine
import AVFoundation

class AudioRecorderState: NSObject, ObservableObject {
  let objectWillChange = PassthroughSubject<AudioRecorderState, Never>()

  private var audioRecorder: AVAudioRecorder?
  private let documentDirectory = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Bruit Blanc")

  var recordings = [Sound]()
  @Published public var cantRecord: Bool = false

  var recording = false {
    didSet {
      objectWillChange.send(self)
    }
  }

  override init() {
    super.init()
    fetchRecordings()
  }

  func startRecording(uuid: UUID) {
    let recordingSession = AVAudioSession.sharedInstance()

    if recordingSession.recordPermission != .granted {
      recordingSession.requestRecordPermission { isGranted in
        if !isGranted {
          self.cantRecord = true
        } else {
          self.cantRecord = false
        }
      }
    } else {
      self.cantRecord = false
    }

    do {
      try recordingSession.setCategory(.playAndRecord, mode: .default)
      try recordingSession.setActive(true)

      let temporaryFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(uuid).m4a")

      let settings: [String:Any] = [
        AVFormatIDKey: Int(kAudioFormatAppleLossless),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
      ]

      audioRecorder = try AVAudioRecorder(url: temporaryFileURL, settings: settings)
      audioRecorder?.isMeteringEnabled = true
      audioRecorder?.record()
      recording = true
    } catch {
      print("Failed to set up recording session")
    }
  }

  func stopRecording() {
    audioRecorder?.stop()
    recording = false
  }

  func clearRecording(uuid: UUID) {
    let temporaryFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(uuid).m4a")
    do {
      try FileManager.default.removeItem(at: temporaryFileURL)
    } catch {
      print("Failed to clear the recording")
    }
  }

  func saveRecording(uuid: UUID, title: String) {
    let temporaryFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(uuid).m4a")
    do {
      try FileManager.default.createDirectory(at: documentDirectory, withIntermediateDirectories: true)
      try FileManager.default.moveItem(at: temporaryFileURL, to: documentDirectory.appendingPathComponent("\(uuid)---\(title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "No Title").m4a"))
    } catch {
      print("Failed to save recording session")
    }
    fetchRecordings()
  }

  func fetchRecordings() {
    recordings.removeAll()

    do {
      let directoryContents = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
      for audio in directoryContents {
        let recording = Sound(id: getId(for: audio), title: getTitle(for: audio), path: audio.path, icon: nil)
        recordings.append(recording)
      }
    } catch {
      print("Failed to fetch recording")
    }


    objectWillChange.send(self)
  }

  /// between 0 and 1
  func getLevel() -> Float {
    audioRecorder?.updateMeters()
    let power = audioRecorder?.averagePower(forChannel: 0) ?? -160
    return (power + 160) / 160
  }

  func deleteSound(_ sound: Sound) {
    do {
      try FileManager.default.removeItem(at: URL(fileURLWithPath: sound.path))
      fetchRecordings()
    } catch {
      print("Failed to clear the recording")
    }
  }

  func renameSound(_ sound: Sound, _ title: String) {
    do {
      try FileManager.default.moveItem(at: URL(fileURLWithPath: sound.path), to: documentDirectory.appendingPathComponent("\(sound.id)---\(title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "No Title").m4a"))
      fetchRecordings()
    } catch {
      print("Failed to clear the recording")
    }
  }

  private func getId(for file: URL) -> String {
    let name = file.deletingPathExtension().lastPathComponent.removingPercentEncoding

    if let parts = name?.components(separatedBy: "---"), parts.count >= 2 {
      return parts[0]
    }

    return UUID().uuidString
  }

  private func getTitle(for file: URL) -> String {
    let name = file.deletingPathExtension().lastPathComponent.removingPercentEncoding

    if let parts = name?.components(separatedBy: "---"), parts.count >= 2 {
      return parts[1]
    }

    return "No Title"
  }

  deinit {
    audioRecorder?.stop()
  }
}
