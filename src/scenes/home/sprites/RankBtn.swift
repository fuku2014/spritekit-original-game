//
//  SubmitBtn.swift
//  あるきスマホ
//
//  Created by admin on 2015/05/30.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

protocol RankBtnDelegate: class {
    func viewRank()
}

class RankBtn: SKSpriteNode {
    var delegate: RankBtnDelegate? = nil
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        self.delegate?.viewRank()
    }
   
}
