//
//  RoomsScene.swift
//  あるきスマホ
//
//  Created by admin on 2016/03/13.
//  Copyright © 2016年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit
import NCMB
import Moscapsule

class RoomsScene: SKScene, TopBtnDelegate, RefreshBtnDelegate, CreateRoomBtnDelegate, RoomEnterDelegate {
    
    var rooms        : [Room] = []
    var mqttConfig   : MQTTConfig!
    var mqttClient   : MQTTClient!
    
    override func didMoveToView(view: SKView) {
        // 背景のセット
        let back = SKSpriteNode(imageNamed:"rooms_back")
        back.xScale = self.size.width/back.size.width
        back.yScale = self.size.height/back.size.height
        back.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        back.zPosition = 0
        self.addChild(back)
        
        // ラベル
        let strLabel : SKLabelNode       = SKLabelNode(fontNamed: "serif")
        strLabel.text                    = "他の人とリアルタイムで遊べるモードです。"
        strLabel.fontColor               = UIColor.blueColor()
        strLabel.fontSize                = 15
        strLabel.position                = CGPointMake(CGRectGetMidX(self.frame),self.size.height * 0.9)
        strLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        strLabel.zPosition               = 1
        self.addChild(strLabel)
        
        // トップ
        let top : TopBtn           = TopBtn(imageNamed: "Top")
        top.userInteractionEnabled = true
        top.position               = CGPointMake(self.size.width * 0.2, self.size.height * 0.1)
        top.delegate               = self
        top.xScale                 = 1 / 2
        top.yScale                 = 1 / 2
        top.zPosition = 1
        self.addChild(top)
        
        // 更新
        let refreshBtn   : RefreshBtn   = RefreshBtn(imageNamed: "Refresh")
        refreshBtn.userInteractionEnabled = true
        refreshBtn.position               = CGPointMake(self.size.width * 0.8, self.size.height * 0.1)
        refreshBtn.delegate               = self
        refreshBtn.xScale                 = 1 / 2
        refreshBtn.yScale                 = 1 / 2
        refreshBtn.zPosition              = 1
        self.addChild(refreshBtn)
        
        //  作成
        let createRoom : CreateRoomBtn = CreateRoomBtn()
        createRoom.userInteractionEnabled = true
        createRoom.position               = CGPointMake(CGRectGetMidX(self.frame), self.size.height * 0.8)
        createRoom.delegate               = self
        createRoom.zPosition              = 1
        self.addChild(createRoom)
        
        self.mqttInit()
    }
    
    func mqttInit() {
        let username = NCMBUser.currentUser().userName + "room"
        let host     = MqttServerInfo.shared.domain
        let port     = MqttServerInfo.shared.port
        let mqttUser = MqttServerInfo.shared.user
        let mqttPw   = MqttServerInfo.shared.password
        
        mqttConfig = MQTTConfig(clientId: username, host: host, port: Int32(port), keepAlive: 60)
        mqttConfig.mqttAuthOpts = MQTTAuthOpts(username: mqttUser, password: mqttPw)
        mqttConfig.cleanSession = true
        // メッセージ受信
        mqttConfig.onMessageCallback = { mqttMessage in
            let userName  : String   = mqttMessage.payloadString!
            let topic : String = mqttMessage.topic
            if topic == "left" {
                dispatch_async(dispatch_get_main_queue(), {
                    self.removeRoom(userName)
                })
            } else if topic == "waiting/" + NCMBUser.currentUser().userName {
                dispatch_async(dispatch_get_main_queue(), {
                    self.addRoom(userName)
                })
            } else if topic == "ready/" + NCMBUser.currentUser().userName {
                dispatch_async(dispatch_get_main_queue(), {
                    self.readyForBattle(userName)
                })
            }
        }
        mqttClient = MQTT.newConnection(mqttConfig)
        let topic = "waiting/" + NCMBUser.currentUser().userName
        mqttClient.subscribe(topic , qos: 2)
        let topicWill = "left"
        mqttClient.subscribe(topicWill , qos: 2)
        let topicReady = "ready/" + NCMBUser.currentUser().userName
        mqttClient.subscribe(topicReady , qos: 2)
    }
    
    func addRoom(userName : String) {
        if self.rooms.count >= 3 {
            return
        }
        
        let query : NCMBQuery = NCMBUser.query()
        query.whereKey("userName", equalTo: userName)
        let user : NCMBUser = try! query.getFirstObject() as! NCMBUser
        
        // user name
        let labelUserName                     = SKLabelNode(fontNamed: "Chalkduster")
        labelUserName.text                    = "  VS  " + (user.objectForKey("myName") as? String)!
        labelUserName.fontColor               = UIColor.blackColor()
        labelUserName.fontSize                = 25
        labelUserName.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        labelUserName.verticalAlignmentMode   = SKLabelVerticalAlignmentMode.Center
        // user image
        let data               = NSData(contentsOfURL:  NSURL (string: NCMBConfig.FILE_URL + user.userName)!)
        let userAvater         =  data == nil ? UIImage(named: "manAvatar.png") : UIImage(data: data!)
        let imgUserAvater      = SKSpriteNode(texture: SKTexture(image: userAvater!))
        // room
        let roomNode = Room()
        roomNode.name     = user.userName
        roomNode.userInteractionEnabled = true
        roomNode.delegate = self
        roomNode.zPosition = 1
        labelUserName.position = CGPointMake(-roomNode.frame.size.width / 2 + 5 , CGRectGetMidY(roomNode.frame))
        imgUserAvater.position = CGPointMake(roomNode.frame.size.width / 2 - imgUserAvater.frame.size.width / 2 - 5, CGRectGetMidY(roomNode.frame))
        roomNode.addChild(labelUserName)
        roomNode.addChild(imgUserAvater)
        self.rooms.append(roomNode)
        renderRooms()
    }
    
    func removeRoom(userName : String) {
        let targetRoom = rooms.filter({(room : Room) -> Bool in
            return room.name == userName
        }).first
        if (targetRoom != nil) {
            targetRoom!.removeFromParent()
            let foundIndex = rooms.indexOf(targetRoom!)
            rooms.removeAtIndex(foundIndex!)
        }
    }
    
    func fetchRooms() {
        let topic = "rooms"
        let msg   = NCMBUser.currentUser().userName
        mqttClient.publishString(msg, topic: topic , qos: 2, retain: false)
    }
    
    func renderRooms() {
        var myHeight = self.size.height * 0.65
        for room in self.rooms {
            room.position  = CGPointMake(CGRectGetMidX(self.frame), myHeight)
            self.addChild(room)
            myHeight = myHeight - self.size.height * 0.15
        }
    }
    
    func goTop(){
        let homeScene = HomeScene(size: self.view!.bounds.size)
        self.view!.presentScene(homeScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        homeScene.runAction(sound)
    }
    
    func refresh() {
        for room in self.rooms {
            room.removeFromParent()
        }
        self.rooms.removeAll()
        self.fetchRooms()
    }
    
    func createRoom() {
        let waitingScene = WaitingScene(size: self.view!.bounds.size)
        waitingScene.scaleMode = SKSceneScaleMode.AspectFill;
        self.view!.presentScene(waitingScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        waitingScene.runAction(sound)
    }
    
    func enterRoom(userName: String) {
        let topic = "enter/" + userName
        let msg   = NCMBUser.currentUser().userName
        mqttClient.publishString(msg, topic: topic , qos: 2, retain: false)
    }
    
    func readyForBattle(userName: String) {
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
    
    override func willMoveFromView(view: SKView) {
        mqttClient.disconnect()
    }
}
