//
//  MovingNode.swift
//  あるきスマホ
//
//  Created by admin on 2015/09/16.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

enum DirectionType {
    case DirectionUp
    case DirectionDown
    case DirectionNone
}

class Road: SKSpriteNode, SKPhysicsContactDelegate {
    
    let groundTexture = SKTexture(imageNamed: "road-03")
    let loadTexture   = SKTexture(imageNamed: "road-02")
    let skyTexture    = SKTexture(imageNamed: "road-01")
    
    let textureYScale : CGFloat
    let sceneWidth    : CGFloat
    
    let man       : Man           = Man()
    var carList   : [Car]         = []
    var direction : DirectionType = DirectionType.DirectionNone
    

    init(textureYScale : Double, sceneWidth : CGFloat) {
        self.textureYScale = CGFloat(textureYScale)
        self.sceneWidth    = sceneWidth
        super.init(texture: groundTexture, color: UIColor.clearColor(), size: groundTexture.size())
        self.createTexture(groundTexture, yPosition: 0)
        self.createTexture(loadTexture,   yPosition: self.textureYScale * self.groundTexture.size().height)
        self.createTexture(skyTexture,    yPosition: self.textureYScale * self.groundTexture.size().height + self.textureYScale * self.loadTexture.size().height)
        
        // 主人公を追加
        self.addMan()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMan() {
        let groundHeight : CGFloat = groundTexture.size().height * textureYScale
        let loadHeight   : CGFloat = loadTexture.size().height * textureYScale
        man.position = CGPointMake(40, groundHeight + man.size.height / 2 + loadHeight / 2)
        man.zPosition = 5
        self.addChild(man)
    }
    
    func addCar(moveSpeed : Double) {
        let car          : Car = Car()
        let groundHeight : CGFloat = groundTexture.size().height * textureYScale
        let loadHeight   : CGFloat = loadTexture.size().height * textureYScale
        let w = self.size.width
        let min = groundHeight + car.size.height / 2
        let max = groundHeight + car.size.height / 2 + loadHeight
        let h = Common.getRandomNumber(Min: Float(min), Max: Float(max))
        car.position = CGPointMake(CGFloat(w), CGFloat(h))
        car.zPosition = 5
        car.moveSpeed = moveSpeed
        self.addChild(car)
        carList.append(car)
    }
    
    
    func createTexture(texture : SKTexture, yPosition : CGFloat){
        texture.filteringMode  = .Nearest
        let x                  = texture.size().width * 2.0
        let moveSprite         = SKAction.moveByX(-x, y: 0, duration: NSTimeInterval(0.02 * x))
        let resetSprite        = SKAction.moveByX(x,  y: 0, duration: 0.0)
        let moveSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSprite,resetSprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.sceneWidth / x; ++i {
            let sprite = SKSpriteNode(texture: texture)
            sprite.xScale = 2
            sprite.yScale = self.textureYScale
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + yPosition)
            sprite.runAction(moveSpritesForever)
            self.addChild(sprite)
        }
        
    }
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location     = touch.locationInNode(self)
            direction = location.y >= man.position.y ? DirectionType.DirectionUp : DirectionType.DirectionDown
        }
    }
    
    override func touchesEnded(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        direction = DirectionType.DirectionNone
    }
    
    func didBeginContact(contact:SKPhysicsContact){
        var firstBody  : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody  = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else {
            firstBody  = contact.bodyB;
            secondBody = contact.bodyA;
        }

        if (firstBody.categoryBitMask & 0x1 << 0) != 0 &&
           (secondBody.categoryBitMask & 0x1 << 1) != 0 {
            if let car = firstBody.node as? Car  {
                if let man = secondBody.node as? Man {
                    self.projectile(car, man: man)
                }
            }
        }
        // 車同士が衝突した場合
        if (firstBody.categoryBitMask & 0x1 << 0) != 0 &&
            (secondBody.categoryBitMask & 0x1 << 0) != 0 {
                if let car = firstBody.node as? Car  {
                    if let car2 = secondBody.node as? Car {
                        self.projectile(car, car2: car2)
                    }
                }
        }
    }
    
    func projectile(car : Car, man : Man){
        let sound    = SKAction.playSoundFileNamed("horn.mp3", waitForCompletion: false)
        let sound2   = SKAction.playSoundFileNamed("break.mp3", waitForCompletion: false)
        let sound3   = SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: false)
        let path     = NSBundle.mainBundle().pathForResource("bomb", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
        
        for car  in carList {
            let foundIndex = carList.indexOf(car)
            carList.removeAtIndex(foundIndex!)
            car.removeFromParent()
        }
        
        man.removeFromParent()
        
        particle.position  = man.position
        particle.xScale    = 1
        particle.yScale    = 1
        particle.zPosition = 3
        particle.runAction(sound)
        particle.runAction(sound2)
        particle.runAction(sound3)
        self.addChild(particle)
        
        let fadeOut  : SKAction = SKAction.fadeOutWithDuration(1.5)
        let remove   : SKAction = SKAction.removeFromParent()
        let sequence : SKAction = SKAction.sequence([fadeOut,remove])
        
        particle.runAction(sequence)
        
        if self.scene!.isKindOfClass(PlayScene) {
            let scene = self.scene as? PlayScene
            scene!.isGameOver = true
        } else if self.scene!.isKindOfClass(BattleScene) {
            let scene = self.scene as? BattleScene
            scene!.isLose = true
        }
    }
    
    func projectile(car : Car, car2 : Car){
 
        let path     = NSBundle.mainBundle().pathForResource("break", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
        
        
        if let foundIndex = carList.indexOf(car) {
            carList.removeAtIndex(foundIndex)
            car.removeFromParent()
        }
        
        if let foundIndex = carList.indexOf(car2) {
            carList.removeAtIndex(foundIndex)
            car2.removeFromParent()
        }
        
        particle.position  = car.position
        particle.xScale    = 0.25
        particle.yScale    = 0.25
        particle.zPosition = 3
        self.addChild(particle)
        
        let fadeOut  : SKAction = SKAction.fadeOutWithDuration(1.0)
        let remove   : SKAction = SKAction.removeFromParent()
        let sequence : SKAction = SKAction.sequence([fadeOut,remove])
        
        particle.runAction(sequence)
        
    }

}
