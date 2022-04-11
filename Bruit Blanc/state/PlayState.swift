//
//  PlayState.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 10/04/2022.
//

import SwiftUI
import AVKit
import MediaPlayer

class PlayState: ObservableObject {
  private var players: [Sound: AVAudioPlayer] = [:]
  
  @Published private(set) var playing: [Sound: Bool] = [:]
  @Published private(set) var volume: [Sound: Float] = [:]

  var isPlaying: Bool? {
    players.isEmpty ? nil : !playing.filter { $0.value }.isEmpty
  }

  var sounds: [Sound] {
    players.map { $0.key }
  }

  func volumeBinding(_ sound: Sound) -> Binding<Float> {
    Binding(get: { self.volume[sound] ?? 1 }, set: {
      self.players[sound]?.volume = $0
      self.volume[sound] = $0
    })
  }

  func playAll() {
    players.forEach { player in
      player.value.play()
      playing[player.key] = true
    }
  }

  func stopAll() {
    players.forEach { player in
      player.value.stop()
      playing[player.key] = false
    }
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
      } catch {
      }
    }
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
