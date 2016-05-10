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

class PlayScene: SKScene,UITextFieldDelegate,SubmitBtnDelegate, TopBtnDelegate {
    
    var myTextField : UITextField!
    var road        : Road!
    var submitBtn   : SubmitBtn!
    var chatView    : ChatView!
    
    // 前回更新時刻を保持、初期化するために必要
    var lastUpdatedAtInitToken = 0.0
    var lastUpdatedAt          = 0.0
    var gameTime               = 0.0
    var gameTimeInt            = 0
    
    var isGameOver = false
    var score      = 0
    var textList           : [String]     = []
    var friendMessageList  : [String]     = []
    
    override func didMoveToView(view: SKView) {
        
        self.view!.multipleTouchEnabled   = false
        
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
        chatView = ChatView(frame: CGRectMake(0, 0, view.bounds.width, 250))
        self.view!.addSubview(chatView)
        chatView.someoneName = "友達"
        chatView.itemes.append(ChatModel(text: "こんにちは！", type: NSBubbleType.BubbleTypeSomeoneElse))
        
        // 道路
        let baseY   = 288.0
        let targetY = Double(self.size.height) - 270
        let rateY      : Double = targetY / baseY
        let sceneWidth : CGFloat = self.frame.size.width
        road = Road(textureYScale: rateY, sceneWidth: sceneWidth)
        road.userInteractionEnabled = true
        self.physicsWorld.contactDelegate = road
        self.addChild(road)
        

        // mbaasから取得
        let innerQuery = NCMBQuery(className: "Message")
        innerQuery.limit = 100
        innerQuery.whereKey("user", notEqualTo: NCMBUser.currentUser())
        if let list = try! innerQuery.findObjects() as? [NCMBObject]{
            for l : NCMBObject in list {
                if let msg = l.objectForKey("message") as? String {
                    friendMessageList.append(msg)
                }
            }
        }
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

        if !self.textList.contains(text!) {
            self.textList.append(text!)
            self.score += text!.characters.count
        }
        // キーボード閉じる
        myTextField.resignFirstResponder()
        
        // chatviewにデータ追加
        chatView.itemes.append(ChatModel(text: text!, type: NSBubbleType.BubbleTypeMine))
        myTextField.text = ""

        // 相手のレスポンス
        if friendMessageList.count > 0 {
            let randInt   = Int(arc4random_uniform(UInt32(friendMessageList.count)))
            let friendMsg = friendMessageList[randInt]
            chatView.itemes.append(ChatModel(text: friendMsg, type: NSBubbleType.BubbleTypeSomeoneElse))
        }
        chatView.itemes.append(ChatModel(text: "Score: " + String(self.score), type: NSBubbleType.BubbleTypeSomeoneElse))
        chatView.reloadData()
        
        // 末尾までスクロール
        let nos = chatView.numberOfSections
        let nor = chatView.numberOfRowsInSection(nos - 1)
        let lastPath:NSIndexPath = NSIndexPath(forRow:nor - 1, inSection:nos - 1)
        chatView.scrollToRowAtIndexPath( lastPath , atScrollPosition: .Bottom, animated: true)
        
        // mbaasに登録
        let user : NCMBUser   = NCMBUser.currentUser()
        let post : NCMBObject = NCMBObject(className: "Message")
        let name : String     = UserData.getUserName()
        post.setObject(user,      forKey: "user")
        post.setObject(text,      forKey: "message")
        post.setObject(name,      forKey: "name")
        var error: NSError?
        post.save(&error)
        
    }
    
    // 結果表示
    func showResult() {
        self.chatView.removeFromSuperview()
        self.myTextField.removeFromSuperview()
        self.submitBtn.removeFromParent()
        self.backgroundColor = UIColor.redColor()
        
        let resultFrame : SKSpriteNode = SKSpriteNode(imageNamed: "result")
        resultFrame.xScale             = 1 / 2.5
        resultFrame.yScale             = 1 / 2.5
        resultFrame.zPosition          = 1
        resultFrame.position           = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(resultFrame)
        
        let score     = self.score
        var highScore = UserData.getHighScore()
        
        if score > highScore {
            UserData.setHighScore(score)
            highScore = score
            
            // mbaasに登録
            let user : NCMBUser   = NCMBUser.currentUser()
            let post : NCMBObject = NCMBObject(className: "Rank")
            let name : String     = UserData.getUserName()
            post.setObject(user,      forKey: "user")
            post.setObject(highScore, forKey: "score")
            post.setObject(name,      forKey: "name")
            var error: NSError?
            post.save(&error)
        }
        
        let highScoreLabel : SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        let scoreLabel     : SKLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        
        highScoreLabel.fontColor               = UIColor.greenColor()
        highScoreLabel.fontSize                = 30
        highScoreLabel.position                = CGPointMake(20,0)
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        highScoreLabel.text                    = String(highScore)
        resultFrame.addChild(highScoreLabel)
        
        scoreLabel.fontColor               = UIColor.blueColor()
        scoreLabel.fontSize                = 30
        scoreLabel.position                = CGPointMake(20,55)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.text                    = String(score)
        resultFrame.addChild(scoreLabel)
        
        let tweetBtn                     = TwitterBtn(msg: "歩きスマホは危険！ Score:" + String(score) + " #あるスマ")
        tweetBtn.userInteractionEnabled  = true
        tweetBtn.position                = CGPointMake(-120, -70)
        tweetBtn.zPosition               = 1
        resultFrame.addChild(tweetBtn)
        
        let topBtn                    = TopBtn(imageNamed : "Top")
        topBtn.userInteractionEnabled = true
        topBtn.position               = CGPointMake(120, -70)
        topBtn.zPosition              = 1
        topBtn.delegate               = self
        resultFrame.addChild(topBtn)
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

        // 車を追加する
        if gameTimeInt != Int(gameTime) {
            gameTimeInt = Int(gameTime)
            if gameTimeInt % 5 == 0 {
                let moveSpeed = -(Double(gameTimeInt / 5 * 60))
                road.addCar(moveSpeed)
            }
        }
        // 車を動かす
        for car  in road.carList {
            car.move(timeSinceLastUpdate)
        }
    }
}
