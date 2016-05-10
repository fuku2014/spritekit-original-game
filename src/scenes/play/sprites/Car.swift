//
//  Car.swift
//  あるきスマホ
//
//  Created by admin on 2015/09/22.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

class Car: SKSpriteNode {
    
    var moveSpeed    = 0.0
    var angularSpeed = 0.0
    
    init() {
        let atlas = SKTextureAtlas(named: "car")
        
        let texture1 = atlas.textureNamed("car-01")
        let texture2 = atlas.textureNamed("car-02")
        
        
        texture1.filteringMode = .Nearest
        texture2.filteringMode = .Nearest
        
        
        let anim = SKAction.animateWithTextures([texture1, texture2], timePerFrame: 0.2)
        let run  = SKAction.repeatActionForever(anim)
        
        super.init(texture: nil, color: UIColor.clearColor(), size: texture1.size())
        
        self.setScale(1 / 6)
        self.runAction(run)
        self.zPosition = 10
        
        // 衝突判定用
        self.physicsBody                                =  SKPhysicsBody(rectangleOfSize : self.size)
        self.physicsBody?.dynamic                       = true
        self.physicsBody?.affectedByGravity             = false
        self.physicsBody?.categoryBitMask               = 0x1 << 0
        self.physicsBody?.contactTestBitMask            = 0x1 << 1 | 0x1 << 0
        self.physicsBody?.collisionBitMask              = 0
        self.physicsBody?.usesPreciseCollisionDetection = true
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(timeSinceLastUpdate : CFTimeInterval) {
        
        let road = self.parent as! Road
        
        // 車の移動方向
        let angularAmount = self.angularSpeed * timeSinceLastUpdate
        self.zRotation    = self.zRotation + CGFloat(angularAmount)
        
        // 車の移動スピード
        let moveAmount  = self.moveSpeed * timeSinceLastUpdate
        let theta       = self.zRotation
        let moveAmountX = CGFloat(cos(theta)) * CGFloat(moveAmount)
        let moveAmountY = CGFloat(sin(theta)) * CGFloat(moveAmount)
        
        let positionBefore = self.position
        var positionAfter  = CGPointMake(positionBefore.x + moveAmountX, positionBefore.y + moveAmountY)
        
        let topEnd    = road.groundTexture.size().height * road.textureYScale + road.loadTexture.size().height * road.textureYScale
        let bottomEnd = road.groundTexture.size().height * road.textureYScale
        
        // 画面の左端に行った場合
        if positionAfter.x  <= 0 {
            positionAfter = CGPointMake(road.size.width, positionAfter.y)
        }
        // 道路の上下端に行った場合
        if positionAfter.y + self.size.height / 2 >= topEnd || positionAfter.y - self.size.height / 2 <= bottomEnd {
            self.zRotation = self.zRotation + 180
            positionAfter = positionBefore
        }
        self.position = positionAfter
    }

}
