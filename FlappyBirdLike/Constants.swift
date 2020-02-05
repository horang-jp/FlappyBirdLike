//
//  Constants.swift
//  FlappyBirdLike
//
//  Created by 김호중 on 2019/08/13.
//  Copyright © 2019 hojung. All rights reserved.
//

import SpriteKit

struct Layer {
    static let sky: CGFloat = 1
    static let pipe: CGFloat = 2
    static let land: CGFloat = 3
    static let ceiling: CGFloat = 4
    static let bird: CGFloat = 5
    static let rain: CGFloat = 6
    static let tutorial: CGFloat = 9
    static let hud: CGFloat = 10
}

struct PhysicsCategory {
    static let bird: UInt32 = 0x1 << 0 // 1
    static let land: UInt32 = 0x1 << 1 // 2
    static let ceiling: UInt32 = 0x1 << 2 // 4
    static let pipe: UInt32 = 0x1 << 3 // 8
    static let score: UInt32 = 0x1 << 4 // 16
}

struct SoundFX {
    static let wing = SKAction.playSoundFileNamed("sfxWing", waitForCompletion: false)
    static let die = SKAction.playSoundFileNamed("sfxDie", waitForCompletion: false)
    static let hit = SKAction.playSoundFileNamed("sfxHit", waitForCompletion: false)
    static let point = SKAction.playSoundFileNamed("sfxPoint", waitForCompletion: false)
    static let swooshing = SKAction.playSoundFileNamed("sfxSwooshing", waitForCompletion: false)
}
