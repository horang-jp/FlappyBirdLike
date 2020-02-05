//
//  MenuScene.swift
//  FlappyBirdLike
//
//  Created by 김호중 on 2019/08/15.
//  Copyright © 2019 hojung. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var background = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        
        if arc4random() % 2 == 0 {
            background = SKSpriteNode(imageNamed: "background1")
            background.name = "background1"
        } else {
            background = SKSpriteNode(imageNamed: "background2")
            background.name = "background2"
        }
        
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        let titleLabel = SKSpriteNode(imageNamed: "titleLabel")
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.7)
        titleLabel.zPosition = 1
        self.addChild(titleLabel)
        
        let playBtn = SKSpriteNode(imageNamed: "playBtn")
        playBtn.name = "playBtn"
        playBtn.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
        playBtn.zPosition = 1
        self.addChild(playBtn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "playBtn" {
                let scene = GameScene(size: self.size)
                scene.background = self.background
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
        }
    }
}
