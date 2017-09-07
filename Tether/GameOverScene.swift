//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by William Johnston on 5/10/17.
//  Copyright © 2017 William Johnston. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    
    var button: UIButton?
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "highScore")
        }
    }
    override func didMove(to view: SKView) {
        button = UIButton(frame: CGRect(x: size.width*0.5 - 50, y: size.height*0.6, width: 100, height: 40))
        button?.backgroundColor = UIColor.white
        
        button?.layer.cornerRadius = 5
        button?.layer.borderWidth = 1
        button?.layer.borderColor = UIColor.black.cgColor
        button?.setTitleColor(UIColor.black, for: .normal)
        button?.titleLabel!.font =  UIFont(name: "Baskerville-Italic", size: 30)
        button?.setTitle("retry", for: .normal)
        button?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view?.addSubview(button!)
    }

    
    init(size: CGSize, score: NSInteger) {
        super.init(size: size)
        backgroundColor = SKColor.lightGray
        let scoreMessage = String(score)
        let gameOverMessage = "final score"

        //determine high score
        if score > highScore{
            highScore = score
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        highScoreLabel.text = "high score: " + String(highScore)
        highScoreLabel.fontSize = 30
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: size.width*0.7, y: size.height - 40)
        addChild(highScoreLabel)
        
        
        let scoreLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        scoreLabel.text = scoreMessage
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(scoreLabel)
        
        let gameoverLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        gameoverLabel.text = gameOverMessage
        gameoverLabel.fontSize = 40
        gameoverLabel.fontColor = SKColor.white
        gameoverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 70)
        addChild(gameoverLabel)
        
      /*  let retry = SKLabelNode(fontNamed: "Baskerville-Italic")
        retry.text = "retry"
        retry.fontSize = 35
        retry.fontColor = SKColor.black
        retry.position = CGPoint(x: size.width*0.5, y: size.height*0.375)
        addChild(retry)
        */
        /*run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run({
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = GameScene(size: size)
            self.view?.presentScene(scene, transition: reveal)
        })]))*/
    }
    
    
    func buttonAction(sender: UIButton!) {
        run(SKAction.run({
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition: reveal)
        }))
        button?.removeFromSuperview()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
