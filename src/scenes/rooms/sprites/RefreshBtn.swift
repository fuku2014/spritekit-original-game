//
//  RefreshBtn.swift
//  あるきスマホ
//
//  Created by admin on 2016/03/13.
//  Copyright © 2016年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

protocol RefreshBtnDelegate: class {
    func refresh()
}

class RefreshBtn: SKSpriteNode {
    var delegate: RefreshBtnDelegate? = nil
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        self.delegate?.refresh()
    }
    
}
