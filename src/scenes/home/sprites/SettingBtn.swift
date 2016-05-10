//
//  SettingBtn.swift
//  あるきスマホ
//
//  Created by admin on 2016/03/11.
//  Copyright © 2016年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

protocol SettingBtnDelegate: class {
    func showSetting()
}

class SettingBtn: SKSpriteNode {
    var delegate: SettingBtnDelegate? = nil
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        self.delegate?.showSetting()
    }
    
}