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

class FaceBookBtn: SKSpriteNode {
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        self.postFacebook()
    }
    
    func postFacebook(){
        let cv = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        cv.setInitialText("")
        cv.addURL(NSURL(string: "https://itunes.apple.com/us/app/arukisumaho-batoru/id1095247230?l=ja&ls=1&mt=8"))
        self.scene!.view?.window?.rootViewController?.presentViewController(cv, animated: true, completion:nil )
    }
}
