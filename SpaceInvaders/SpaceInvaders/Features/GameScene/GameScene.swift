//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 15/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
   var contentCreated = false
    
    override func didMove(to view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
        }
    }
    
    func createContent() {
        let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
        invader.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(invader)
        self.backgroundColor = SKColor.black
    }
    
    // Scene Update
    override func update(_ currentTime: TimeInterval) {
    }
}
