import UIKit
import SpriteKit
import NCMB

class SettingScene: UIView, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let minLength = 1
    let maxLength = 6
    
    var backGroundView : UIView!
    var scene          : SKScene!
    var okButton       : UIButton     = UIButton(type: UIButtonType.Custom)
    var cancelButton   : UIButton     = UIButton(type: UIButtonType.Custom)
    var avatarImage    : UIImageView  = UIImageView()
    var nameInputView  : UITextField  = UITextField(frame: CGRectMake(0, 0, 250, 30))
    var imagePicker    : UIImagePickerController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 初期化処理
    init(scene : SKScene,frame : CGRect){
        
        super.init(frame: scene.view!.bounds)
        self.scene = scene
        self.scene.view!.paused = true
        
        self.scene.userInteractionEnabled = false
        for sprit in self.scene.children {
            sprit.userInteractionEnabled = false
        }
        self.layer.zPosition = 10
        
        // SceneOver
        self.backGroundView                 = UIView(frame: scene.view!.bounds)
        self.backGroundView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        self.backGroundView.layer.position  = scene.view!.center
        self.addSubview(backGroundView)
        
        // ViewBackGround
        let board                 = UIView(frame: frame)
        board.backgroundColor     = UIColor.greenColor()
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
        textView.text            = "ユーザー名"
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
        nameInputView.text           = UserData.getUserName()
        self.addSubview(nameInputView)
        
        // OKButton
        okButton.frame               = CGRectMake(0, 0, 100, 40)
        okButton.layer.masksToBounds = true
        okButton.backgroundColor     = UIColor.blueColor()
        okButton.layer.cornerRadius  = 20.0
        okButton.layer.position      = CGPointMake(board.center.x + 50, board.center.y + board.frame.size.height / 2 - 50)
        okButton.setTitle("OK", forState: UIControlState.Normal)
        okButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        okButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        okButton.addTarget(self, action: "submit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(okButton)
        
        // キャンセルButton
        cancelButton.frame               = CGRectMake(0, 0, 100, 40)
        cancelButton.layer.masksToBounds = true
        cancelButton.backgroundColor     = UIColor.whiteColor()
        cancelButton.layer.cornerRadius  = 20.0
        cancelButton.layer.position      = CGPointMake(board.center.x - 50, board.center.y + board.frame.size.height / 2 - 50)
        cancelButton.setTitle("キャンセル", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        cancelButton.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(cancelButton)
        
        // Label 2
        let textView2             = UILabel(frame: CGRectMake(0, 0, 180, 50))
        textView2.shadowColor     = UIColor.grayColor()
        textView2.textAlignment   = NSTextAlignment.Center
        textView2.text            = "アバター"
        textView2.sizeToFit();
        textView2.layer.position  = CGPointMake(board.center.x, board.center.y - board.frame.size.height / 2 + 150)
        textView2.backgroundColor = UIColor.clearColor()
        textView2.textColor       = UIColor.blackColor()
        self.addSubview(textView2)
        
        // Image
        avatarImage.image                  = UIImage(data: UserData.getImageData())
        avatarImage.frame                  = CGRectMake(0, 0, 50, 50)
        avatarImage.layer.cornerRadius     = 9.0
        avatarImage.layer.masksToBounds    = true
        avatarImage.layer.borderColor      = UIColor(white: 0.0, alpha: 0.2).CGColor
        avatarImage.layer.borderWidth      = 1.0
        avatarImage.layer.position         = CGPointMake(board.center.x, board.center.y - board.frame.size.height / 2 + 200)
        avatarImage.userInteractionEnabled = true
        avatarImage.tag                    = 1
        self.addSubview(avatarImage)
        
    }
    
    func submit(sender: UIButton) {
        okButton.enabled = false
        let name : String = nameInputView.text!
        if name.characters.count < minLength || name.characters.count > maxLength {
            nameInputView.text = "Enter Name at " + String(minLength) + "-" + String(maxLength) + "characters"
            okButton.enabled = true
            return
        }
        
        let user : NCMBUser = NCMBUser.currentUser()
        var error: NSError?
        user.setObject(name, forKey: "myName")
        // ユーザー登録
        user.save(&error)
        if let actualError = error {
            print("An Error Occurred: \(actualError)")
            okButton.enabled = true
            return
        }
        UserData.setUserName(name)
        // 画像登録
        let data : NSData   = UIImagePNGRepresentation(avatarImage.image!)!
        let file : NCMBFile = NCMBFile.fileWithName(user.userName, data: data) as! NCMBFile
        file.save(&error)
        if let actualError = error {
            print("An Error Occurred: \(actualError)")
            okButton.enabled = true
            return
        }
        UserData.setImageData(data)
        self.close(sender)
    }
    
    func close(sender: UIButton) {
        self.scene.view!.paused           = false
        self.scene.userInteractionEnabled = true
        for sprit in self.scene.children {
            sprit.userInteractionEnabled = true
        }
        self.removeFromSuperview()
    }
    
    func selectImage() {
        imagePicker               = UIImagePickerController()
        imagePicker.delegate      = self
        imagePicker.sourceType    = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.allowsEditing = false
        let vc = UIApplication.sharedApplication().keyWindow?.rootViewController! as! ViewController
        vc.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // didFinishPickingImage
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // resize
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // update view
        self.avatarImage.image  = resizeImage
        let vc                  = UIApplication.sharedApplication().keyWindow?.rootViewController! as! ViewController
        vc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // textFieldShouldReturn
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case 1:
                selectImage()
            default:
                break
            }
        }
    }
    
}
