import UIKit
import SpriteKit

protocol SignUpViewDelegate: class {
    func signUp(userName : String)
}

class SignUpView: UIView, UITextFieldDelegate {
    
    let minLength = 1
    let maxLength = 6
    
    var backGroundView : UIView!
    var scene          : SKScene!
    var delegate       : SignUpViewDelegate? = nil
    var okButton       : UIButton            = UIButton(type: UIButtonType.Custom)
    var nameInputView  : UITextField         = UITextField(frame: CGRectMake(0, 0, 250, 30))
    let webview        : UIWebView           = UIWebView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 初期化処理
    init(scene : SKScene,frame : CGRect){
        
        super.init(frame: scene.view!.bounds)
        
        self.scene = scene
        self.scene.view!.paused = true
        
        self.scene.userInteractionEnabled = false
        self.layer.zPosition = 10
        
        // SceneOver
        self.backGroundView                 = UIView(frame: scene.view!.bounds)
        self.backGroundView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        self.backGroundView.layer.position  = scene.view!.center
        self.addSubview(backGroundView)
        
        // ViewBackGround
        let board                 = UIView(frame: frame)
        board.backgroundColor     = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        board.layer.position      = backGroundView.center
        board.layer.masksToBounds = true
        board.layer.cornerRadius  = 20.0
        board.layer.borderColor   = UIColor.blackColor().CGColor
        board.layer.borderWidth   = 2.0
        self.addSubview(board)
    
        // Label 1
        let textView             = UILabel(frame: CGRectMake(0, 0, 180, 50))
        textView.shadowColor     = UIColor.grayColor()
        textView.textAlignment   = NSTextAlignment.Center
        textView.text            = "ユーザー名を入力してください"
        textView.sizeToFit();
        textView.layer.position  = CGPointMake(board.center.x, board.center.y - board.frame.size.height / 2 + 50)
        textView.backgroundColor = UIColor.clearColor()
        textView.textColor       = UIColor.blackColor()
        self.addSubview(textView)
        
        // InputView
        nameInputView.layer.position = CGPointMake(board.center.x, board.center.y - board.frame.size.height / 2 + 100)
        nameInputView.delegate       = self
        nameInputView.borderStyle    = UITextBorderStyle.RoundedRect
        nameInputView.returnKeyType  = UIReturnKeyType.Done
        nameInputView.keyboardType   = UIKeyboardType.Default
        self.addSubview(nameInputView)
        
        // Label 2
        let textView2             = UILabel(frame: CGRectMake(0, 0, 50, 20))
        textView2.shadowColor     = UIColor.grayColor()
        textView2.textAlignment   = NSTextAlignment.Center
        textView2.layer.position  = CGPointMake(board.center.x, board.center.y - board.frame.size.height / 2 + 130)
        textView2.backgroundColor = UIColor.clearColor()
        textView2.textColor       = UIColor.blackColor()
        textView2.text = "※" + String(minLength) + "〜" + String(maxLength) + "文字"
        textView2.sizeToFit();
        self.addSubview(textView2)
        
        //checkbox
        let checkBox     = UIButton(type: UIButtonType.Custom)
        let noCheckedImg = UIImage(named: "noChecked.png")
        let checkedImg   = UIImage(named: "checked.png")
        checkBox.frame   = CGRectMake(0, 0, 25, 25)
        checkBox.setBackgroundImage(noCheckedImg, forState:UIControlState.Normal)
        checkBox.setBackgroundImage(checkedImg, forState: UIControlState.Selected)
        checkBox.selected = false
        checkBox.layer.position  = CGPointMake(board.center.x - 80 , board.center.y - board.frame.size.height / 2 + 170)
        checkBox.addTarget(self, action: "check:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(checkBox)
        
        // Btn for webview
        let termsBtn             = UIButton(type: UIButtonType.Custom)
        termsBtn.frame           = CGRectMake(0, 0, 30, 20)
        termsBtn.backgroundColor = UIColor.clearColor()
        termsBtn.layer.position  = CGPointMake(board.center.x - 50, board.center.y - board.frame.size.height / 2 + 164)
        termsBtn.titleLabel?.textAlignment = NSTextAlignment.Left
        termsBtn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        termsBtn.setTitle("利用規約", forState: UIControlState.Normal)
        termsBtn.addTarget(self, action: "termsView:", forControlEvents: UIControlEvents.TouchUpInside)
        termsBtn.sizeToFit()
        self.addSubview(termsBtn)
        
        // Label 3
        let textView3             = UILabel(frame: CGRectMake(0, 0, 30, 20))
        textView3.text            = "に同意します"
        textView3.textAlignment   = NSTextAlignment.Left
        textView3.layer.position  = CGPointMake(board.center.x + 30 , board.center.y - board.frame.size.height / 2 + 170)
        textView3.backgroundColor = UIColor.clearColor()
        textView3.textColor       = UIColor.blackColor()
        textView3.sizeToFit();
        self.addSubview(textView3)
        
        // OKButton
        okButton.frame               = CGRectMake(0, 0, 100, 40)
        okButton.layer.masksToBounds = true
        okButton.backgroundColor     = UIColor.blueColor()
        okButton.layer.cornerRadius  = 20.0
        okButton.layer.position      = CGPointMake(board.center.x, board.center.y + board.frame.size.height / 2 - 50)
        okButton.setTitle("OK", forState: UIControlState.Normal)
        okButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        okButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        okButton.addTarget(self, action: "doSignUp:", forControlEvents: UIControlEvents.TouchUpInside)
        okButton.enabled = false
        self.addSubview(okButton)
        
    }
    
    // チェックボックスのオンオフ切り替え
    func check(sender: UIButton) {
        sender.selected = !sender.selected
        okButton.enabled = sender.selected
    }
    
    // 利用規約の表示
    func termsView(sender: UIButton) {
        let url =  NSURL (string: NCMBConfig.FILE_URL + "terms.html")
        webview.frame = self.bounds
        self.addSubview(webview)
        let urlRequest: NSURLRequest = NSURLRequest(URL: url!)
        webview.loadRequest(urlRequest)
        // 右方向へのスワイプ
        let gestureToRight       = UISwipeGestureRecognizer(target: self, action: "closeTerms")
        gestureToRight.direction = UISwipeGestureRecognizerDirection.Right
        webview.addGestureRecognizer(gestureToRight)
    }
    
    // 利用規約を閉じる
    func closeTerms() {
        webview.removeFromSuperview()
    }
    
    // サインアップ
    func doSignUp(sender: UIButton) {
        
        let name : String = nameInputView.text!
        if name.characters.count < minLength || name.characters.count > maxLength {
            nameInputView.text = "Enter Name at " + String(minLength) + "-" + String(maxLength) + "characters"
            return
        }
        
        self.scene.view!.paused = false
        self.scene.userInteractionEnabled = true
        self.removeFromSuperview()
        self.delegate?.signUp(name)
    }
    
    // textFieldShouldReturn
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
