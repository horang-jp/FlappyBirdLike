//
//  GameScene.swift
//  FlappyBirdLike
//
//  Created by 김호중 on 2019/08/12.
//  Copyright © 2019 hojung. All rights reserved.
//

import SpriteKit
import GameKit

enum GameState {
    case ready
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background = SKSpriteNode()
   
    private var tutorial = SKSpriteNode()
    private var bgmPlayer = SKAudioNode()
    private var cameraNode = SKCameraNode()
    private var bird = SKSpriteNode()
    private var gameState = GameState.ready
    
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    private var scoreLabel = SKLabelNode()

    // MARK: - Sprite Alignment
    override func didMove(to view: SKView) {
        var bgColor = SKColor()
        
        if background.name == "background1" {
            bgColor = SKColor(red: 81.0 / 255.0, green: 192.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
        } else {
            bgColor = SKColor(red: 0.0 / 255.0, green: 135.0 / 255.0, blue: 147.0 / 255.0, alpha: 1.0)
        }
        
        self.backgroundColor = bgColor
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -6.4)
        
        creatBird()
        creatEnvironment()
        createScore()
        createTutorial()
        
        if arc4random() % 2 == 0 {
            createRain()
        } else {
            
        }
        
        // BGM 모듈
        bgmPlayer = SKAudioNode(fileNamed: "bgm.mp3")
        bgmPlayer.autoplayLooped = true
//        self.addChild(bgmPlayer)
        
        // 카메라 추가
        camera = cameraNode
        cameraNode.position.x = self.size.width / 2
        cameraNode.position.y = self.size.height / 2
        self.addChild(cameraNode)
        
        // physics' outline
        self.view?.showsPhysics = false
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Minercraftory")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height - 60)
        scoreLabel.zPosition = Layer.hud
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.text = "\(score)"
        
        self.addChild(scoreLabel)
    }
    
    func creatBird() {
//        let birdTexture = SKTextureAtlas(named: "Bird")
        
        bird = SKSpriteNode(imageNamed: "bird1")
        bird.position = CGPoint(x: self.size.width / 3, y: self.size.height / 2)
        bird.zPosition = Layer.bird
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.land | PhysicsCategory.pipe | PhysicsCategory.ceiling | PhysicsCategory.score
        bird.physicsBody?.collisionBitMask = PhysicsCategory.land | PhysicsCategory.pipe | PhysicsCategory.ceiling
        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.isDynamic = false
        
        self.addChild(bird)
        
        // Part Animation
//        var aniArray = [SKTexture]()
//        for i in 1...birdTexture.textureNames.count {
//            aniArray.append(SKTexture(imageNamed: "bird\(i)"))
//        }
//        let flyingAnimation = SKAction.animate(with: aniArray, timePerFrame: 0.1)
//        bird.run(SKAction.repeatForever(flyingAnimation))
        
        guard let flyingBySKS = SKAction(named: "flying") else { return }
        bird.run(flyingBySKS)
        
        // thruster 효과 추가
        guard let thruster = SKEmitterNode(fileNamed: "thruster") else { return }
        thruster.position = CGPoint.zero
        thruster.position.x -= bird.size.width / 2
        thruster.zPosition = -0.1
        
        // add 블랜딩 문제를 SKEffectNode로 해결
        let thrusterEffectNode = SKEffectNode()
        thrusterEffectNode.addChild(thruster)
        bird.addChild(thrusterEffectNode)
        
    }
    
    func creatEnvironment() {
        let envAtlas = SKTextureAtlas(named: "Environment")
        let landTexture = envAtlas.textureNamed("land")
        let landRepeatNum = Int(ceil(self.size.width / landTexture.size().width))
//        let skyTexture = envAtlas.textureNamed("sky")
        guard let skyTexture = self.background.texture else { return }
        let skyRepeatNum = Int(ceil(self.size.width / skyTexture.size().width))
        let ceilTexture = envAtlas.textureNamed("ceiling")
        let ceilRepeatNum = Int(ceil(self.size.width / ceilTexture.size().width))
        
        for i in 0...landRepeatNum {
            let land = SKSpriteNode(texture: landTexture)
            land.anchorPoint = CGPoint.zero
            land.position = CGPoint(x: CGFloat(i) * land.size.width, y: 0)
            land.zPosition = Layer.land
            
            land.physicsBody = SKPhysicsBody(rectangleOf: land.size, center: CGPoint(x: land.size.width / 2, y: land.size.height / 2))
            land.physicsBody?.categoryBitMask = PhysicsCategory.land
            land.physicsBody?.affectedByGravity = false
            land.physicsBody?.isDynamic = false
            
            self.addChild(land)
            
            let moveLeft = SKAction.moveBy(x: -landTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: landTexture.size().width, y: 0, duration: 0)
            let moveSequence = SKAction.sequence([moveLeft, moveReset])
            land.run(SKAction.repeatForever(moveSequence))
        }
        
        for i in 0...skyRepeatNum {
            let sky = SKSpriteNode(texture: skyTexture)
            sky.anchorPoint = CGPoint.zero
//            sky.position = CGPoint(x: CGFloat(i) * sky.size.width, y: envAtlas.textureNamed("land").size().height)
            sky.position = CGPoint(x: CGFloat(i) * sky.size.width, y: 0)
            sky.zPosition = Layer.sky
            self.addChild(sky)
            
            let moveLeft = SKAction.moveBy(x: -skyTexture.size().width, y: 0, duration: 40)
            let moveReset = SKAction.moveBy(x: skyTexture.size().width, y: 0, duration: 0)
            let moveSequence = SKAction.sequence([moveLeft, moveReset])
            sky.run(SKAction.repeatForever(moveSequence))
        }
        
        for i in 0...ceilRepeatNum {
            let ceiling = SKSpriteNode(texture: ceilTexture)
            ceiling.anchorPoint = CGPoint.zero
            ceiling.position = CGPoint(x: CGFloat(i) * ceiling.size.width, y: self.size.height - ceiling.size.height / 2)
            ceiling.zPosition = Layer.ceiling
            
            ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size, center: CGPoint(x: ceiling.size.width / 2, y: ceiling.size.height / 2))
            ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ceiling
            ceiling.physicsBody?.affectedByGravity = false
            ceiling.physicsBody?.isDynamic = false
            
            self.addChild(ceiling)
            
            let moveLeft = SKAction.moveBy(x: -ceilTexture.size().width, y: 0, duration: 3)
            let moveReset = SKAction.moveBy(x: ceilTexture.size().width, y: 0, duration: 0)
            let moveSequence = SKAction.sequence([moveLeft, moveReset])
            ceiling.run(SKAction.repeatForever(moveSequence))
        }
        
//        let land = SKSpriteNode(imageNamed: "land")
//        land.position = CGPoint(x: self.size.width / 2, y: 50)
//        land.zPosition = 3
//        self.addChild(land)
        
//        let sky = SKSpriteNode(imageNamed: "sky")
//        sky.position = CGPoint(x: self.size.width / 2, y: 100)
//        sky.zPosition = 1
//        self.addChild(sky)
//
//        let ceiling = SKSpriteNode(imageNamed: "ceiling")
//        ceiling.position = CGPoint(x: self.size.width / 2, y: self.size.height)
//        ceiling.zPosition = 3
//        self.addChild(ceiling)
        
    }
    
    func setUpPipe(pipeDistance: CGFloat) {
        // 스프라이트 생성
        let envAtlas = SKTextureAtlas(named: "Environment")
        let pipeTexture = envAtlas.textureNamed("pipe")
        
        let pipeDown = SKSpriteNode(texture: pipeTexture)
        pipeDown.zPosition = Layer.pipe
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipeDown.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipeDown.physicsBody?.isDynamic = false
        
        let pipeUp = SKSpriteNode(texture: pipeTexture)
        // 좌우반전
        pipeUp.xScale = -1
        // 상하반전
        pipeUp.zRotation = .pi
        pipeUp.zPosition = Layer.pipe
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipeUp.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipeUp.physicsBody?.isDynamic = false
        
        // 파이프와 파이프 사이를 새가 지나갔을 때 점수가 1점씩 올라감
        let pipeCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 1, height: self.size.height))
        pipeCollision.zPosition = Layer.pipe
        pipeCollision.physicsBody = SKPhysicsBody(rectangleOf: pipeCollision.size)
        pipeCollision.physicsBody?.categoryBitMask = PhysicsCategory.score
        pipeCollision.physicsBody?.isDynamic = false
        pipeCollision.name = "pipeCollision"
        
        self.addChild(pipeDown)
        self.addChild(pipeUp)
        self.addChild(pipeCollision)
        
        // 스프라이트 배치
        let max = self.size.height * 0.3
        let xPos = self.size.width + pipeUp.size.width
        let yPos = CGFloat(arc4random_uniform(UInt32(max))) + envAtlas.textureNamed("land").size().height
        let endPos = self.size.width + (pipeDown.size.width * 2)
        
        pipeDown.position = CGPoint(x: xPos, y: yPos)
        pipeUp.position = CGPoint(x: xPos, y: pipeDown.position.y + pipeDistance + pipeUp.size.height)
        pipeCollision.position = CGPoint(x: xPos, y: self.size.height / 2)
        
        let moveAct = SKAction.moveBy(x: -endPos, y: 0, duration: 6)
        let moveSeq = SKAction.sequence([moveAct, SKAction.removeFromParent()])
        pipeDown.run(moveSeq)
        pipeUp.run(moveSeq)
        pipeCollision.run(moveSeq)
    }
    
    func createInfinitePipe(duration: TimeInterval) {
        let create = SKAction.run {
            [unowned self] in
                self.setUpPipe(pipeDistance: 100)
        }
        let wait = SKAction.wait(forDuration: duration)
        let actSeq = SKAction.sequence([create, wait])
        run(SKAction.repeatForever(actSeq))
    }
    
    func createTutorial() {
        tutorial = SKSpriteNode(imageNamed: "tutorial")
        tutorial.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        tutorial.zPosition = Layer.tutorial
        self.addChild(tutorial)
    }
    
    // MARK: - Game Algorithm
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .ready:
            gameState = .playing
            
            self.bird.physicsBody?.isDynamic = true
            self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 7))
            self.createInfinitePipe(duration: 4)
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let actSequence = SKAction.sequence([fadeOut, wait, remove])
            self.tutorial.run(actSequence)
            
        case .playing:
            self.run(SoundFX.wing)
            self.bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 5.5))
        case .dead:
            let touch = touches.first
            if let location = touch?.location(in: self) {
                let nodesArray = self.nodes(at: location)
                if nodesArray.first?.name == "restartBtn" {
                    self.run(SoundFX.swooshing)
                    let scene = MenuScene(size: self.size)
                    let transition = SKTransition.doorsOpenHorizontal(withDuration: 1)
                    self.view?.presentScene(scene, transition: transition)
                } else if nodesArray.first?.name == "leaderborad" {
                    showLeaderborad()
                }
            }
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var collideBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            collideBody = contact.bodyB
        } else {
            collideBody = contact.bodyA
        }
        
        let collideType = collideBody.categoryBitMask
        
        switch collideType {
        case PhysicsCategory.land:
            if gameState == .playing {
                gameOver()
            }
        case PhysicsCategory.ceiling:
            print("ceiling")
        case PhysicsCategory.pipe:
            if gameState == .playing {
                gameOver()
            }
        case PhysicsCategory.score:
            score += 10
            self.run(SoundFX.point)
            print(score)
        default:
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let rotation = self.bird.zRotation
        if rotation > 0 {
            self.bird.zRotation = min(rotation, 0.7)
        } else {
            self.bird.zRotation = max(rotation, -0.7)
        }
        
        if self.gameState == .dead {
            self.bird.physicsBody?.velocity.dx = 0
        }
    }
    
    func gameOver() {
        damageEffect()
        cameraShake()
        
        self.bird.removeAllActions()
        createGameOverBoard()
        
        self.bgmPlayer.run(SKAction.stop())
        
        self.gameState = .dead
    }
    
    func recordBestScore() {
        let userDefaults = UserDefaults.standard
        var bestScore = userDefaults.integer(forKey: "bestScore")
        
        if self.score > bestScore {
            bestScore = self.score
            userDefaults.set(bestScore, forKey: "bestScore")
        }
        userDefaults.synchronize()
    }
    
    func createGameOverBoard() {
        recordBestScore()
        updateLeaderboard()
        checkForAchivement()
        
        let gameoverBoard = SKSpriteNode(imageNamed: "gameoverBoard")
        gameoverBoard.position = CGPoint(x: self.size.width / 2, y: -gameoverBoard.size.height)
        gameoverBoard.zPosition = Layer.hud
        self.addChild(gameoverBoard)
        
        var medal = SKSpriteNode()
        
        if score >= 100 {
            medal = SKSpriteNode(imageNamed: "medalPlatinum")
        } else if score >= 50 {
            medal = SKSpriteNode(imageNamed: "medalGold")
        } else if score >= 30 {
            medal = SKSpriteNode(imageNamed: "medalSilver")
        } else if score >= 10 {
            medal = SKSpriteNode(imageNamed: "medalBronze")
        }
        medal.position = CGPoint(x: -gameoverBoard.size.width * 0.27, y: gameoverBoard.size.height * 0.02)
        medal.zPosition = 0.1
        gameoverBoard.addChild(medal)
        
        let scoreLabel = SKLabelNode(fontNamed: "Minercraftory")
        scoreLabel.fontSize = 13
        scoreLabel.fontColor = .orange
        scoreLabel.text = "\(score)"
        scoreLabel.horizontalAlignmentMode = .left
        
        if score == 0 {
            scoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.35, y: gameoverBoard.size.height * 0.07)
        } else if score >= 10 {
            scoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.31, y: gameoverBoard.size.height * 0.07)
        } else if score >= 100 {
            scoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.28, y: gameoverBoard.size.height * 0.07)
        } else {
            scoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.25, y: gameoverBoard.size.height * 0.07)
        }
        
        scoreLabel.zPosition = 0.1
        gameoverBoard.addChild(scoreLabel)
        
        print("scoreLabel'position is \(scoreLabel.position)")
        print("gmaeoverBoard'size is \(gameoverBoard.size.width)")
        
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        let bestScoreLabel = SKLabelNode(fontNamed: "Minercraftory")
        bestScoreLabel.fontSize = 13
        bestScoreLabel.fontColor = .orange
        bestScoreLabel.text = "\(bestScore)"
        bestScoreLabel.horizontalAlignmentMode = .left
        
        if bestScore == 0 {
            bestScoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.35, y: -gameoverBoard.size.height * 0.07)
        } else if bestScore >= 10 {
            bestScoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.31, y: -gameoverBoard.size.height * 0.07)
        } else if bestScore >= 100 {
            bestScoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.28, y: -gameoverBoard.size.height * 0.07)
        } else {
            bestScoreLabel.position = CGPoint(x: gameoverBoard.size.width * 0.25, y: -gameoverBoard.size.height * 0.07)
        }
        
        bestScoreLabel.zPosition = 0.1
        gameoverBoard.addChild(bestScoreLabel)
        
        let restartBtn = SKSpriteNode(imageNamed: "playBtn")
        restartBtn.name = "restartBtn"
        restartBtn.position = CGPoint(x: 0, y: -gameoverBoard.size.height * 0.35)
        restartBtn.zPosition = 0.1
        gameoverBoard.addChild(restartBtn)
        
        if GKLocalPlayer.local.isAuthenticated {
            let leaderborad = SKSpriteNode(imageNamed: "gameCenterIcon")
            leaderborad.name = "leaderborad"
            leaderborad.position = CGPoint(x: 0, y: -gameoverBoard.size.height * 0.70)
            leaderborad.zPosition = 0.1
            gameoverBoard.addChild(leaderborad)
        }
        
        gameoverBoard.run(SKAction.sequence([SKAction.moveTo(y: self.size.height / 2, duration: 1), SKAction.run {
            self.speed = 0
            }]))
    }
    
    func damageEffect() {
        let flashNode = SKSpriteNode(color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), size: self.size)
        let actionSequence = SKAction.sequence([SKAction.wait(forDuration: 0.01), SKAction.removeFromParent()])
        flashNode.name = "flashNode"
        flashNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        flashNode.zPosition = Layer.hud
        self.addChild(flashNode)
        flashNode.run(actionSequence)
        
        let wait = SKAction.wait(forDuration: 1)
        let soundSequence = SKAction.sequence([SoundFX.hit, wait, SoundFX.die])
        run(soundSequence)
    }
    
    func cameraShake() {
        let moveLeft = SKAction.moveTo(x: self.size.width / 2 - 5, duration: 0.1)
        let moveRight = SKAction.moveTo(x: self.size.width / 2 + 5, duration: 0.1)
        let moveReset = SKAction.moveTo(x: self.size.width / 2, duration: 0.1)
        let shakeAction = SKAction.sequence([moveLeft, moveRight, moveLeft, moveRight, moveReset])
        shakeAction.timingMode = .easeInEaseOut
        self.cameraNode.run(shakeAction)
    }
 
    func createRain() {
        guard let rainField = SKEmitterNode(fileNamed: "rain") else { return }
        rainField.position = CGPoint(x: self.size.width / 2, y: self.size.height)
        rainField.zPosition = Layer.rain
        rainField.advanceSimulationTime(30)
        self.addChild(rainField)
    }
    
}

extension GameScene: GKGameCenterControllerDelegate {
    
    func showLeaderborad() {
        if GKLocalPlayer.local.isAuthenticated {
            let gameCenter = GKGameCenterViewController()
            
            gameCenter.gameCenterDelegate = self
            gameCenter.viewState = GKGameCenterViewControllerState.leaderboards
            
            if let gameViewController = self.view?.window?.rootViewController {
                gameViewController.show(gameCenter, sender: self)
                gameViewController.navigationController?.pushViewController(gameCenter, animated: true)
            } else {
                print("Not Logged in!")
            }
            
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func updateLeaderboard() {
        if GKLocalPlayer.local.isAuthenticated {
            let leaderboradIdentifier = "com.hiroshi.FlappyBirdLikeBestScore"
            let bestScore = GKScore(leaderboardIdentifier: leaderboradIdentifier)
            let ingameBestScore = UserDefaults.standard.integer(forKey: "bestScore")
            bestScore.value = Int64(ingameBestScore)
            let scoreArray: [GKScore] = [bestScore]
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }
    
    func checkForAchivement() {
        if GKLocalPlayer.local.isAuthenticated {
            let inGameBestScore = score
            
            if inGameBestScore >= 100 {
                let identifier = "com.hiroshi.FlappyBirdLikePlatinumMedal"
                let achive = GKAchievement(identifier: identifier)
                achive.showsCompletionBanner = true
                achive.percentComplete = 100.0
                GKAchievement.report([achive], withCompletionHandler: nil)
                
            } else if inGameBestScore >= 50 {
                let identifier = "com.hiroshi.FlappyBirdLikeGoldMedal"
                let achive = GKAchievement(identifier: identifier)
                achive.showsCompletionBanner = true
                achive.percentComplete = 100.0
                GKAchievement.report([achive], withCompletionHandler: nil)
                
            } else if inGameBestScore >= 30 {
                let identifier = "com.hiroshi.FlappyBirdLikeSilverMedal"
                let achive = GKAchievement(identifier: identifier)
                achive.showsCompletionBanner = true
                achive.percentComplete = 100.0
                GKAchievement.report([achive], withCompletionHandler: nil)
                
            } else if inGameBestScore >= 10 {
                let identifier = "com.hiroshi.FlappyBirdLikeBronze"
                let achive = GKAchievement(identifier: identifier)
                achive.showsCompletionBanner = true
                achive.percentComplete = 100.0
                GKAchievement.report([achive], withCompletionHandler: nil)
                
            } else {
                return
            }
        }
    }
    
}
