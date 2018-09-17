//
//  Bullet.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 17/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import SpriteKit
import CoreMotion

class Bullet: SKScene {
    
    let kBulletSize = CGSize(width:4, height: 8)
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipCategory: UInt32 = 0x1 << 2
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    func makeBullet(ofType bulletType: BulletType) -> SKNode {
        var bullet: SKNode
        
        switch bulletType {
        case .shipFired:
            bullet = SKSpriteNode(color: SKColor.green, size: kBulletSize)
            bullet.name = AppNamesControl.shared.kShipFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kInvaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        case .invaderFired:
            bullet = SKSpriteNode(color: SKColor.magenta, size: kBulletSize)
            bullet.name = AppNamesControl.shared.kInvaderFiredBulletName
            
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody!.isDynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kShipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
            break
        }
        
        return bullet
    }
}
