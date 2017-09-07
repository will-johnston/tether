//
//  GameScene.swift
//  Tether
//
//  Created by William Johnston on 5/10/17.
//  Copyright © 2017 William Johnston. All rights reserved.
//

import SpriteKit
import GameplayKit


extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalize() -> CGPoint {
        return CGPoint(x :self.x/length(), y: self.y/length())
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    //global variables
    let head = SKSpriteNode(imageNamed: "worm_head")
    let tail = SKSpriteNode(imageNamed: "worm_tail")
    var sprites = [SKSpriteNode]()
    var joints = [SKPhysicsJoint]()
    
    
    let headBitMask = UInt32(1)
    let tailBitMask = UInt32(2)
    let bodyBitMask = UInt32(4)
    let LeftArrowBitMask = UInt32(8)
    let RightArrowBitMask = UInt32(16)
    let downArrowBitMask = UInt32(32)
    let bombBitMask = UInt32(64)
   
    
    var touchStartPos: CGPoint?
   
    var wormTouched: Bool?
    var nodeToMove: SKNode?
    var scoreNode:SKLabelNode!
    var score = NSInteger()
    var gameIsOver: Bool?


    override func didMove(to view: SKView) {
        //set up worm and arrows
        gameIsOver = false
        setWorldPhysics()
        setUpWorm()
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(setUpArrows), SKAction.wait(forDuration: 2.5)])))
         run(SKAction.repeatForever(SKAction.sequence([SKAction.run(setUpBomb), SKAction.wait(forDuration: 10)])))
        
        //add score and game over feature
        score = 0
        scoreNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreNode.position = CGPoint( x: self.frame.midX, y: self.frame.size.height - self.frame.size.height/11 )
        scoreNode.zPosition = 100
        scoreNode.text = String(score)
        self.addChild(scoreNode)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(checkIfGameOver), SKAction.wait(forDuration: 0.25)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.5), SKAction.run(incrementScore)])))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !(gameIsOver!) else {
            return
        }
        var bodyOne: SKPhysicsBody?
        var bodyTwo: SKPhysicsBody?
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyOne = contact.bodyA
            bodyTwo = contact.bodyB
        } else {
            bodyOne = contact.bodyB
            bodyTwo = contact.bodyA
        }
        
        if ((bodyTwo?.categoryBitMask)! & LeftArrowBitMask != 0) {
            
            if let wormNode = bodyOne?.node as? SKSpriteNode, let
                leftArrow = bodyTwo?.node as? SKSpriteNode {
                wormArrowCollision(wormNode: wormNode, arrow: leftArrow, orientation: 0)
            }
        }
        else if ((bodyTwo?.categoryBitMask)! & RightArrowBitMask != 0) {
            
            if let wormNode = bodyOne?.node as? SKSpriteNode, let
                rightArrow = bodyTwo?.node as? SKSpriteNode {
                wormArrowCollision(wormNode: wormNode, arrow: rightArrow, orientation: 1)
            }
        }
        else if ((bodyTwo?.categoryBitMask)! & downArrowBitMask != 0) {
            if let wormNode = bodyOne?.node as? SKSpriteNode, let
            downArrow = bodyTwo?.node as? SKSpriteNode {
                wormArrowCollision(wormNode: wormNode, arrow: downArrow, orientation: 2)
            }
        }
        else if ((bodyTwo?.categoryBitMask)! & bombBitMask != 0) {
            if let wormNode = bodyOne?.node as? SKSpriteNode, let
                bomb = bodyTwo?.node as? SKSpriteNode {
                wormBombCollision(wormNode: wormNode, bomb: bomb)
            }
        }
    }
    
        func wormBombCollision(wormNode: SKSpriteNode, bomb: SKSpriteNode) {
            physicsWorld.removeAllJoints()
            head.removeAllActions()
            head.physicsBody?.allowsRotation = false
            tail.removeAllActions()
            head.physicsBody?.allowsRotation = false
            for sprite in sprites {
                sprite.removeAllActions()
                sprite.physicsBody?.allowsRotation = false

            }
            wormNode.physicsBody?.applyAngularImpulse(CGFloat(0.5))
            let over = SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run(transitionToGameOver)])
            run(over)
            
    }
    func transitionToGameOver() {
        let reveal = SKTransition.crossFade(withDuration: 1.5)
        let gameOverScene = GameOverScene(size: self.size, score: score)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    /*
    func wormdownArrowCollision(wormNode: SKSpriteNode, downArrow: SKSpriteNode) {
        downArrow.run(SKAction.sequence([SKAction.scale(to: 3.5, duration:TimeInterval(0.25)), SKAction.scale(to: 2.5, duration:TimeInterval(0.1))]))
        wormNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -0.25))
        let pulsedYellow = SKAction.sequence([
            SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.15),
            SKAction.wait(forDuration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.15)])
        downArrow.run(pulsedYellow)
    }
    */
    
    func checkIfGameOver() {
        guard !(gameIsOver!) else {
            return
        }
        if !head.intersects(head.parent!) && !tail.intersects(tail.parent!) {
            for sprite in sprites {
                guard !sprite.intersects(sprite.parent!) else {
                    return
                }
            }
            transitionToGameOver()
        }
    }
    
    func incrementScore() {
        score += 1
        scoreNode.text = String(score)
    }
    
    func wormArrowCollision(wormNode: SKSpriteNode, arrow: SKSpriteNode, orientation: Int) {
        
        let pulsedYellow = SKAction.sequence([
            SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.15),
            SKAction.wait(forDuration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.15)])
        arrow.run(pulsedYellow)
        
        arrow.run(SKAction.sequence([SKAction.scale(to: 2, duration:TimeInterval(0.15)), SKAction.scale(to: 1, duration:TimeInterval(0.1))]))
       
        
        if orientation == 0 {
            wormNode.physicsBody?.applyImpulse(CGVector(dx: -3, dy: 0))
        }
        else if orientation == 1
        {
            wormNode.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 0))
        }
        else if orientation == 2 {
            wormNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -1.5))

        }
    }

    
    func setWorldPhysics() {
        physicsWorld.contactDelegate = self
        //physicsWorld.speed = 0.2
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.2)//-9.8)
    }
    
    

    func setUpWorm() {
        //add head
        head.position = CGPoint(x: size.width * 0.3, y: size.height * 0.5)
        head.zPosition = 10
        head.name = "head"
        head.isUserInteractionEnabled = false
        addChild(head)
        
        //add tail
        tail.position = CGPoint(x: size.width * 0.3+40+40+16, y: size.height * 0.5)
        tail.zPosition = 10
        tail.name = "tail"
        tail.isUserInteractionEnabled = false
        addChild(tail)
        
        //set up physics for head and tail
        head.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: head.size.width, height: head.size.height))
        head.physicsBody?.isDynamic = true
        head.physicsBody?.categoryBitMask = headBitMask
        head.physicsBody?.collisionBitMask = 0
        head.physicsBody?.contactTestBitMask = LeftArrowBitMask | RightArrowBitMask | downArrowBitMask | bombBitMask
        tail.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: tail.size.width, height: tail.size.height))
        tail.physicsBody?.isDynamic = true
        tail.physicsBody?.categoryBitMask = tailBitMask
        tail.physicsBody?.contactTestBitMask = LeftArrowBitMask | RightArrowBitMask | downArrowBitMask | bombBitMask
        tail.physicsBody?.collisionBitMask = 0
        
        //add the middle part of body
        let body = bodyParts(count: 8)
        for sprite in body {
            addChild(sprite)
        }
        addJoints(bodyArr: body)
    }
    
    func addJoints(bodyArr: [SKSpriteNode]) {
        let count = bodyArr.count
        for index in 0..<count {  //inclusive because an extra set of joints are needed
            if index == 0 {
                //head case ;)
                let joint = SKPhysicsJointPin.joint(withBodyA: head.physicsBody!, bodyB: bodyArr[index].physicsBody!, anchor: CGPoint(x: head.frame.maxX, y: bodyArr[index].frame.midY))
                joint.shouldEnableLimits = true
                joint.lowerAngleLimit = -0.1
                joint.upperAngleLimit = 0.1
                self.physicsWorld.add(joint)
                joints.append(joint)
               
             
            }
            
            if index == count-1 {
                //tail case not an else if because count can be 1
                let joint = SKPhysicsJointPin.joint(withBodyA: tail.physicsBody!, bodyB: bodyArr[index].physicsBody!, anchor: CGPoint(x: bodyArr[index].frame.maxX, y: tail.frame.midY))
                joint.shouldEnableLimits = true
                joint.lowerAngleLimit = -0.1
                joint.upperAngleLimit = 0.1
                self.physicsWorld.add(joint)
                joints.append(joint)
             
            } else {
                //normal case
                let joint = SKPhysicsJointPin.joint(withBodyA: bodyArr[index].physicsBody!, bodyB: bodyArr[index+1].physicsBody!, anchor: CGPoint(x: bodyArr[index].frame.maxX, y: bodyArr[index+1].frame.midY))
                joint.shouldEnableLimits = true

                joint.lowerAngleLimit = -0.1
                joint.upperAngleLimit = 0.1
                self.physicsWorld.add(joint)
                joints.append(joint)
            }
            
        }
    }
    
    func bodyParts(count: Int) -> [SKSpriteNode] {
        //var sprites = [SKSpriteNode]()
        for index in 0..<count {
            let sprite = SKSpriteNode(imageNamed: "worm_body_thin")
            sprite.name = String(index+1)
            // physics
            sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width, height: sprite.size.height))
            sprite.physicsBody?.isDynamic = true
            sprite.physicsBody?.categoryBitMask = bodyBitMask
            sprite.physicsBody?.contactTestBitMask = LeftArrowBitMask | RightArrowBitMask | bombBitMask
            sprite.physicsBody?.collisionBitMask = 0
            // giving the sprites a position
            sprite.position = CGPoint(x: (size.width * 0.3)+20+(8.0 * CGFloat(index)), y: size.height*0.5)
            sprite.zPosition = 7
            sprites.append(sprite)
        }
        return sprites
    }
    
    func setUpBomb() {
        //set up bomb
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.zPosition = 5
        bomb.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bomb.size.width, height: bomb.size.height))
        bomb.physicsBody?.isDynamic = true
        bomb.physicsBody?.categoryBitMask = bombBitMask
        bomb.physicsBody?.collisionBitMask = 0
        bomb.physicsBody?.contactTestBitMask = headBitMask | tailBitMask | bodyBitMask
        bomb.physicsBody?.affectedByGravity = false
        
        //set up position
        var randomValue = random()*size.width
        if (randomValue < 100) {
            randomValue += (100+random()*50)
        }
        else if (randomValue > size.width-100) {
            randomValue -= (100+random()*50)
        }
        
        bomb.position = CGPoint(x: randomValue, y: self.frame.size.height + bomb.size.height * 2 )
        
        //create action to move/remove
        let distance = CGFloat(self.frame.size.height + 4.0 * bomb.size.height)
        let moveBomb = SKAction.moveBy(x: 0.0, y: -distance, duration:TimeInterval(0.01 * distance))
        let removeBomb = SKAction.removeFromParent()
        let moveAndRemoveBomb = SKAction.sequence([moveBomb, removeBomb])
        addChild(bomb)
        bomb.run(moveAndRemoveBomb)

    }
    
    func setUpArrows() {
        //create sprites
        let arrowLeft = SKSpriteNode(imageNamed: "left_arrow_simple")
        let arrowRight = SKSpriteNode(imageNamed: "right_arrow_simple")
        let downArrow = SKSpriteNode(imageNamed: "down_arrow_simple")
       
        //determine  arrow position
        var randomValue = random()*size.width
        if (randomValue < 100) {
            randomValue += (100+random()*50)
        }
        else if (randomValue > size.width-100) {
            randomValue -= (100+random()*50)
        }
    
        
        arrowLeft.zPosition = -5
        arrowRight.zPosition = -5
        downArrow.zPosition = -5

        //create action to move/remove
        let distance = CGFloat(self.frame.size.height + 4.0 * arrowLeft.size.height)
        let moveArrow = SKAction.moveBy(x: 0.0, y: -distance, duration:TimeInterval(0.01 * distance))
        let removeArrow = SKAction.removeFromParent()
        let moveArrowAndRemove = SKAction.sequence([moveArrow, removeArrow])
        
        //determine which arrow is spawned
        let rand = random()
        if rand < 0.33 {
            //spawn left arrow
            arrowLeft.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: arrowLeft.size.width, height: arrowLeft.size.height))
            arrowLeft.physicsBody?.isDynamic = true
            arrowLeft.physicsBody?.categoryBitMask = LeftArrowBitMask
            arrowLeft.physicsBody?.collisionBitMask = 0
            arrowLeft.physicsBody?.contactTestBitMask = tailBitMask | headBitMask

            arrowLeft.physicsBody?.affectedByGravity = false
            arrowLeft.position = CGPoint(x: randomValue, y: self.frame.size.height + arrowLeft.size.height * 2 )
            addChild(arrowLeft)
            arrowLeft.run(moveArrowAndRemove)
        } else if rand > 0.66
        {
            //spawn right arrow
            arrowRight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: arrowRight.size.width, height: arrowRight.size.height))
            arrowRight.physicsBody?.isDynamic = true
            arrowRight.physicsBody?.categoryBitMask = RightArrowBitMask
            arrowRight.physicsBody?.collisionBitMask = 0
            arrowRight.physicsBody?.contactTestBitMask = tailBitMask | headBitMask
            arrowRight.physicsBody?.affectedByGravity = false

             arrowRight.position = CGPoint( x: randomValue, y: self.frame.size.height + arrowRight.size.height * 2 )
            addChild(arrowRight)
            arrowRight.run(moveArrowAndRemove)
        }
        else {
            //spawn down arrow
           
            downArrow.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: downArrow.size.width, height: downArrow.size.height))
            downArrow.physicsBody?.isDynamic = true
            downArrow.physicsBody?.categoryBitMask = downArrowBitMask
            downArrow.physicsBody?.collisionBitMask = 0
            downArrow.physicsBody?.contactTestBitMask = headBitMask | tailBitMask | bodyBitMask
            downArrow.physicsBody?.affectedByGravity = false
             downArrow.position = CGPoint(x: randomValue, y: self.frame.size.height + downArrow.size.height*2.0)
            
            //create seperate action to move/remove
            let distanceDown = CGFloat(self.frame.size.height + 4.0 * downArrow.size.height)
            let movedownArrow = SKAction.moveBy(x: 0.0, y: -distanceDown, duration:TimeInterval(0.01 * distanceDown))
            let removedownArrow = SKAction.removeFromParent()
            let movedownArrowAndRemove = SKAction.sequence([movedownArrow, removedownArrow])
            
            addChild(downArrow)
            downArrow.run(movedownArrowAndRemove)
        }
        

    }

    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
   
        
        touchStartPos = touches.first?.location(in: self)
        let touchedNode = self.atPoint(touchStartPos!)
        
        if ((touchedNode.physicsBody?.categoryBitMask) == headBitMask || (touchedNode.physicsBody?.categoryBitMask) == tailBitMask || (touchedNode.physicsBody?.categoryBitMask) == bodyBitMask) {
            nodeToMove = touchedNode
            wormTouched = true
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            touchStartPos = nil
            wormTouched = false
            nodeToMove = nil
        }
        //make sure there is only one touch occurring
        guard touches.count == 1  else {
            return
        }
        //make sure one of the two balls was touched at beginning
        guard (wormTouched == true) else {
            return
        }
      
        let touchEndPos = touches.first?.location(in: self)
        let force = CGVector(dx: ((touchEndPos?.x)! - (touchStartPos?.x)!)*3.0, dy: ((touchEndPos?.y)! - (touchStartPos?.y)!)*3.0)

        nodeToMove?.physicsBody?.applyForce(force)

    }
}
