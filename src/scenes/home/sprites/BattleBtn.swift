//
//  BattleBtn.swift
//  あるきスマホ
//
//  Created by admin on 2016/03/13.
//  Copyright © 2016年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

protocol BattleBtnDelegate: class {
    func presentBattleRooms()
}

class BattleBtn: SKSpriteNode {
    var delegate: BattleBtnDelegate? = nil
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        self.delegate?.presentBattleRooms()
    }
    
}