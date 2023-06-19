//
//  GameScene.swift
//  Reefslab
//
//  Created by Tim Bornholdt on 6/3/23.
//

// TODO: The ball collides with the paddle and then shoots straight up and down. That makes it next to impossible to get it back to traveling at a more comfortable angle.
// TODO: Add rotation to the ball to see how that works.
// TODO: Experiment with how bricks populate on the screen. Creating some sort of standard template that I feed into the game engine to spit out some creative levels.

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var fingerIsOnPaddle = false
    var ballIsInMotion = false
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    
    let ballCategory:UInt32 = 0x1 << 0
    let bottomCategory:UInt32 = 0x1 << 1
    let brickCategory:UInt32 = 0x1 << 2
    let paddleCategory:UInt32 = 0x1 << 3
    
    let ball = SKShapeNode(circleOfRadius: 5)
    
    override init(size: CGSize) {
        super .init(size: size)
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        let worldBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
        
        let paddle = SKShapeNode(rectOf: CGSize(width: 50, height: 5))
        paddle.name = paddleCategoryName
        paddle.fillColor = SKColor.white
        paddle.position = CGPoint(x: self.frame.midX, y: paddle.frame.size.height * 4)
        self.addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.frame.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0
        paddle.physicsBody?.isDynamic = false
        
        ball.name = ballCategoryName
        ball.fillColor = .white  // Choose whatever color you like
        ball.strokeColor = .white  // If you want an outline, otherwise you can remove this line
        let paddleHeight = paddle.frame.size.height
        ball.position = CGPoint(x: paddle.position.x, y: paddle.position.y + paddleHeight/2 + ball.frame.size.height/2)
        self.addChild(ball)

        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
//        ball.physicsBody?.applyImpulse(CGVectorMake(30, -30))
        
        let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        self.addChild(bottom)
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory
        
        let numberOfRows = 5
        let numberOfBricks = 7
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
        
        launchBall()
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

                // Check if the ball's horizontal velocity is too low and adjust if necessary
                let minHorizontalVelocity: CGFloat = 10  // Set to the minimum horizontal speed you want
                if abs(firstBody.velocity.dx) < minHorizontalVelocity {
                    firstBody.velocity.dx = firstBody.velocity.dx >= 0 ? minHorizontalVelocity : -minHorizontalVelocity
                }
            }
            
        // If the ball hits the paddle
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory {
            // Calculate where the ball hit the paddle, relative to the paddle's center
            let hitLocation = contact.contactPoint.x - secondBody.node!.position.x

            // Use the hitLocation to adjust the ball's velocity
            let minVelocityX: CGFloat = 10  // This will be the velocity when the ball hits the paddle in the center
            let maxVelocityX: CGFloat = 30  // This will be the velocity when the ball hits the paddle at the very edge
            let velocityXRange = maxVelocityX - minVelocityX
            let paddleWidth = secondBody.node!.frame.width
            let velocityX = minVelocityX + velocityXRange * abs(hitLocation / (paddleWidth / 2))

            let velocityDirection: CGFloat = hitLocation > 0 ? 1 : -1  // The direction depends on the hit location

            // Always maintain the same vertical velocity
            let velocityY = abs(firstBody.velocity.dy)

            firstBody.velocity = CGVector(dx: velocityX * velocityDirection, dy: velocityY)
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
    
    func launchBall() {
        guard !ballIsInMotion else { return }

        // Determine direction of impulse: +1 for right, -1 for left
        let direction = arc4random_uniform(2) == 0 ? CGFloat(1) : CGFloat(-1)

        // Apply the impulse to the ball at 45 degree angle
        let angleInRadians = CGFloat.pi / 4
        let impulseVector = CGVector(dx: cos(angleInRadians) * direction, dy: sin(angleInRadians))
        let impulseMagnitude: CGFloat = 3  // Adjust this as needed
        ball.physicsBody?.applyImpulse(CGVector(dx: impulseVector.dx * impulseMagnitude, dy: impulseVector.dy * impulseMagnitude))

        ballIsInMotion = true
    }

}
