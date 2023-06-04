//
//  GameScene.swift
//  Reefslab
//
//  Created by Tim Bornholdt on 6/3/23.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var fingerIsOnPaddle = false
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    
    let ballCategory:UInt32 = 0x1 << 0
    let bottomCategory:UInt32 = 0x1 << 1
    let brickCategory:UInt32 = 0x1 << 2
    let paddleCategory:UInt32 = 0x1 << 3
    
    override init(size: CGSize) {
        super .init(size: size)
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        let worldBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
        
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = ballCategoryName
        ball.position = CGPointMake(self.frame.size.width / 4, self.frame.size.height / 4)
        ball.size = CGSize(width: 50, height: 50)
        self.addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.applyImpulse(CGVectorMake(30, -30))
        
        let paddle = SKShapeNode(rectOf: CGSize(width: 200, height: 5))
        paddle.name = paddleCategoryName
        paddle.fillColor = SKColor.white
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddle.frame.size.height * 4)
        self.addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.frame.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0
        paddle.physicsBody?.isDynamic = false
        
        let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        self.addChild(bottom)
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory
        
        let numberOfRows = 1
        let numberOfBricks = 3
        let brickWidth = 30
        let padding:Float = 20
        
        let offSet:Float = (Float(self.frame.size.width) - (Float(brickWidth) * Float(numberOfBricks) + padding * (Float(numberOfBricks) - 1) ) ) / 2
        
        for index in 1 ... numberOfRows {
            
            var yOffset:CGFloat {
                switch index {
                case 1:
                    return self.frame.size.height * 0.8
                case 2:
                    return self.frame.size.height * 0.7
                case 3:
                    return self.frame.size.height * 0.6
                case 4:
                    return self.frame.size.height * 0.5
                case 5:
                    return self.frame.size.height * 0.4
                case 6:
                    return self.frame.size.height * 0.3
                default:
                    return self.frame.size.height * 0
                }
            }
            
            for index in 1 ... numberOfBricks {
                let brick = SKShapeNode(rectOf: CGSize(width: 30, height: 5))
                brick.fillColor = .random
                let calc1:Float = Float(index) - 0.5
                let calc2:Float = Float(index) - 1
                
                brick.position = CGPointMake(CGFloat(calc1 * Float(brick.frame.size.width) + calc2 * padding + offSet), yOffset)
                
                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.frame.size)
                brick.physicsBody?.allowsRotation = false
                brick.physicsBody?.friction = 0
                brick.physicsBody?.restitution = 1.0
                brick.physicsBody?.isDynamic = false
                brick.name = brickCategoryName
                brick.physicsBody?.categoryBitMask = brickCategory
                self.addChild(brick)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            if touchLocation.y < self.size.height / 4 {
                fingerIsOnPaddle = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if fingerIsOnPaddle {
            if let touch = touches.first {
                let touchLoc = touch.location(in: self)
                let prevTouchLoc = touch.previousLocation(in: self)
                    
                if let paddle = self.childNode(withName: paddleCategoryName) as? SKShapeNode {
                    var newXPos = paddle.position.x + (touchLoc.x - prevTouchLoc.x)
                    newXPos = max(newXPos, paddle.frame.width / 2)
                    newXPos = min(newXPos, self.size.width - paddle.frame.width / 2)
                    paddle.position = CGPoint(x: newXPos, y: paddle.position.y)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerIsOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            let gameOverScene = GameOverScene(size: self.frame.size, playerWon: false)
            self.view?.presentScene(gameOverScene)
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory {
            secondBody.node?.removeFromParent()
            
            if isGameWon() {
                let youWinScene = GameOverScene(size: self.frame.size, playerWon: true)
                self.view?.presentScene(youWinScene)
            }
        }
        
        // Handle ball and paddle contact
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory {
            print("first body is ball, second body is paddle")
            // Calculate where the ball hit the paddle relative to the paddle's center
            let hitLocation = contact.contactPoint.x - secondBody.node!.position.x
            print("paddle center: %d", hitLocation)

            // Use the hitLocation to adjust the ball's velocity
            let ballVelocityY = abs(firstBody.velocity.dy)
            let ballVelocityX = hitLocation * 10  // Adjust the multiplier as needed to get the desired effect
            firstBody.velocity = CGVector(dx: ballVelocityX, dy: ballVelocityY)
        }
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        
        for nodeObject in self.children {
            let node = nodeObject as SKNode
            if node.name == brickCategoryName {
                numberOfBricks += 1
            }
        }
        
        return numberOfBricks <= 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
