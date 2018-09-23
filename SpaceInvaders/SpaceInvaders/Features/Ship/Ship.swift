//
//  Ship.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 16/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import SpriteKit
import CoreMotion

class Ship: SKScene {
    
    let shipCategory: UInt32 = 0x1 << 2
    let sceneEdgeCategory: UInt32 = 0x1 << 3
    
    func makeShip() -> SKNode {
        let ship = SKSpriteNode(imageNamed: "Ship.png")
        ship.name = AppNamesControl.shared.shipName
        
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.02
        
        ship.physicsBody!.categoryBitMask = shipCategory
        ship.physicsBody!.contactTestBitMask = 0x0
        ship.physicsBody!.collisionBitMask = sceneEdgeCategory
        
        return ship
    }
}
