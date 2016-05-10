
import UIKit
import SpriteKit
import NCMB

class RankScene: SKScene, TopBtnDelegate {
    
    var currentScore = 0
    
    func setup(){
        // 背景
        let back       = SKSpriteNode(imageNamed:"rank_back")
        back.xScale    = self.size.width  / back.size.width
        back.yScale    = self.size.height / back.size.height
        back.position  = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        back.zPosition = 0
        self.addChild(back)
        // トップ
        let top : TopBtn           = TopBtn(imageNamed: "Top")
        top.userInteractionEnabled = true
        top.position               = CGPointMake(self.size.width * 0.2, self.size.height * 0.1)
        top.delegate               = self
        top.xScale                 = 1 / 2
        top.yScale                 = 1 / 2
        top.zPosition = 1
        self.addChild(top)
    }
    
    func goTop(){
        let homeScene = HomeScene(size: self.view!.bounds.size)
        self.view!.presentScene(homeScene)
        let sound    = SKAction.playSoundFileNamed("button.mp3", waitForCompletion: false)
        homeScene.runAction(sound)
    }
    
    func addBest5() -> (Bool){
        // Rankクラスからクエリを生成
        let rankQuery = NCMBQuery(className: "Rank")
        // スコア順にソート
        rankQuery.orderByDescending("score")
        //5件取得
        rankQuery.limit = 5
        // クエリを実行して、rankList配列に結果を格納
        if let rankList = try! rankQuery.findObjects() as? [NCMBObject]{
            var myHeight = self.size.height * 0.7
            // 取得件数分ループする
            for rank : NCMBObject in rankList {
                let lavbelMyName  = SKLabelNode(fontNamed: "Chalkduster")
                let lavbelMyScore = SKLabelNode(fontNamed: "Chalkduster")
                // Rankクラスから、ユーザーを取得
                if let user = rank.objectForKey("name") as? String {
                    lavbelMyName.text = user
                }
                // Rankクラスからスコアを取得
                if let score = rank.objectForKey("score") as? Int {
                    lavbelMyScore.text = "score: " + String(score)
                }
                
                lavbelMyName.fontColor  = UIColor.blackColor()
                lavbelMyScore.fontColor = UIColor.redColor()
                
                lavbelMyName.fontSize  = 15
                lavbelMyScore.fontSize = 15
                
                lavbelMyName.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
                lavbelMyScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
                
                lavbelMyName.position  = CGPointMake(self.size.width*0.27,myHeight)
                lavbelMyScore.position = CGPointMake(self.size.width*0.27,lavbelMyName.position.y - 20)
                
                lavbelMyName.zPosition = 1
                lavbelMyScore.zPosition = 1
                
                self.addChild(lavbelMyName)
                self.addChild(lavbelMyScore)
                myHeight = myHeight - self.size.height * 0.1
            }
        }
        return true
    }
    
    func addRank() -> (Bool){
        let rankQuery = NCMBQuery(className: "Rank")
        rankQuery.whereKey("score", greaterThan: currentScore)
        var error: NSError?
        let myRnak = rankQuery.countObjects(&error) + 1

        let lavbelMyName = SKLabelNode(fontNamed: "Chalkduster")
        let lavbelMyScore = SKLabelNode(fontNamed: "Chalkduster")
        let lavbelMyRank = SKLabelNode(fontNamed: "Chalkduster")
        
        
        lavbelMyName.text  = UserData.getUserName()
        lavbelMyScore.text = "score: " + String(self.currentScore)
        lavbelMyRank.text  = String(myRnak)
        
        lavbelMyName.fontColor  = UIColor.blackColor()
        lavbelMyScore.fontColor = UIColor.redColor()
        lavbelMyRank.fontColor  = UIColor.greenColor()
        
        lavbelMyName.fontSize  = 15
        lavbelMyScore.fontSize = 15
        lavbelMyRank.fontSize  = 25
        
        lavbelMyName.position  = CGPointMake(self.size.width*0.27,self.size.height*0.21);
        lavbelMyScore.position = CGPointMake(self.size.width*0.27,lavbelMyName.position.y - 20)
        lavbelMyRank.position  = CGPointMake(self.size.width*0.1,self.size.height*0.18);
        
        lavbelMyName.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lavbelMyScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lavbelMyRank.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        lavbelMyName.zPosition = 1
        lavbelMyScore.zPosition = 1
        lavbelMyRank.zPosition = 1
        
        self.addChild(lavbelMyName)
        self.addChild(lavbelMyScore)
        self.addChild(lavbelMyRank)
        return true
    }
}
