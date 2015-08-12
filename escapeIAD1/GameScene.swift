//
//  GameScene.swift
//  escapeIAD1
//
//  Created by FRANCISCO MARTINEZ on 7/17/15.
//  Copyright (c) 2015 FRANCISCO MARTINEZ. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    var currentLevel = 0
    var currentLevelData:NSDictionary
    var background: SKSpriteNode
    var levelType: SKSpriteNode
    var nicole: SKSpriteNode
    var harpx = SKSpriteNode(imageNamed: "harpx")
    var alienNode = SKSpriteNode()
    var creatures:[Creature] = []
    var levels:Levels
    var runningNicoleTextures = [SKTexture]()
    var stagMaxLeft: CGFloat = 0
    var stagMaxRight: CGFloat = 0
    var nicoleLeft = false
    var nicoleRight = false
    var endOfScreenRight = CGFloat()
    var endOfScreenLeft = CGFloat()
    var pickHarpx = false
    var timeNode = SKLabelNode(text: "0")
    var loadLB = SKLabelNode()
    var gameOver = false
    var touchLocation = CGFloat()
    var hero:Hero!
    var timeScore = Int(0)
    var identifier : String? = nil
    var index : Int!
    var percentComplete : Double = 0
    var progressInLevelAchievement = Bool()
    
    let fire = SKSpriteNode(imageNamed: "harpx")
    var fireIt = false
    
    // var nicoleSpeed = 10
    
    enum ColliderType:UInt32 {
        
        case nicole = 1
        case creature = 2
      //  case harpx = 3
        
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1)
        endOfScreenRight = self.size.width
        
        stagMaxRight = self.size.width/2
        stagMaxLeft = -stagMaxRight
        
        authenticateLocalPlayer()
        
        fire.hidden = true
        fire.zPosition = 7.0
        
        self.addChild(harpx)
        self.addChild(fire)
        
        
        loadLevel()
        loadNicole()
        //loadCreatures()
        loadHarpx()
        loadTime()
    }
    
    func loadTime() {
        
        var actionwait = SKAction.waitForDuration(0.5)
        var actionrun = SKAction.runBlock({
            
            self.timeScore++
            if self.timeScore == 0 {self.timeScore = 0}
            self.timeNode.text = "\(self.timeScore)"
            
        })
        
        timeNode.runAction(SKAction.repeatActionForever(SKAction.sequence([actionwait,actionrun])))
        timeNode.fontName = "copperplate"
        timeNode.fontColor = UIColor.redColor()
        timeNode.zPosition = 8.0
        timeNode.position = CGPointMake(100, 100)
        addChild(timeNode)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var notNicole = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            notNicole = contact.bodyB
            
        } else {
            
            notNicole = contact.bodyA
        }
        
        if notNicole.categoryBitMask == ColliderType.creature.rawValue {
            
            nicole.removeFromParent()
            
            println("ROAR! Game Over")
            
            reloadGame()
        /*
        } else if notNicole.categoryBitMask == ColliderType.harpx.rawValue {
            
            harpx.removeFromParent()
            
            println("HarpX ready!")
           */
        }
    }
    
    
    func reloadGame() {
        
        timeNode.hidden = false
        
    }
    
    func loadLevel() {
        
        currentLevelData = levels.data[currentLevel]
        loadBackground()
        loadLevelType()
        
    }
    
    func loadBackground() {
        
        var bgNum = currentLevelData["background"] as! String
        background = SKSpriteNode(imageNamed: "background_\(bgNum)")
        background.name = "background"
        background.zPosition = 1.0
        scene?.addChild(background)
        
    }
    
    func loadLevelType() {
        
        var levelTypeInfo = currentLevelData["type"] as! String
        levelType = SKSpriteNode(imageNamed: levelTypeInfo)
        levelType.name = "level_type"
        levelType.position.y = -50
        levelType.zPosition = 2.0
        scene?.addChild(levelType)
        
    }
    
    func loadNicole() {
        
        loadTextures()
        
        let nicole1 = SKSpriteNode(imageNamed: "BNicoleRun0")
        hero = Hero(girl: nicole1)
        nicole.position.y -= nicole.size.height/2
        nicole.position.x = -(scene!.size.width/2) + nicole.size.width * 2
        nicole.physicsBody = SKPhysicsBody(circleOfRadius: nicole.size.width/2)
        nicole.physicsBody!.affectedByGravity = false
        nicole.physicsBody!.categoryBitMask = ColliderType.nicole.rawValue
        nicole.physicsBody!.contactTestBitMask = ColliderType.creature.rawValue;
        nicole.physicsBody!.collisionBitMask = ColliderType.creature.rawValue;
        //nicole.physicsBody!.contactTestBitMask = ColliderType.harpx.rawValue;
        //nicole.physicsBody!.collisionBitMask = ColliderType.harpx.rawValue;
        nicole.zPosition = 3.0
        addChild(nicole)
        
    }

    func loadHarpx() {
        
        harpx = SKSpriteNode(imageNamed: "harpx")
        //harpx.physicsBody = SKPhysicsBody(circleOfRadius: harpx.size.width/3)
        harpx.position.y = -125
        harpx.position.x = 150
        harpx.zPosition = 4.0
        
        addChild(harpx)
        
    }
    
    func loadCreatures() {
        
        addCreature(named: "Alien", speed: 5.0, xPos: self.size.height/2)
        
    }
    
    func addCreature(#named:String, speed:Float, xPos:CGFloat) {
        
        alienNode = SKSpriteNode (imageNamed: named)
        
        var alien1 = Creature(speed: speed, alien: alienNode)
        
        alienNode.physicsBody = SKPhysicsBody(circleOfRadius: alienNode.size.width/2)
        alienNode.physicsBody!.affectedByGravity = false
        alienNode.physicsBody!.categoryBitMask = ColliderType.creature.rawValue
        alienNode.physicsBody!.contactTestBitMask = ColliderType.nicole.rawValue
        alienNode.physicsBody!.collisionBitMask = ColliderType.nicole.rawValue
        
        creatures.append(alien1)
        
        resetCreature(alienNode, xPos: xPos)
        
        alien1.xPos = alienNode.position.x
        
        alienNode.position.y = -85
        alienNode.zPosition = 5.0
        
        addChild(alienNode)
        
    }
    
    func resetCreature(alienNode: SKSpriteNode, xPos:CGFloat) {
        
        alienNode.position.x = endOfScreenRight
    }
    
    
    func nicoleMove(direction:String){
        
        if direction == "left" {
            
            nicoleLeft = true
            nicole.xScale = -1
            nicoleRight = false
            runNicole()
            
        } else {
            
            nicoleRight = true
            nicole.xScale = 1
            nicoleLeft = false
            runNicole()
            
        }
    }
    
    func runNicole(){
        
        nicole.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(runningNicoleTextures, timePerFrame: 0.1, resize: false, restore: true)))
        
    }
    
    
    func loadTextures() {
        
        var nicoleAtlas = SKTextureAtlas(named: "BNicole")
        
        for i in 1...2 {
            
            var textureName = "BNicoleRun0"
            var temp = nicoleAtlas.textureNamed(textureName)
            runningNicoleTextures.append(temp)
            
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            
            let location = touch.locationInNode(self)
            let thisNode = self.nodeAtPoint(location)
            
            if (thisNode.name == self.fire.name){
                
                self.fireIt = true
                self.fire.position = self.nicole.position
                self.fire.hidden = false
            }
            
            if event.allTouches()?.count == 1 {
                
                let location = touch.locationInNode(self)
                
                if location.x > 0{
                    
                    nicoleMove("right")
                    
                } else {
                    
                    nicoleMove("left")
                    
                }
                
            } else {
                
                println("pick up object")
                
            }
            
            if !gameOver {
                
                touchLocation = (touch.locationInView(self.view!).x * -1)+(self.size.height/2)
                
            }
            
            if self.nodeAtPoint(location) == self.loadLB {

                saveTimer(timeScore)
                showLeader()
                
                println("Credits")
                
            }
        }
    }
    
    func cancelMoves() {
        
        nicoleLeft = false
        nicoleRight = false
        nicole.removeAllActions()
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        cancelMoves()
    }
    
    func cleanScreen() {
        
        background.removeFromParent()
        levelType.removeFromParent()
        
    }
    
    func nextScreen(level:Int) -> Bool{
        
        if level >= 0 && level < levels.data.count {
            
            currentLevel = level
            currentLevelData = levels.data[currentLevel]
            cleanScreen()
            loadLevelType()
            loadBackground()
            loadCreatures()
            
            return true
        }
        
        if level == 4 {
            
            gameOver = true
            
            var timeShow = SKLabelNode(text: "Your time was: \(timeScore)")
            
            timeShow.fontColor = UIColor.redColor()
            timeShow.fontSize = 24;
            timeShow.fontName = "copperplate"
            timeShow.position = CGPointMake(25, 50)
            timeShow.zPosition = 3.0
            self.addChild(timeShow)
            
            timeNode.removeFromParent()
            harpx.removeFromParent()
            nicole.removeFromParent()
            
            loadLB = SKLabelNode(text: "Tap for Leaderboard")
            loadLB.fontColor = UIColor.redColor()
            loadLB.fontSize = 24;
            loadLB.fontName = "copperplate"
            loadLB.position = CGPointMake(25, 10)
            loadLB.zPosition = 4.0
            self.addChild(loadLB)
            
            println("Game Over")
            
        }
        
        return false
    }
    
    func updateNicolePosition() {
        
        if nicole.position.x < stagMaxLeft {
            
            if nextScreen(currentLevel - 1) {
                
                nicole.position.x = stagMaxRight
                println("Moving Right")
                
            }
            
            if nicoleLeft {
                
                return
                
            }
        }
        
        if nicole.position.x > stagMaxRight{
            
            if nextScreen(currentLevel + 1) {
                
                nicole.position.x = stagMaxLeft
                println("Moving Left")
                
            }
            
            if nicoleRight {
                
                return
            
            }
        }
        
        if nicoleLeft {
            
            nicole.position.x -= 5
            
        } else if nicoleRight {
            
            nicole.position.x += 5
            
        }
        
    }
    
    override init(size: CGSize) {
        
        self.currentLevel = 0
        self.currentLevelData = [:]
        self.levels = Levels()
        self.background = SKSpriteNode()
        self.nicole = SKSpriteNode(texture: SKTexture(imageNamed: "BNicoleRun0"))
        self.nicole.name = "Nicole"
        self.levelType = SKSpriteNode()
        self.harpx = SKSpriteNode()
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        updateNicolePosition()
        updateCreaturePosition()
        
        if self.fireIt{
            let missileSpeed:CGFloat = 50
            let blastRadius = 25
            var dX = (nicole.position.x - fire.position.x)
            var dY = (nicole.position.y - fire.position.y)
            
            let action = SKAction.moveBy(CGVectorMake(dX*missileSpeed/2500, dY*missileSpeed/2500), duration: 1.0)
            
            self.fire.runAction(action)
            
            if (Int(abs(dX)) < blastRadius) && (Int(abs(dY)) < blastRadius)
            {fire.position = harpx.position
                let action = SKAction.moveToX(100, duration: 1.0)
                harpx.physicsBody!.velocity = CGVectorMake(100,100)
                harpx.runAction(action)
                fire.runAction(action)
            }
        }
        
    }
    
    func updateCreaturePosition(){
        
        for alien1 in creatures {
            if !alien1.moving {
                alien1.currentFrame++
                if alien1.currentFrame > alien1.randomFrame {
                    alien1.moving = true
                }
                
            } else {
                alien1.alien.position.y = CGFloat(Double(alien1.alien.position.y) + sin(alien1.angle) * alien1.range)
                alien1.angle += hero.speed
                
                if alien1.alien.position.x > endOfScreenLeft {
                    
                    alien1.alien.position.x -= CGFloat(alien1.speed)
                    
                } else {
                    
                    alien1.alien.position.x = endOfScreenRight
                    alien1.currentFrame = 0
                    alien1.setRandomFrame()
                    alien1.moving = false
                    alien1.range = 0.01
                    
                }
            }
        }
    }

    func saveTimer(timeScore:Int) {
        
        if GKLocalPlayer.localPlayer().authenticated {
            
            var timeReporter = GKScore(leaderboardIdentifier: "EFTSleaderB_1")
            
            timeReporter.value = Int64(timeScore)
            
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
    
    func checkAchievements() {

        switch(timeScore)
            
        {
        case 1:
            identifier = "EFT001"
            //index = 0
            percentComplete = 100.0
            
        case 2:
            
            if timeScore <= 90 {
                
                identifier = "EFT002"
                //index = 1
                percentComplete = 100.0
            }
            
        case 3:

            if timeScore <= 60 {
                
                identifier = "EFT003"
                //index = 2
                percentComplete = 100.0
            }
            
        case 4:
            
            if timeScore <= 40 {
                
                identifier = "EFT004"
                //index = 3
                percentComplete = 100.0
            }
            
        case 5:
            identifier = "EFT005"
            //index = 4
            percentComplete = 100.0
            
        case 6:
            
            if currentLevel == 4 {
                
                identifier = "EFT006"
                //index = 4
                percentComplete = 100.0
                progressInLevelAchievement = true
            }
            
        default:
            identifier = nil
            
        }
        if identifier != nil {
            
            let achievement = GKAchievement(identifier: identifier)
            achievement.showsCompletionBanner = true
            
            GKAchievement.loadAchievementsWithCompletionHandler({(achievement, var error) in
                
                if (error != nil) {
                    
                    println("nothing is happening")
                   
                }
            })
        }
    }
    
    let gameCenterPlayer=GKLocalPlayer.localPlayer()
    
    var canUseGameCenter:Bool = false {
        
        didSet{if canUseGameCenter == true {
            
            gameCenterLoadAchievements()}
        
        }}
    
    var gameCenterAchievements=[String:GKAchievement]()
    
        func gameCenterLoadAchievements(){
        
        var allAchievements=[GKAchievement]()
        
        GKAchievement.loadAchievementsWithCompletionHandler({ (allAchievements, error:NSError!) -> Void in
            
            if error != nil{
                
                println("Could not load!")
                
            } else {
                
                for anAchievement in allAchievements  {
                    
                    if let oneAchievement = anAchievement as? GKAchievement {
                        
                        self.gameCenterAchievements[oneAchievement.identifier]=oneAchievement}
                    
                }
            }
        })
    }
    
    func gameCenterAddProgressToAnAchievement(progress:Double,achievementID:String) {
        
        if canUseGameCenter == true {
            
            var lookupAchievement:GKAchievement? = gameCenterAchievements[achievementID]
            
            if let achievement = lookupAchievement {
                
                if achievement.percentComplete != 100 {
                    
                    achievement.percentComplete = progress
                    if progress == 100.0  {achievement.showsCompletionBanner=true}
                    
                    GKAchievement.reportAchievements([achievement], withCompletionHandler:  {(var error:NSError!) -> Void in
                        if error != nil {
                            println("No Progress")
                        }
                    })
                } else {
                    
                    println("DEBUG: Achievement (\(achievementID)) working")}
                
            } else {
                
                println("No achievement with ID (\(achievementID)) was found.")
                gameCenterAchievements[achievementID] = GKAchievement(identifier: achievementID)
                gameCenterAddProgressToAnAchievement(progress, achievementID: achievementID)
                
            }
        }
    }
}















