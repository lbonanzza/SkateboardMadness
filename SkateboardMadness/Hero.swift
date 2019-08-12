//
//  Hero.swift
//  SkateboardMadness
//
//  Created by alekseykolesnik on 28/02/2019.
//  Copyright © 2019 User. All rights reserved.
//

import SpriteKit

class Hero: SKSpriteNode {

    var velocity = CGPoint.zero
    var minimumY: CGFloat = 0.0
    var jumpSpeed: CGFloat = 20.0
    var isOnGround = true
    
    func setupPhysicsBody() {
        
        if let skaterTexture = texture {
            
            physicsBody = SKPhysicsBody(texture: skaterTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            physicsBody?.allowsRotation = false
            physicsBody?.angularDamping = 0.5
            
            physicsBody?.categoryBitMask = PhysicsCategory.skater
            physicsBody?.collisionBitMask = PhysicsCategory.brick
            physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.gem
        }
    }
}
