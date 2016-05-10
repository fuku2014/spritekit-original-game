//
//  SubmitBtn.swift
//  あるきスマホ
//
//  Created by admin on 2015/05/30.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit
import Social


class TwitterBtn: SKSpriteNode {
    
    let url = "https://itunes.apple.com/us/app/arukisumaho-batoru/id1095247230?l=ja&ls=1&mt=8"
    var msg = ""
    
    init (msg : String) {
        self.msg = msg
        let texture = SKTexture(imageNamed: "home_tweet")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        self.tweet()
    }
    
    func tweet(){
        let cv = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        cv.setInitialText(msg)
        cv.addURL(NSURL(string: url))
        self.scene!.view?.window?.rootViewController?.presentViewController(cv, animated: true, completion:nil )
    }
   
}
