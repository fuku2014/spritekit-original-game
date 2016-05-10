//
//  Room.swift
//  あるきスマホ
//
//  Created by admin on 2016/03/13.
//  Copyright © 2016年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

protocol RoomEnterDelegate: class {
    func enterRoom(userName : String)
}

class Room: SKSpriteNode {
    
    var delegate: RoomEnterDelegate? = nil
    
    init() {
        let texture = SKTexture(imageNamed: "room")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        let userName : String = self.name!
        self.delegate?.enterRoom(userName)
    }

}
