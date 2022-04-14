//
//  PlayState.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 10/04/2022.
//

import SwiftUI
import AVKit
import MediaPlayer

class PlayState: NSObject, ObservableObject {
  private var players: [Sound: AVAudioPlayer] = [:]
  private var decrescendoPlayer = AVAudioPlayer()
  
  @Published private(set) var playing: [Sound: Bool] = [:]
  @Published private(set) var volume: [Sound: Float] = [:]
  @Published var masterVolume: Float = 1 {
    didSet {
      players.forEach { player in
        player.value.volume = (volume[player.key] ?? 1) * masterVolume
      }
    }
  }
  @Published private(set) var decrescendoDuration: TimeInterval?
  @Published private(set) var decrescendoStartTime: Date?
  @Published private(set) var decrescendoTimeLeft: TimeInterval?

  var isPlaying: Bool? {
    players.isEmpty ? nil : !playing.filter { $0.value }.isEmpty
  }

  var sounds: [Sound] {
    players.map { $0.key }
  }

  func volumeBinding(_ sound: Sound) -> Binding<Float> {
    Binding(get: { self.volume[sound] ?? 1 }, set: {
      self.players[sound]?.volume = $0 * self.masterVolume
      self.volume[sound] = $0
    })
  }

  func playAll() {
    players.forEach { player in
      player.value.play()
      playing[player.key] = true
    }
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
      try AVAudioSession.sharedInstance().setActive(true)

      UIApplication.shared.beginReceivingRemoteControlEvents()

      let commandCenter = MPRemoteCommandCenter.shared()
      commandCenter.playCommand.addTarget(handler: remotePlay)
      commandCenter.pauseCommand.addTarget(handler: remoteStop)
    } catch {
    }
  }

  func stopAll() {
    players.forEach { player in
      player.value.stop()
      playing[player.key] = false
    }
    stopDecrescendo()
  }

  func play(_ sound: Sound) {
    if players.isEmpty {
      do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio)
        try AVAudioSession.sharedInstance().setActive(true)

        UIApplication.shared.beginReceivingRemoteControlEvents()

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget(handler: remotePlay)
        commandCenter.pauseCommand.addTarget(handler: remoteStop)
      } catch {
      }
    }

    let url = URL(fileURLWithPath: sound.path)

    do {
      let audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer.numberOfLoops = -1
      audioPlayer.play()

      players[sound] = audioPlayer
      playing[sound] = true
      volume[sound] = 1

      updateNowPlaying()
    } catch {
    }
  }

  func stop(_ sound: Sound) {
    guard let audioPlayer = players[sound] else {
      return
    }
    audioPlayer.stop()
    players.removeValue(forKey: sound)
    volume.removeValue(forKey: sound)
    playing[sound] = false
    updateNowPlaying()

    if players.isEmpty {
      do {
        try AVAudioSession.sharedInstance().setActive(false)
        UIApplication.shared.endReceivingRemoteControlEvents()

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(remotePlay)
        commandCenter.pauseCommand.removeTarget(remoteStop)
        commandCenter.stopCommand.removeTarget(remoteStop)
      } catch {
      }
    }
  }

  func startDecrescendo(duration: TimeInterval) {
    decrescendoDuration = duration
    decrescendoStartTime = Date()
    decrescendoTimeLeft = duration

    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "silence.mp3", ofType: nil)!)

    do {
      decrescendoPlayer = try AVAudioPlayer(contentsOf: url)
      decrescendoPlayer.volume = 0
      decrescendoPlayer.play()

      decrescendoPlayer.delegate = self
    } catch {
    }
  }

  func stopDecrescendo() {
    decrescendoDuration = nil
    decrescendoStartTime = nil
    decrescendoTimeLeft = nil
  }

  private func updateNowPlaying() {
    var nowPlayingInfo = [String : Any]()
    nowPlayingInfo[MPMediaItemPropertyTitle] = playing.filter { $0.value }.map { $0.key.title }.joined(separator: " - ")
    nowPlayingInfo[MPMediaItemPropertyArtist] = "Bruit Blanc"

    if let image = Bundle.main.icon {
      nowPlayingInfo[MPMediaItemPropertyArtwork] =
        MPMediaItemArtwork(boundsSize: image.size) { size in
              return image
        }
    }

    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }

  private func remotePlay(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    playAll()
    return .success
  }

  private func remoteStop(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    stopAll()
    return .success
  }
}

extension PlayState: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    guard let decrescendoStartTime = decrescendoStartTime, let decrescendoDuration = decrescendoDuration else {
      return
    }

    let timeLeft = decrescendoStartTime.addingTimeInterval(decrescendoDuration).timeIntervalSince(Date())

    if timeLeft > 0 {
      decrescendoTimeLeft = timeLeft

      decrescendoPlayer.currentTime = 0
      decrescendoPlayer.play()

      let step = masterVolume / Float(timeLeft)
      masterVolume -= step
    } else {
      stopAll()
      // reset the volume at the end
      masterVolume = 1
    }
  }
}
