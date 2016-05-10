//
//  HomeScene.swift
//  あるきスマホ
//
//  Created by admin on 2015/09/06.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit

class HomeScene: SKScene,StartBtnDelegate, RankBtnDelegate, SettingBtnDelegate, BattleBtnDelegate {
    
    override func didMoveToView(view: SKView) {
        let back       = SKSpriteNode(imageNamed:"home_back")
        back.xScale    = self.size.width/back.size.width
        back.yScale    = self.size.height/back.size.height
        back.position  = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        back.zPosition = 0
        self.addChild(back)
        
        let startBtn                    = StartBtn(imageNamed: "home_btn_start")
        startBtn.delegate               = self
        startBtn.userInteractionEnabled = true
        startBtn.position               = CGPointMake(CGRectGetMidX(self.frame), self.size.height * 0.35)
        startBtn.zPosition              = 1
        self.addChild(startBtn)
        
        let rankBtn                     = RankBtn(imageNamed: "home_btn_rank")
        rankBtn.delegate                = self
        rankBtn.xScale                  = 1 / 5
        rankBtn.yScale                  = 1 / 5
        rankBtn.userInteractionEnabled  = true
        rankBtn.position                = CGPointMake(CGRectGetMidX(self.frame) - 65, self.size.height * 0.24)
        rankBtn.zPosition               = 1
        self.addChild(rankBtn)
        
        let battleBtn                     = BattleBtn(imageNamed: "home_btn_battle")
        battleBtn.delegate                = self
        battleBtn.xScale                  = 1 / 5
        battleBtn.yScale                  = 1 / 5
        battleBtn.userInteractionEnabled  = true
        battleBtn.position                = CGPointMake(CGRectGetMidX(self.frame), self.size.height * 0.24)
        battleBtn.zPosition               = 1
        self.addChild(battleBtn)
        
        let settingBtn                     = SettingBtn(imageNamed: "home_setting")
        settingBtn.userInteractionEnabled  = true
        settingBtn.delegate                = self
        settingBtn.position                = CGPointMake(CGRectGetMidX(self.frame) + 65, self.size.height * 0.24)
        settingBtn.zPosition               = 1
        self.addChild(settingBtn)
        
        let facebookBtn                     = FaceBookBtn(imageNamed: "home_facebook")
        facebookBtn.userInteractionEnabled  = true
        facebookBtn.position                = CGPointMake(CGRectGetMidX(self.frame) - 65 , self.size.height * 0.12)
        facebookBtn.zPosition               = 1
        self.addChild(facebookBtn)

        let tweetBtn                     = TwitterBtn(msg: "")
        tweetBtn.userInteractionEnabled  = true
        tweetBtn.position                = CGPointMake(CGRectGetMidX(self.frame) , self.size.height * 0.12)
        tweetBtn.zPosition = 1
        self.addChild(tweetBtn)
        
        let helpBtn                     = HelpBtn(imageNamed: "home_help")
        helpBtn.userInteractionEnabled  = true
        helpBtn.position                = CGPointMake(CGRectGetMidX(self.frame) + 65, self.size.height * 0.12)
        helpBtn.zPosition              = 1
        self.addChild(helpBtn)
        
        let highScore                    = UserData.getHighScore()
        let highScoreLabel : SKLabelNode = SKLabelNode(fontNamed: "serif")
        highScoreLabel.text                    = String(highScore) + "点"
        highScoreLabel.fontColor               = UIColor.redColor()
        highScoreLabel.fontSize                = 60
        highScoreLabel.position                = CGPointMake(CGRectGetMidX(self.frame) - 100, self.size.height * 0.6)
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        highScoreLabel.zPosition               = 1
        self.addChild(highScoreLabel)
    }
    
    func viewRank() {
        let rankScene          = RankScene(size: self.view!.bounds.size)
        rankScene.scaleMode    = SKSceneScaleMode.AspectFill
        rankScene.currentScore = UserData.getHighScore()
        rankScene.setup()
        rankScene.addBest5()
        rankScene.addRank()
        self.view!.presentScene(rankScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        rankScene.runAction(sound)
    }

    func gameStart() {
        let playScene = PlayScene(size: self.view!.bounds.size)
        playScene.scaleMode = SKSceneScaleMode.AspectFill;
        self.view!.presentScene(playScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        playScene.runAction(sound)
        // BGMの再生
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController! as! ViewController
        vc.changeBGM(playScene)
    }
    
    func showSetting() {
        let dialog   = SettingScene(scene: self, frame:CGRectMake(0, 0, self.view!.bounds.maxX - 50, 350))
        self.view!.addSubview(dialog)
    }
    
    func presentBattleRooms() {
        let roomsScene = RoomsScene(size: self.view!.bounds.size)
        roomsScene.scaleMode = SKSceneScaleMode.AspectFill;
        self.view!.presentScene(roomsScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        roomsScene.runAction(sound)
        roomsScene.refresh()
        // BGMの再生
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController! as! ViewController
        vc.changeBGM(roomsScene)
    }
}
