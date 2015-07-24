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
    //var doneLB = UIButton()
    var time = 0
    
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
        
        authenticateLocalPlayer()
        
    }
    
    func loadGameOver () {
        
        gameOverScreen = SKLabelNode(text: "Your Time is: ")
        //gameOverScreen.text = "\(timeNode)"
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
    
    func done(UIButton) {
        
        saveTimer(time)
        showLeader()
    
    }
    
    func saveTimer(score:Int) {

        if GKLocalPlayer.localPlayer().authenticated {
            
            var timeReporter = GKScore(leaderboardIdentifier: "EFTSleaderB_1")
            
            timeReporter.value = Int64(score)
            
            var timeArray: [GKScore] = [timeReporter]
            
            GKScore.reportScores(timeArray, withCompletionHandler: {(error : NSError!) -> Void in
                if error != nil {
                    
                    println("error")
                    
                }
            })
            
        }
        
    }
    
    func showLeader() {
        var vc = self.view?.window?.rootViewController
        var gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc?.presentViewController(gc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func authenticateLocalPlayer(){
        
        var localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                
                let vc: UIViewController = self.view!.window!.rootViewController!
                vc.presentViewController(viewController, animated: true, completion: nil)
                println("Something Happened")
                
            } else {
                
                println((GKLocalPlayer.localPlayer().authenticated))
                println("Nothing is Happening")
                
            }
        }
        
    }
    /*
    let vc: UIViewController = self.view!.window!.rootViewController!
    vc.presentViewController(ViewController, animated: true, completion: nil)
    */
    
}