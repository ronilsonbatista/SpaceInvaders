//
//  GamePlay.swift
//  SpaceInvaders
//
//  Created by Ronilson Batista on 15/09/2018.
//  Copyright © 2018 Ronilson Batista. All rights reserved.
//

import SpriteKit
import CoreMotion
import RealmSwift

class GamePlay: SKScene, SKPhysicsContactDelegate {
    
    fileprivate let motionManager = CMMotionManager()
    fileprivate var contentCreated = false
    
    fileprivate var invaderMovementDirection: InvaderMovementDirection = .right
    fileprivate var timeOfLastMove: CFTimeInterval = 0.0
    fileprivate var timePerMove: CFTimeInterval = 1.0
    
    fileprivate var tapQueue = [Int]()
    fileprivate var contactQueue = [SKPhysicsContact]()
    
    fileprivate var score: Int = 0
    fileprivate var shipHealth: Float = 1.0
    
    fileprivate let kMinInvaderBottomHeight: Float = 32.0
    fileprivate var gameEnding: Bool = false
    
    fileprivate let invaderGridSpacing = CGSize(width: 12, height: 12)
    fileprivate let invaderRowCount = 6
    fileprivate let invaderColCount = 6

    fileprivate let kShipSize = CGSize(width: 30, height: 16)
    fileprivate let kSceneEdgeCategory: UInt32 = 0x1 << 3
    
    fileprivate var invaders = InsertInvaders()
    fileprivate var ship = InsertShip()
    fileprivate var bulletView = InsertBullet()
    
    fileprivate var dataManager = ScoresDataManager()
    
    override func didMove(to view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            motionManager.startAccelerometerUpdates()
            physicsWorld.contactDelegate = self
        }
    }
    
    func createContent() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        
        setupInvaders()
        setupShip()
        setupScore()

        self.backgroundColor = SKColor.black
    }
    
    func setupInvaders() {
        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)
        
        for row in 0..<invaderRowCount {
    
            var invaderType: InvaderType

            if row % 3 == 0 {
                invaderType = .invaderA
            } else if row % 3 == 1 {
                invaderType = .invaderB
            } else {
                invaderType = .invaderC
            }

            let invaderPositionY = CGFloat(row) * (InvaderType.size.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)

            for _ in 1..<invaderRowCount {
                let invader = self.invaders.makeInvader(ofType: invaderType)
                invader.position = invaderPosition
                addChild(invader)

                invaderPosition = CGPoint(
                    x: invaderPosition.x + InvaderType.size.width + invaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }
    
    func setupShip() {
        let ship = self.ship.makeShip()

        ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
        addChild(ship)
    }
    
    // Scene Update
    
    func moveInvaders(forUpdate currentTime: CFTimeInterval) {
        if (currentTime - timeOfLastMove < timePerMove) { return }
        
        self.determineInvaderMovementDirection()

        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .downThenLeft, .downThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .none:
                break
            }
            self.timeOfLastMove = currentTime
        }
    }
    
    func adjustInvaderMovement(to timePerMove: CFTimeInterval) {
        if self.timePerMove <= 0 {
            return
        }
        
        let ratio: CGFloat = CGFloat(self.timePerMove / timePerMove)
        self.timePerMove = timePerMove
        
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            node.speed = node.speed * ratio
        }
    }
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        if let ship = childNode(withName: AppNamesControl.shared.shipName) as? SKSpriteNode {
            if let data = motionManager.accelerometerData {
                if fabs(data.acceleration.x) > 0.2 {
                    ship.physicsBody!.applyForce(CGVector(dx: 40 * CGFloat(data.acceleration.x), dy: 0))
                }
            }
        }
    }
    
    func fireInvaderBullets(forUpdate currentTime: CFTimeInterval) {
        let existingBullet = childNode(withName: AppNamesControl.shared.invaderFiredBulletName)

        if existingBullet == nil {
            var allInvaders = [SKNode]()
            enumerateChildNodes(withName: InvaderType.name) { node, stop in
                allInvaders.append(node)
            }
            
            if allInvaders.count > 0 {
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                let invader = allInvaders[allInvadersIndex]
                let bullet = self.bulletView.makeBullet(ofType: .invaderFired)
                bullet.position = CGPoint(
                    x: invader.position.x,
                    y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
                )
                
                let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
                fireBullet(
                    bullet: bullet,
                    toDestination: bulletDestination,
                    withDuration: 2.0,
                    andSoundFileName: "InvaderBullet.wav"
                )
            }
        }
    }
    
    func processContacts(forUpdate currentTime: CFTimeInterval) {
        for contact in contactQueue {
            handle(contact)
            
            if let index = contactQueue.index(of: contact) {
                contactQueue.remove(at: index)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver() {
            endGame()
        }
        
        processUserMotion(forUpdate: currentTime)
        moveInvaders(forUpdate: currentTime)
        processUserTaps(forUpdate: currentTime)
        fireInvaderBullets(forUpdate: currentTime)
        processContacts(forUpdate: currentTime)
    }
    
    // Scene Update Helpers
    
    func processUserTaps(forUpdate currentTime: CFTimeInterval) {
        for tapCount in tapQueue {
            if tapCount == 1 {
                fireShipBullets()
            }
            tapQueue.remove(at: 0)
        }
    }
    
    // Invader Movement Helpers
    
    func determineInvaderMovementDirection() {
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
        
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                if (node.frame.maxX >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .downThenLeft
                    self.adjustInvaderMovement(to: self.timePerMove * 0.8)
                    stop.pointee = true
                }
            case .left:
                if (node.frame.minX <= 1.0) {
                    proposedMovementDirection = .downThenRight
                    self.adjustInvaderMovement(to: self.timePerMove * 0.8)
                    stop.pointee = true
                }
            case .downThenLeft:
                proposedMovementDirection = .left
                stop.pointee = true
            case .downThenRight:
                proposedMovementDirection = .right
                stop.pointee = true
            default:
                break
            }
        }
    
        if (proposedMovementDirection != invaderMovementDirection) {
            invaderMovementDirection = proposedMovementDirection
        }
    }
}

// Score
extension GamePlay {
    func setupScore() {
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = AppNamesControl.shared.scoreHudName
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.green
        scoreLabel.text = String(format: "Score: %04u", 0)
        scoreLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (40 + scoreLabel.frame.size.height/2)
        )
        addChild(scoreLabel)
        
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = AppNamesControl.shared.healthHudName
        healthLabel.fontSize = 25
        healthLabel.fontColor = SKColor.red
        healthLabel.text = String(format: "Health: %.1f%%", shipHealth * 100.0)
        healthLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (80 + healthLabel.frame.size.height/2)
        )
        addChild(healthLabel)
    }
    
    func adjustScore(by points: Int) {
        score += points
        if let score = childNode(withName: AppNamesControl.shared.scoreHudName) as? SKLabelNode {
            score.text = String(format: "Score: %04u", self.score)
        }
    }
    
    func adjustShipHealth(by healthAdjustment: Float) {
        shipHealth = max(shipHealth + healthAdjustment, 0)
        if let health = childNode(withName: AppNamesControl.shared.healthHudName) as? SKLabelNode {
            health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        }
    }
}

//Bullet
extension GamePlay {
    func fireBullet(bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
        let bulletAction = SKAction.sequence([
            SKAction.move(to: destination, duration: duration),
            SKAction.wait(forDuration: 3.0 / 60.0),
            SKAction.removeFromParent()
            ])
        
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        bullet.run(SKAction.group([bulletAction, soundAction]))
        addChild(bullet)
    }
    
    func fireShipBullets() {
        let existingBullet = childNode(withName: AppNamesControl.shared.shipFiredBulletName)
        
        if existingBullet == nil {
            if let ship = childNode(withName: AppNamesControl.shared.shipName) {
                let bullet = self.bulletView.makeBullet(ofType: .shipFired)
                bullet.position = CGPoint(
                    x: ship.position.x,
                    y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
                )
                let bulletDestination = CGPoint(
                    x: ship.position.x,
                    y: frame.size.height + bullet.frame.size.height / 2
                )
                fireBullet(
                    bullet: bullet,
                    toDestination: bulletDestination,
                    withDuration: 1.0,
                    andSoundFileName: "ShipBullet.wav"
                )
            }
        }
    }
}

//touch in device
extension GamePlay {
    func handle(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil { return }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        if nodeNames.contains(AppNamesControl.shared.shipName) && nodeNames.contains(AppNamesControl.shared.invaderFiredBulletName) {
            run(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
            
            adjustShipHealth(by: -0.334)
            if shipHealth <= 0.0 {
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
            } else {
                if let ship = childNode(withName: AppNamesControl.shared.shipName) {
                    ship.alpha = CGFloat(shipHealth)
                    
                    if contact.bodyA.node == ship {
                        contact.bodyB.node!.removeFromParent()
                        
                    } else {
                        contact.bodyA.node!.removeFromParent()
                    }
                }
            }
            
        } else if nodeNames.contains(InvaderType.name) && nodeNames.contains(AppNamesControl.shared.shipFiredBulletName) {
            run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            adjustScore(by: 100)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if (touch.tapCount == 1) {
                tapQueue.append(1)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        contactQueue.append(contact)
    }
}

// Game Over
extension GamePlay {
    func isGameOver() -> Bool {
        let invader = childNode(withName: InvaderType.name)
        var invaderTooLow = false
        
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            if (Float(node.frame.minY) <= self.kMinInvaderBottomHeight)   {
                invaderTooLow = true
                stop.pointee = true
            }
        }
        
        let ship = childNode(withName: AppNamesControl.shared.shipName)
        return invader == nil || invaderTooLow || ship == nil
    }
    
    func endGame() {
        if !gameEnding {
//            print("socre \(self.score)")
            gameEnding = true
            motionManager.stopAccelerometerUpdates()
            self.addScore()
            let gameOverScene: GameOver = GameOver(size: size)
            view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
    }
    
    func addScore() {
        self.dataManager.saveScores(score: self.score)
    }
}
