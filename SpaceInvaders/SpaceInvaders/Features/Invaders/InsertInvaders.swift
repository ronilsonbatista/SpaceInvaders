//
//  InsertInvaders.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 16/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import SpriteKit
import CoreMotion

class InsertInvaders: SKScene {
    
    let invaderCategory: UInt32 = 0x1 << 0
    var timePerMove: CFTimeInterval = 1.0

    func makeInvader(ofType invaderType: InvaderType) -> SKNode {
        let invaderTextures = loadInvaderTextures(ofType: invaderType)
        
        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = InvaderType.name
        
        invader.run(SKAction.repeatForever(SKAction.animate(with: invaderTextures, timePerFrame: timePerMove)))
        
        invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
        invader.physicsBody!.isDynamic = false
        invader.physicsBody!.categoryBitMask = invaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0
        
        return invader
    }
    
    func loadInvaderTextures(ofType invaderType: InvaderType) -> [SKTexture] {
        var prefix: String
        
        switch(invaderType) {
        case .invaderA:
            prefix = "InvaderA"
        case .invaderB:
            prefix = "InvaderB"
        case .invaderC:
            prefix = "InvaderC"
        }
        
        return [SKTexture(imageNamed: String(format: "%@_00.png", prefix)),
                SKTexture(imageNamed: String(format: "%@_01.png", prefix))]
    }
}
