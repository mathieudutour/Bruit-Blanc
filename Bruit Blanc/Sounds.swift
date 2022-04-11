//
//  Sounds.swift
//  Bruit Blanc
//
//  Created by Mathieu Dutour on 08/04/2022.
//

import Foundation

struct Sound: Identifiable, Hashable {
  let id: String
  let title: String
  let path: String
  let icon: String?
}

let NOISES = [
  Sound(id: UUID().uuidString, title: "White Noise", path: Bundle.main.path(forResource: "white.wav", ofType: nil)!, icon: "white"),
  Sound(id: UUID().uuidString, title: "Pink Noise", path: Bundle.main.path(forResource: "pink.wav", ofType: nil)!, icon: "pink"),
  Sound(id: UUID().uuidString, title: "Brown Noise", path: Bundle.main.path(forResource: "brownian.wav", ofType: nil)!, icon: "brown"),
]

let SOUNDS = [
  Sound(id: UUID().uuidString, title: "Rain", path: Bundle.main.path(forResource: "rain.m4a", ofType: nil)!, icon: "rain"),
  Sound(id: UUID().uuidString, title: "Stream", path: Bundle.main.path(forResource: "stream.wav", ofType: nil)!, icon: "stream"),
  Sound(id: UUID().uuidString, title: "Forest", path: Bundle.main.path(forResource: "forest.wav", ofType: nil)!, icon: "forest"),
  Sound(id: UUID().uuidString, title: "Waves", path: Bundle.main.path(forResource: "waves.m4a", ofType: nil)!, icon: "waves"),
  Sound(id: UUID().uuidString, title: "Birds", path: Bundle.main.path(forResource: "birds.m4a", ofType: nil)!, icon: "birds"),
  Sound(id: UUID().uuidString, title: "Ducks", path: Bundle.main.path(forResource: "ducks.wav", ofType: nil)!, icon: "ducks"),
  Sound(id: UUID().uuidString, title: "Crickets", path: Bundle.main.path(forResource: "crickets.m4a", ofType: nil)!, icon: "crickets"),
  Sound(id: UUID().uuidString, title: "Car Engine", path: Bundle.main.path(forResource: "car-engine.m4a", ofType: nil)!, icon: "car engine"),
  Sound(id: UUID().uuidString, title: "Fire", path: Bundle.main.path(forResource: "fire.m4a", ofType: nil)!, icon: "fire"),
  Sound(id: UUID().uuidString, title: "Vacuum", path: Bundle.main.path(forResource: "vacuum-cleaner.m4a", ofType: nil)!, icon: "vacuum cleaner"),
  Sound(id: UUID().uuidString, title: "Faucet", path: Bundle.main.path(forResource: "water-faucet.m4a", ofType: nil)!, icon: "water faucet"),
]
