//
//  GameOverScene.swift
//  Reefslab
//
//  Created by Tim Bornholdt on 6/4/23.
//

import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize, playerWon:Bool) {
        super.init(size: size)
        
        var text = "Failure."
        
        if playerWon {
            text = "Winner!"
        }
        
        let gameOverLabel = SKMultilineLabel(text: text, labelWidth: 250, pos: CGPoint(x: size.width / 2, y: size.height / 2))
        gameOverLabel.fontSize = 48
        self.addChild(gameOverLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene)
    }
}
