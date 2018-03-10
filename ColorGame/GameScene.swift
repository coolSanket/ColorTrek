//
//  GameScene.swift
//  ColorGame
//
//  Created by sanket kumar on 08/03/18.
//  Copyright © 2018 sanket kumar. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Enemies : Int {
    case small
    case medium
    case large
}

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    // MARK : Arrays
    var tracksArray : [SKSpriteNode]? = [SKSpriteNode]()
    let trackVelocities = [180,200,250]
    var directionArray  = [Bool]()
    var velocityArray   = [Int]()
    
    // MARK : Nodes
    var player     : SKSpriteNode?
    var targer     : SKSpriteNode?
    
     // MARK : - Label & Pause
    var timeLabel  : SKLabelNode?
    var scoreLabel : SKLabelNode?
    var pause      : SKSpriteNode?
    
    // MARK : Variables
    var currentTrack       = 0
    var movingToTrack      = false
    var remainingTime : TimeInterval = 60 {
        didSet {
            timeLabel?.text = "TIME: \(Int(self.remainingTime))"
        }
    }
    var currentScore : Int = 0  {
        didSet {
            scoreLabel?.text = "SCORE: \(self.currentScore)"
            GameHandler.sharedInstnace.score = currentScore
        }
    }
    
    
    
    // MARK : Sound
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    var backgroundNoise : SKAudioNode!
    
    
    
    // MARK : category of sprites
    let playerCategory  : UInt32 = 0x1 << 0 // 1
    let enemyCategory   : UInt32 = 0x1 << 1 // 2
    let targetCategory  : UInt32 = 0x1 << 2 // 4
    let powerUpCategory : UInt32 = 0x1 << 3 // 8
    
    
    // MARK : Entry point
    override func didMove(to view: SKView) {
        setupTracks()
        createLabel()
        launchGameTimer()
        createPlayer()
        createTarget()
        
        
        self.physicsWorld.contactDelegate = self
        
        if let musicURL = Bundle.main.url(forResource: "background", withExtension: "wav") {
            backgroundNoise = SKAudioNode(url: musicURL)
            self.addChild(backgroundNoise)
        }
        
        
        if let numberOfTracks = tracksArray?.count {
            for _ in 0...numberOfTracks {
                let randomNumberForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                velocityArray.append(trackVelocities[randomNumberForVelocity])
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
            }
        }
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
                self.spawnEnemies()
            },SKAction.wait(forDuration: 2)])))
        
    }
    
    // MARK : Create player
    func createPlayer() {
        
        player = SKSpriteNode(imageNamed: "player")
        player?.physicsBody = SKPhysicsBody(circleOfRadius: (player!.size.width) / 2)
        player?.physicsBody?.linearDamping = 0
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = 0
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory | powerUpCategory
        
        
        guard let playerPosition = tracksArray?.first?.position.x else {
            return
        }
        player?.position = CGPoint(x: playerPosition, y: self.size.height / 2)
        self.addChild(player!)
        
        let pulse = SKEmitterNode(fileNamed: "pulse")!
        player?.addChild(pulse)
        pulse.position = CGPoint(x: 0, y: 0)
    }
    
    // MARK : Create Target
    func createTarget() {
        targer = self.childNode(withName: "target") as? SKSpriteNode
        targer?.physicsBody = SKPhysicsBody(circleOfRadius: targer!.size.width / 2)
        targer?.physicsBody?.categoryBitMask = targetCategory
        targer?.physicsBody?.collisionBitMask = 0
    }
    
    // MARK : Create Enemy
    func createEnemy(type : Enemies , forTrack track : Int) -> SKShapeNode? {
        
        // Create a SKShapeNode()
        let enemyStrite = SKShapeNode()
        enemyStrite.name = "ENEMY"
    
        switch(type) {
            case .small:
                enemyStrite.path = CGPath(roundedRect: CGRect(x : -10 , y : 0 , width : 20 , height : 70), cornerWidth: 8, cornerHeight: 8, transform: nil)
                enemyStrite.fillColor = UIColor(red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1)
            
            case .medium:
                enemyStrite.path = CGPath(roundedRect: CGRect(x : -10 , y : 0 , width : 20 , height : 100), cornerWidth: 8, cornerHeight: 8, transform: nil)
                enemyStrite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
            case .large:
                enemyStrite.path = CGPath(roundedRect: CGRect(x : -10 , y : 0 , width : 20 , height : 130), cornerWidth: 8, cornerHeight: 8, transform: nil)
                enemyStrite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
        }
        
        // check track is available or not
        guard let enemyPosition = tracksArray?[track].position else {
            return nil
        }
        
        // get the direction
        let up = directionArray[track]
        
        // set the enemy position
        enemyStrite.position.x = enemyPosition.x
        enemyStrite.position.y = up ? -130 : self.size.height + 130
        
        // Add physics body property to detect collision or other stuff
        enemyStrite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemyStrite.path!)
        enemyStrite.physicsBody?.categoryBitMask = enemyCategory
        
        enemyStrite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return enemyStrite
    }
    
    
    func spawnEnemies() {
        
        var randomTrackNumber = 0
        let createPowerUp = GKRandomSource.sharedRandom().nextBool()
        
        if createPowerUp {
            randomTrackNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 6) + 1
            if let powerUPObject = self.createPowerUp(forTrack: randomTrackNumber) {
                self.addChild(powerUPObject)
            }
        }
    
        for i in 1...7 {
            if randomTrackNumber != i {
                let randomEnemyType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
                if let newEnemy = createEnemy(type: randomEnemyType, forTrack: i) {
                    self.addChild(newEnemy)
                }
            }
        }
        
        self.enumerateChildNodes(withName: "ENEMY"){(node: SKNode , nil) in
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        }
    }
    
    // MARK  : setup tracks
    func setupTracks() {
        for i in 0...8 {
            if let tracks = self.childNode(withName: "\(i)") as? SKSpriteNode {
                tracksArray?.append(tracks)
            }
        }
    }
    
    // MARK : Move vertically
    func moveVertically(up : Bool) {
        if up {
            let moveAction = SKAction.moveBy(x: 0, y: 10, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }else {
            let moveAction = SKAction.moveBy(x: 0, y: -10, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }
    }
    
    // MARK : Go to next track
    func moveToNextTrack() {
        player?.removeAllActions()
        movingToTrack = true
      
        
        guard let nextTrack = tracksArray?[currentTrack + 1].position else {
            return
        }
    
        
        if let player = self.player {
            let moveAction = SKAction.move(to: CGPoint(x : nextTrack.x, y : player.position.y), duration: 0.2)
            let up = directionArray[currentTrack + 1]
            
            player.run(moveAction, completion: {
                self.movingToTrack = false
                
                if self.currentTrack != 8 {
                    self.player?.physicsBody?.velocity = up ? CGVector(dx: 0, dy: self.velocityArray[self.currentTrack]) : CGVector(dx: 0, dy: -self.velocityArray[self.currentTrack])
                }
                else {
                    self.player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
                
                
                
            })
   
            currentTrack += 1
            self.run(moveSound)
        }
    }
    
    // MARK : Touch control
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch  = touches.first {
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if node?.name == "right" {
                if currentTrack < 8 {
                    moveToNextTrack()
                }
            }else if node?.name == "up" {
                moveVertically(up: true)
            }else if node?.name == "down" {
                moveVertically(up: false)
            }
            else if node?.name == "pause" , let scene = self.scene {
                if scene.isPaused  {
                    scene.isPaused = false
                }
                else  {
                    scene.isPaused = true
                }
            }
        }
    }
    
    // MARK : Touch ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    // MARK : Touch Cancel
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    
    // MARK : Handle Contact b/w body
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody : SKPhysicsBody
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            playerBody = contact.bodyA
            otherBody = contact.bodyB
        }
        else {
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory {
            movePlayerToStart()
            self.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: true))
        }
        else if (playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory) {
            nextLavel(playerPhysicsBody: playerBody)
        }
        else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == powerUpCategory {
            self.run(SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: true))
            otherBody.node?.removeFromParent()
            remainingTime += 5
        }
    }
    
    func nextLavel(playerPhysicsBody : SKPhysicsBody) {
        self.currentScore += 1
        self.run(SKAction.playSoundFileNamed("levelUp.wav", waitForCompletion: true))
        
        let emitter = SKEffectNode(fileNamed: "fireworks.sks")
        playerPhysicsBody.node?.addChild(emitter!)
        self.run(SKAction.wait(forDuration: 0.2)) {
            emitter?.removeFromParent()
            self.movePlayerToStart()
        }
        
    }
    
    
    func movePlayerToStart() {
        if let player = self.player {
            player.removeFromParent()
            self.player = nil
            self.createPlayer()
            self.currentTrack = 0
            // remainingTime = 60
        }
    }
    
    
    // MARK : - update
    override func update(_ currentTime: TimeInterval) {
        if let player = self.player {
            if player.position.y > self.size.height || player.position.y < 0 {
                movePlayerToStart()
            }
        }
        if remainingTime <= 5 {
            timeLabel?.fontColor = UIColor.red
        }
        if remainingTime == 0 {
            gameOver()
        }
        
    }
    
    
    // MARK : - Create Label
    func createLabel() {
        timeLabel = childNode(withName: "time") as? SKLabelNode
        scoreLabel = childNode(withName: "score") as? SKLabelNode
        pause = childNode(withName: "pause") as? SKSpriteNode
        remainingTime = 60
        currentScore = 0
    }
    
    
    func launchGameTimer() {
        let timeAction = SKAction.repeatForever(SKAction.sequence([SKAction.run({
            self.remainingTime -= 1
        }),SKAction.wait(forDuration: 1)]))
        self.timeLabel?.run(timeAction)
    }
    
    
    func createPowerUp(forTrack track : Int) -> SKSpriteNode? {
        
        let powerUpSprite = SKSpriteNode(imageNamed: "powerUp")
        powerUpSprite.name = "ENEMY"
        
        powerUpSprite.physicsBody = SKPhysicsBody(circleOfRadius: powerUpSprite.size.width / 2)
        powerUpSprite.physicsBody?.linearDamping = 0;
        powerUpSprite.physicsBody?.categoryBitMask = powerUpCategory
        powerUpSprite.physicsBody?.collisionBitMask = 0
        
        let up = directionArray[track]
        
        guard let powerUpXPosition = tracksArray?[track].position.x else {
            return nil
        }
        
        powerUpSprite.position.x = powerUpXPosition
        powerUpSprite.position.y = up ? -130 : self.size.height + 130
        powerUpSprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return powerUpSprite
    }
    
    
    func gameOver()  {
        
        GameHandler.sharedInstnace.saveGameStats()
        self.run(SKAction.playSoundFileNamed("levelCompleted.wav", waitForCompletion: true))
        let transition = SKTransition.fade(withDuration: 1)
        if let gameOverScene = SKScene(fileNamed: "GameOverScene") {
            gameOverScene.scaleMode = .aspectFit
            self.view?.presentScene(gameOverScene, transition: transition)
        }
        
    }
    
    
    
    
    
    
    
    
}
