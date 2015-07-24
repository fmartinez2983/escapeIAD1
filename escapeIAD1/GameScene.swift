//
//  GameScene.swift
//  escapeIAD1
//
//  Created by FRANCISCO MARTINEZ on 7/17/15.
//  Copyright (c) 2015 FRANCISCO MARTINEZ. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var currentLevel = 0
    var currentLevelData:NSDictionary
    var background: SKSpriteNode
    var levelType: SKSpriteNode
    var nicole: SKSpriteNode
    var harpx = SKSpriteNode()
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

    var gameOver = false
    var touchLocation = CGFloat()
    var hero:Hero!
    
    // var nicoleSpeed = 10
    
    enum ColliderType:UInt32 {
        case nicole = 1
        case harpx = 2
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1)
        endOfScreenRight = self.size.width
        
        stagMaxRight = self.size.width/2
        stagMaxLeft = -stagMaxRight
        
        loadLevel()
        loadNicole()
        //loadHarpx()
        loadCreatures()
        loadTime()
    }
    
    func loadTime() {
        
        var actionwait = SKAction.waitForDuration(0.5)
        var timesecond = Int()
        var actionrun = SKAction.runBlock({
            timesecond++
            if timesecond == 0 {timesecond = 0}
            self.timeNode.text = "\(timesecond)"
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
        
        if notNicole.categoryBitMask == ColliderType.harpx.rawValue {

            pickHarpx = true
            
            harpx.removeFromParent()
            
            println("Picked up HarpX")
            
        }
    }
    
    func reloadGame() {
        
        timeNode.hidden = false
        loadLevel()
        loadTime()
        loadNicole()
        loadCreatures()
    
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
        
        let nicole1 = SKSpriteNode(imageNamed: "NicoleRun1")
        hero = Hero(girl: nicole1)
        nicole.position.y -= nicole.size.height/2
        nicole.position.x = -(scene!.size.width/2) + nicole.size.width * 2
        nicole.physicsBody = SKPhysicsBody(circleOfRadius: nicole.size.width/2)
        nicole.physicsBody!.affectedByGravity = false
        nicole.physicsBody!.categoryBitMask = ColliderType.nicole.rawValue
        nicole.physicsBody!.contactTestBitMask = ColliderType.harpx.rawValue;
        nicole.physicsBody!.collisionBitMask = ColliderType.harpx.rawValue;
        nicole.zPosition = 3.0
        addChild(nicole)
        
    }
    
    func loadHarpx() {
        
        harpx = SKSpriteNode(imageNamed: "harpx")
        harpx.physicsBody = SKPhysicsBody(circleOfRadius: harpx.size.width/2)
        harpx.physicsBody!.affectedByGravity = false
        harpx.physicsBody!.categoryBitMask = ColliderType.harpx.rawValue
        harpx.physicsBody!.contactTestBitMask = ColliderType.nicole.rawValue
        harpx.physicsBody!.collisionBitMask = ColliderType.nicole.rawValue
        harpx.position.y = -100
        harpx.zPosition = 4.0
        addChild(harpx)
    }
    
    
    func loadCreatures() {
        addCreature(named: "Alien", speed: 10.0, xPos: self.size.height/2)
    }
    
    func addCreature(#named:String, speed:Float, xPos:CGFloat) {
        var alienNode = SKSpriteNode (imageNamed: named)
        
        var alien1 = Creature(speed: speed, alien: alienNode)
        
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
        var nicoleAtlas = SKTextureAtlas(named: "nicole")
        
        for i in 1...2 {
            
            var textureName = "NicoleRun1"
            var temp = nicoleAtlas.textureNamed(textureName)
            runningNicoleTextures.append(temp)
            
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            
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
            
            gameOver = true
            
            var endScene = GameOver(size: self.size)
            var transition = SKTransition.doorsCloseVerticalWithDuration(2.0)
            
            self.scene?.view?.presentScene(endScene, transition: transition)
            
            println("Game Over")
            
            return true
        }
        /*
        if level >= 3 {
            
            gameOver = true
            
            var endScene = GameOver(size: self.size)
            var transition = SKTransition.doorsCloseVerticalWithDuration(2.0)
            
            self.scene?.view?.presentScene(endScene, transition: transition)
            
            println("Game Over")
            
        }
        */
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
        self.nicole = SKSpriteNode(texture: SKTexture(imageNamed: "NicoleRun1"))
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
}















