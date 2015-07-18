//
//  GameScene.swift
//  escapeIAD1
//
//  Created by FRANCISCO MARTINEZ on 7/17/15.
//  Copyright (c) 2015 FRANCISCO MARTINEZ. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var currentLevel = 0
    var currentLevelData:NSDictionary
    var background: SKSpriteNode
    var levelType: SKSpriteNode
    var nicole: SKSpriteNode
    var harpx = SKSpriteNode()
    //var creature:[Creature] = []
    var levels:Levels
    var runningNicoleTextures = [SKTexture]()
    var stagMaxLeft: CGFloat = 0
    var stagMaxRight: CGFloat = 0
    var nicoleLeft = false
    var nicoleRight = false
    var aliens = [Creature].self
    var endOfScreenRight = CGFloat()
    var endOfScreenLeft = CGFloat()
    var pickHarpx = false
    
    // var nicoleSpeed = 10
    
    enum ColliderType:UInt32 {
        case nicole = 2
        case harpx = 1
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1)
        endOfScreenRight = self.size.width / 2
        
        stagMaxRight = self.size.width/2
        stagMaxLeft = -stagMaxRight
        
        loadLevel()
        loadNicole()
        loadHarpx()
        // loadCreature()
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        pickHarpx = true
        
        println("Picked up HarpX")
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
    
    func loadHarpx(){
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
    
    func updateHarpX(){
        
    }
    
    /*
    func loadCreature() {
    addCreature(named: "Alien", speed: 1.0, yPos: CGFloat(self.size.height))
    }
    
    func addCreature(#named:String, speed:Float, yPos:CGFloat) {
    
    var creatureNode = SKSpriteNode(imageNamed: named)
    var creature1 = Creature(speed: speed, alien: creatureNode)
    
    creature.append(creature1)
    resetCreature(creatureNode, yPos: yPos)
    creature1.yPos = creatureNode.position.y
    creatureNode.zPosition = 3.0
    addChild(creatureNode)
    }
    
    func resetCreature(creatureNode: SKSpriteNode, yPos:CGFloat) {
    creatureNode.position.x = endOfScreenRight
    }
    */
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
            return true
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
    /*
    func updateCreaturePosition(){
    for creature1 in creature {
    if !creature1.moving {
    creature1.currentFrame++
    if creature1.currentFrame > creature1.randomFrame {
    creature1.moving = true
    }
    
    } else {
    creature1.alien.position.y = CGFloat(Double(creature1.alien.position.y) + sin(creature1.range) * creature1.range)
    if creature1.alien.position.x > endOfScreenLeft {
    creature1.alien.position.x -= CGFloat(creature1.speed)
    } else {
    creature1.alien.position.x = endOfScreenRight
    creature1.currentFrame = 0
    creature1.setRandomFrame()
    creature1.moving = false
    creature1.range += 0.1
    }
    }
    }
    
    }
    */
    
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
        
        if !pickHarpx {
            
        }
        
        updateNicolePosition()
    }
}
