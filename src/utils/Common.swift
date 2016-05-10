//
//  Common.swift
//  あるきスマホ
//
//  Created by admin on 2015/09/26.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit

class Common: NSObject {
    
    static func getRandomNumber(Min _Min : Float, Max _Max : Float)->Float {
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (_Max - _Min) + _Min
    }

}
