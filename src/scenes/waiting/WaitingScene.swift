//
//  WaitingScene.swift
//  あるきスマホ
//
//  Created by admin on 2016/03/19.
//  Copyright © 2016年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit
import NCMB
import Moscapsule

class WaitingScene: SKScene, TopBtnDelegate {
    
    var mqttConfig   : MQTTConfig!
    var mqttClient   : MQTTClient!
    
    override func didMoveToView(view: SKView) {
        
        // 背景のセット
        self.backgroundColor = UIColor.brownColor()
        
        // ラベル
        let strLabel : SKLabelNode       = SKLabelNode(fontNamed: "serif")
        strLabel.text                    = "待機中..."
        strLabel.fontColor               = UIColor.blueColor()
        strLabel.fontSize                = 15
        strLabel.position                = CGPointMake(CGRectGetMidX(self.frame), self.size.height * 0.9)
        strLabel.zPosition               = 1
        strLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.addChild(strLabel)
        
        // 人間
        let man : Man = Man()
        man.position = CGPointMake(CGRectGetMidX(self.frame) + 55,self.size.height * 0.9)
        self.addChild(man)
        
        // トップ
        let top : TopBtn           = TopBtn(imageNamed: "Top")
        top.userInteractionEnabled = true
        top.position               = CGPointMake(self.size.width * 0.2, self.size.height * 0.1)
        top.delegate               = self
        top.xScale                 = 1 / 2
        top.yScale                 = 1 / 2
        top.zPosition = 1
        self.addChild(top)
        self.mqttInit()
    }

    func mqttInit() {
        let username = NCMBUser.currentUser().userName + "waiting"
        let host     = MqttServerInfo.shared.domain
        let port     = MqttServerInfo.shared.port
        let mqttUser = MqttServerInfo.shared.user
        let mqttPw   = MqttServerInfo.shared.password
        
        mqttConfig = MQTTConfig(clientId: username, host: host, port: Int32(port), keepAlive: 60)
        mqttConfig.mqttAuthOpts = MQTTAuthOpts(username: mqttUser, password: mqttPw)
        mqttConfig.cleanSession = true
        // willopts
        let willMsg : NSData       = NCMBUser.currentUser().userName.dataUsingEncoding(NSUTF8StringEncoding)!
        let willOps : MQTTWillOpts = MQTTWillOpts(topic: "left", payload: willMsg, qos: 2, retain: false)
        mqttConfig.mqttWillOpts    = willOps
        // メッセージ受信
        mqttConfig.onMessageCallback = { mqttMessage in
            let userName  : String   = mqttMessage.payloadString!
            let topic : String = mqttMessage.topic
            if topic == "rooms" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.notification(userName)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.enteredRoom(userName)
                })
            }
        }
        mqttClient = MQTT.newConnection(mqttConfig)
        // 部屋を検索した時のレスポンス
        let topicSearch = "rooms"
        mqttClient.subscribe(topicSearch , qos: 2)
        // 部屋に入ってきた時のレスポンス
        let topicEnter = "enter/" + NCMBUser.currentUser().userName
        mqttClient.subscribe(topicEnter , qos: 2)
    }
    
    func notification(userName: String) {
        let topic = "waiting/" + userName
        let msg   = NCMBUser.currentUser().userName
        mqttClient.publishString(msg, topic: topic , qos: 2, retain: false)
    }
    
    func enteredRoom(userName: String) {
        // readyを通知する
        let msg   = NCMBUser.currentUser().userName
        let topic = "ready/" + userName
        mqttClient.publishString(msg, topic: topic , qos: 2, retain: false)
        // ユーザー取得
        let query : NCMBQuery = NCMBUser.query()
        query.whereKey("userName", equalTo: userName)
        let user : NCMBUser = try! query.getFirstObject() as! NCMBUser
        // バトル画面へ移動
        let battleScene = BattleScene(friend: user, size: self.view!.bounds.size)
        battleScene.scaleMode = SKSceneScaleMode.AspectFill;
        self.view!.presentScene(battleScene)
        // BGMの再生
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController! as! ViewController
        vc.changeBGM(battleScene)
        
    }
    
    func goTop(){
        let homeScene = HomeScene(size: self.view!.bounds.size)
        self.view!.presentScene(homeScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        homeScene.runAction(sound)
    }
    
    override func willMoveFromView(view: SKView) {
        let willMsg   = NCMBUser.currentUser().userName
        mqttClient.publishString(willMsg, topic: "left", qos: 2, retain: false, requestCompletion: { (res, no) -> () in
            print(self.mqttClient.isConnected)
            print(res)
        })
        usleep(500000)
        mqttClient.disconnect { (res) -> () in
            print(self.mqttClient.isConnected)
            print(res)
        }
    }
}
