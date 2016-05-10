//
//  SubmitBtn.swift
//  あるきスマホ
//
//  Created by admin on 2015/05/30.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

class HelpBtn: SKSpriteNode {
    
    let webview: UIWebView = UIWebView()
    
    override func touchesBegan(touches:  Set<UITouch>, withEvent event: UIEvent?) {
        self.showHelp()
    }
    
    func showHelp(){
        let url =  NSURL (string: "http://arukisumaho.xyz/#how")
        UIApplication.sharedApplication().openURL(url!)
    }
}