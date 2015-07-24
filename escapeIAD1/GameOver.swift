//
//  GameOver.swift
//  escapeIAD1
//
//  Created by FRANCISCO MARTINEZ on 7/23/15.
//  Copyright (c) 2015 FRANCISCO MARTINEZ. All rights reserved.
//

import SpriteKit
import GameKit

class GameOver: SKScene, GKGameCenterControllerDelegate {
    
    var gameOverScreen = SKLabelNode(text: "Your Time is: ")
    var tryAgain = SKLabelNode(text: "Tap To Try Again")
    var sendLB = SKLabelNode()
    var door = SKSpriteNode()
    var enabledGC = Bool()
    var defaultLB = String()
    
    override init(size: CGSize) {
        
        //self.gameOverScreen = SKSpriteNode(texture: SKTexture(imageNamed: "gameover"))
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor.grayColor()
        addChild(gameOverScreen)
        gameOverScreen.hidden = true
        gameOverScreen.name = "gameOver1"
        loadGameOver()
        
    }
    
    func loadGameOver () {
        
        gameOverScreen = SKLabelNode(text: "Your Time is: ")
        gameOverScreen.position = CGPointMake(300, 175)
        gameOverScreen.zPosition = 2.0
        self.addChild(gameOverScreen)
        
        tryAgain.fontColor = UIColor.redColor()
        tryAgain.fontSize = 24;
        tryAgain.fontName = "copperplate"
        tryAgain.position = CGPointMake(300, -10)
        tryAgain.runAction(SKAction .moveToY(70, duration: 1.0))
        tryAgain.zPosition = 3.0
        self.addChild(tryAgain)
        
        sendLB = SKLabelNode(text: "Send Time To Leaderboard")
        sendLB.fontColor = UIColor.redColor()
        sendLB.fontSize = 24;
        sendLB.fontName = "copperplate"
        sendLB.position = CGPointMake(300, -25)
        sendLB.runAction(SKAction .moveToY(40, duration: 1.0))
        sendLB.zPosition = 4.0
        self.addChild(sendLB)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.tryAgain {
                
                var backScene = GameScene(size:self.size)
                var transition = SKTransition.doorsOpenVerticalWithDuration(2.0)
                
                self.scene!.view!.presentScene(backScene, transition: transition)
                
                println("Try Again")
                
            } else if self.nodeAtPoint(location) == self.sendLB {
                
                var gameScene = GameScene(size: self.size)
                var transition = SKTransition.doorsOpenVerticalWithDuration(2.0)
                
                self.scene?.view?.presentScene(gameScene, transition: transition)
                
                println("")
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                
                let vc: UIViewController = self.view!.window!.rootViewController!
                vc.presentViewController(ViewController, animated: true, completion: nil)
                
            } else if (localPlayer.authenticated) {
                
                self.enabledGC = true
                
                
                localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String!, error: NSError!) -> Void in
                    if error != nil {
                        
                        println(error)
                        
                    } else {
                        
                        self.defaultLB = leaderboardIdentifer
                    }
                })
                
                
            } else {
                
                self.enabledGC = false
                println("Local player not authenticated, disabling game center")
                println(error)
            }
        }
    }

    
}