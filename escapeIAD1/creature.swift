//
//  creature.swift
//  escapeIAD1
//
//  Created by FRANCISCO MARTINEZ on 7/17/15.
//  Copyright (c) 2015 FRANCISCO MARTINEZ. All rights reserved.
//

import SpriteKit

class Creature {
    var speed:Float = 0.0
    var alien:SKSpriteNode
    var currentFrame = 0
    var randomFrame = 0
    var moving = false
    var angle = 0.0
    var range = 2.0
    var xPos = CGFloat()
    
    init(speed:Float, alien:SKSpriteNode){
        self.speed = speed
        self.alien = alien
        self.setRandomFrame()
    }
    
    func setRandomFrame() {
        var range = UInt32(50)..<UInt32(200)
        self.randomFrame = Int(range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1))
    }
}