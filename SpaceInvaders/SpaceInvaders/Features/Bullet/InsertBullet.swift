//
//  InsertBullet.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 17/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import SpriteKit
import CoreMotion

class InsertBullet: SKScene {
    
    let bulletSize = CGSize(width:4, height: 8)
    let shipFiredBulletCategory: UInt32 = 0x1 << 1
    let invaderCategory: UInt32 = 0x1 << 0
    let shipCategory: UInt32 = 0x1 << 2
    let invaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    func makeBullet(ofType bulletType: BulletType) -> SKNode {
        var bullet: SKNode
        
        switch bulletType {
        case .shipFired:
            bullet = SKSpriteNode(color: SKColor.green, size: bulletSize)
            bullet.name = AppNamesControl.shared.shipFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = shipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = invaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        case .invaderFired:
            bullet = SKSpriteNode(color: SKColor.magenta, size: bulletSize)
            bullet.name = AppNamesControl.shared.invaderFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = invaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = shipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            break
        }
        
        return bullet
    }
}
