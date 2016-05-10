//
//  MainScene.swift
//  あるきスマホ
//
//  Created by admin on 2015/05/09.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit
import NCMB
import Moscapsule

class BattleScene: SKScene,UITextFieldDelegate,SubmitBtnDelegate, TopBtnDelegate {
    
    var mqttConfig   : MQTTConfig!
    var mqttClient   : MQTTClient!
    
    var myTextField : UITextField!
    var road        : Road!
    var submitBtn   : SubmitBtn!
    var chatView    : ChatView!
    
    var friend      : NCMBUser!
    
    // 前回更新時刻を保持、初期化するために必要
    var lastUpdatedAtInitToken = 0.0
    var lastUpdatedAt          = 0.0
    var gameTime               = 0.0
    var gameTimeInt            = 0
    
    var isGameOver = false
    var isLose     = false
    
    init(friend: NCMBUser, size: CGSize) {
        self.friend = friend
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func didMoveToView(view: SKView) {
        
        mqttInit()
        
        // 送信ボタン
        submitBtn = SubmitBtn(imageNamed: "submit")
        submitBtn.userInteractionEnabled = true
        submitBtn.position  = CGPointMake(self.size.width - submitBtn.size.width / 2,self.size.height - 265)
        submitBtn.zPosition = 2
        submitBtn.delegate  = self
        self.addChild(submitBtn)
        
        // 文字入力欄
        myTextField = UITextField(frame: CGRectMake(0,0,view.bounds.width - 50,30))
        myTextField.delegate = self
        myTextField.borderStyle = UITextBorderStyle.RoundedRect
        myTextField.layer.position = CGPoint(x:view.bounds.width / 2 - submitBtn.size.width / 2 ,y:265);
        myTextField.returnKeyType = UIReturnKeyType.Done
        myTextField.keyboardType = UIKeyboardType.Default
        self.view!.addSubview(myTextField)
        
        // チャット表示欄
        let data               = NSData(contentsOfURL:  NSURL (string: NCMBConfig.FILE_URL + friend.userName)!)
        let userAvater         =  data == nil ? UIImage(named: "manAvatar.png") : UIImage(data: data!)
        chatView = ChatView(frame: CGRectMake(0, 0, view.bounds.width, 250))
        self.view!.addSubview(chatView)
        chatView.someoneName  = friend.objectForKey("myName") as! String
        chatView.someoneImage = userAvater!
        chatView.itemes.append(ChatModel(text: "バトルスタート！", type: NSBubbleType.BubbleTypeSomeoneElse))
        
        // 道路
        let baseY   = 288.0
        let targetY = Double(self.size.height) - 270
        let rateY      : Double = targetY / baseY
        let sceneWidth : CGFloat = self.frame.size.width
        road = Road(textureYScale: rateY, sceneWidth: sceneWidth)
        road.userInteractionEnabled = true
        self.physicsWorld.contactDelegate = road
        self.addChild(road)
    }
    
    func mqttInit() {
        let username = NCMBUser.currentUser().userName + "btl"
        let host     = MqttServerInfo.shared.domain
        let port     = MqttServerInfo.shared.port
        let mqttUser = MqttServerInfo.shared.user
        let mqttPw   = MqttServerInfo.shared.password
        
        mqttConfig = MQTTConfig(clientId: username, host: host, port: Int32(port), keepAlive: 60)
        mqttConfig.mqttAuthOpts = MQTTAuthOpts(username: mqttUser, password: mqttPw)
        mqttConfig.cleanSession = true

        // メッセージ受信
        mqttConfig.onMessageCallback = { mqttMessage in
            let msg   : String   = mqttMessage.payloadString!
            let topic : String   = mqttMessage.topic
            if topic == "btl/" + NCMBUser.currentUser().userName {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showMessage(msg)
                })
            } else if topic == "lose/" + NCMBUser.currentUser().userName {
                self.win()
            }
        }
        mqttClient = MQTT.newConnection(mqttConfig)
        mqttClient.subscribe("btl/" + NCMBUser.currentUser().userName , qos: 2)
        mqttClient.subscribe("lose/" + NCMBUser.currentUser().userName , qos: 2)
    }
    
    // textFieldShouldReturn
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // 送信
    func submit() {
        
        if isGameOver {
            return
        }
        
        let text = myTextField.text
        
        if text == "" {
            return
        }
        
        // キーボード閉じる
        myTextField.resignFirstResponder()
        
        // chatviewにデータ追加
        chatView.itemes.append(ChatModel(text: text!, type: NSBubbleType.BubbleTypeMine))
        myTextField.text = ""
        
        // メッセージを相手に送信
        let topic = "btl/" + friend.userName
        mqttClient.publishString(text!, topic: topic , qos: 2, retain: false)
        chatView.reloadData()
        
        // 末尾までスクロール
        let nos = chatView.numberOfSections
        let nor = chatView.numberOfRowsInSection(nos - 1)
        let lastPath:NSIndexPath = NSIndexPath(forRow:nor - 1, inSection:nos - 1)
        chatView.scrollToRowAtIndexPath(lastPath , atScrollPosition: .Bottom, animated: true)
    }
    
    func showMessage(msg: String) {
        chatView.itemes.append(ChatModel(text: msg, type: NSBubbleType.BubbleTypeSomeoneElse))
        chatView.reloadData()
        // 末尾までスクロール
        let nos = chatView.numberOfSections
        let nor = chatView.numberOfRowsInSection(nos - 1)
        let lastPath:NSIndexPath = NSIndexPath(forRow:nor - 1, inSection:nos - 1)
        chatView.scrollToRowAtIndexPath(lastPath , atScrollPosition: .Bottom, animated: true)
        // 車を追加する
        let moveSpeed = -(Double(msg.characters.count * 60))
        road.addCar(moveSpeed)
    }
    
    func lose() {
        isGameOver = true
        // 負けたことを相手に通知する
        let topic = "lose/" + friend.userName
        let msg   = NCMBUser.currentUser().userName
        mqttClient.publishString(msg, topic: topic , qos: 2, retain: false)
    }
    
    func win() {
        isGameOver = true
    }
    
    // 結果表示
    func showResult() {
        self.chatView.removeFromSuperview()
        self.myTextField.removeFromSuperview()
        self.submitBtn.removeFromParent()
        
        self.backgroundColor = isLose ? UIColor.redColor() : UIColor.greenColor()

        
        let strLabel : SKLabelNode       = SKLabelNode(fontNamed: "serif")
        strLabel.text                    = isLose ? "YOU LOSE" : "YOU WIN"
        strLabel.fontColor               = UIColor.blackColor()
        strLabel.fontSize                = 40
        strLabel.position                = CGPointMake(CGRectGetMidX(self.frame),self.size.height * 0.9)
        strLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.addChild(strLabel)
        
        let topBtn                    = TopBtn(imageNamed : "Top")
        topBtn.userInteractionEnabled = true
        topBtn.position               = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        topBtn.zPosition              = 1
        topBtn.delegate               = self
        self.addChild(topBtn)

    }
    
    // トップに戻る
    func goTop(){
        let homeScene = HomeScene(size: self.view!.bounds.size)
        self.view!.presentScene(homeScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        homeScene.runAction(sound)
        // BGMの再生
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController! as! ViewController
        vc.changeBGM(homeScene)
    }
    
    // update
    override func update(currentTime: CFTimeInterval) {
        
        if isGameOver {
            self.showResult()
            return
        }
        
        if isLose {
            self.lose()
            return
        }
        
        // 前回のフレームの更新時刻を記憶しておく
        if lastUpdatedAtInitToken == 0.0 {
            lastUpdatedAt          = currentTime
            lastUpdatedAtInitToken = 0.1
        }
        
        // 前回フレーム更新からの経過時刻を計算する
        let timeSinceLastUpdate = currentTime - lastUpdatedAt;
        lastUpdatedAt           = currentTime
        gameTime               += timeSinceLastUpdate
        
        // 主人公を動かす
        if road.direction != DirectionType.DirectionNone {
            road.man.move()
        }

        // 車を動かす
        for car  in road.carList {
            car.move(timeSinceLastUpdate)
        }
    }
    
    override func willMoveFromView(view: SKView) {
        mqttClient.disconnect()
    }
}
