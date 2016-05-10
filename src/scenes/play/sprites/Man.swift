//
//  Man.swift
//  あるきスマホ
//
//  Created by admin on 2015/09/20.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

class Man: SKSpriteNode {
    
    init() {
        let atlas = SKTextureAtlas(named: "man")

        let texture1 = atlas.textureNamed("man-01")
        let texture2 = atlas.textureNamed("man-02")

        
        texture1.filteringMode = .Nearest
        texture2.filteringMode = .Nearest

        
        let anim = SKAction.animateWithTextures([texture1, texture2], timePerFrame: 0.2)
        let walk = SKAction.repeatActionForever(anim)
        
        super.init(texture: nil, color: UIColor.clearColor(), size: texture1.size())
        
        self.setScale(1 / 15)
        self.runAction(walk)
        
        // 衝突判定用
        self.physicsBody                     = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic            = true
        self.physicsBody?.affectedByGravity  = false
        self.physicsBody?.categoryBitMask    = 0x1 << 1
        self.physicsBody?.contactTestBitMask = 0x1 << 0
        self.physicsBody?.collisionBitMask   = 0
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move() {
        let road = self.parent as! Road
        
        let positionBefore : CGPoint = self.position
        let moveAmountY    : CGFloat = road.direction == DirectionType.DirectionUp ? 5.0 : -5.0
        var positionAfter  : CGPoint = CGPointMake(positionBefore.x, positionBefore.y + moveAmountY)
        
        let topEnd    = road.groundTexture.size().height * road.textureYScale + road.loadTexture.size().height * road.textureYScale
        let bottomEnd = road.groundTexture.size().height * road.textureYScale
        
        if positionAfter.y - self.size.height / 2 <= bottomEnd || positionAfter.y + self.size.height / 2 >= topEnd {
            positionAfter = positionBefore
        }
        self.position = positionAfter
        
    }

}
