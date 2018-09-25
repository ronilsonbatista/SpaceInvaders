//
//  GameOver.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 15/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import UIKit
import SpriteKit
import RealmSwift

class GameOver: SKScene {
    
    private var dataBase: Realm?
    private var score: RealmSwift.Results<ScoresModel>?
    private var scoreByOrder: [ScoresModel] = []
    
    var contentCreated = false
    
    override func didMove(to view: SKView) {
        if (!self.contentCreated) {
            self.createContent()
            self.dataBase = try! Realm()
            self.updateData()
            self.contentCreated = true
        }
    }
    
    private func updateData() {
        guard let dataBase = self.dataBase else {
            return
        }
        self.score = dataBase.objects(ScoresModel.self)
        self.sortedByOrder()
    }
    
    private func sortedByOrder() {
        
        let order =  self.score?.sorted(by: { $0.score > $1.score })
        self.scoreByOrder = order!
        
        for element in self.scoreByOrder {
            print("element \(element.score)")
        }
    }
    
    func createContent() {
        
        let gameOverLabel = SKLabelNode(fontNamed: "Courier")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.text = "Game Over!"
        gameOverLabel.position = CGPoint(x: self.size.width/2, y: 2.0 / 3.0 * self.size.height);
        
        self.addChild(gameOverLabel)
    
        let tapLabel = SKLabelNode(fontNamed: "Courier")
        tapLabel.fontSize = 25
        tapLabel.fontColor = SKColor.white
        tapLabel.text = "(Tap to Play Again)"
        tapLabel.position = CGPoint(x: self.size.width/2, y: gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 40);
        
        self.addChild(tapLabel)
        self.backgroundColor = SKColor.black
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
        let gameScene = GamePlay(size: self.size)
        gameScene.scaleMode = .aspectFill
        
        self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
    }
}
