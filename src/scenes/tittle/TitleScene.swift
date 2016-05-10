//
//  FirstScene.swift
//  あるきスマホ
//
//  Created by admin on 2015/05/09.
//  Copyright (c) 2015年 m.fukuzawa. All rights reserved.
//

import UIKit
import SpriteKit
import NCMB

class TitleScene: SKScene, SignUpViewDelegate {
    
    override func didMoveToView(view: SKView) {

        // 背景のセット
        let back = SKSpriteNode(imageNamed:"title_back")
        back.xScale = self.size.width/back.size.width
        back.yScale = self.size.height/back.size.height
        back.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        back.zPosition = 0
        self.addChild(back)
        
        let userName : String! = UserData.getUserName()
        
        // 初回起動時にユーザー名入力ダイアログ表示
        if (userName == nil) {
            let dialog = SignUpView(scene: self, frame:CGRectMake(0, 0, self.view!.bounds.maxX - 50, 300))
            dialog.delegate = self
            self.view!.addSubview(dialog)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let uuid : String! = UserData.getUserId()
        var error: NSError?
        do {
            // ログイン
            try NCMBUser.logInWithUsername(uuid, password: uuid)
        } catch let error1 as NSError {
            error = error1
        }
        if let actualError = error {
            let alert: UIAlertController = UIAlertController(title:"通信エラー",
                message: actualError.localizedDescription,
                preferredStyle: UIAlertControllerStyle.Alert)
            self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        // ホーム画面へ遷移
        let homeScene       = HomeScene(size: self.view!.bounds.size)
        homeScene.scaleMode = SKSceneScaleMode.AspectFill;
        self.view!.presentScene(homeScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        homeScene.runAction(sound)
        // BGMの再生
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController! as! ViewController
        vc.changeBGM(homeScene)
    }
    
    func signUp(userName : String) {
        let uuid : String = NSUUID().UUIDString
        let user : NCMBUser = NCMBUser()
        let acl  : NCMBACL =  NCMBACL()
        var error: NSError?
        user.userName = uuid as String
        user.password = uuid as String
        user.setObject(userName, forKey: "myName")
        acl.setPublicReadAccess(true)
        acl.setPublicWriteAccess(true)
        user.ACL = acl
        // ユーザー登録
        user.signUp(&error)
        if let actualError = error {
          let alert: UIAlertController = UIAlertController(title:"通信エラー",
              message: actualError.localizedDescription,
              preferredStyle: UIAlertControllerStyle.Alert)
            self.view?.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            return
        }
        UserData.setUserId(uuid)
        UserData.setUserName(userName)
        let img  : UIImage = UIImage(named: "manAvatar.png")!
        let data : NSData  = UIImagePNGRepresentation(img)!
        UserData.setImageData(data)
    }
}
