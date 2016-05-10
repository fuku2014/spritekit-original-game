
import UIKit

class ChatViewCell: UITableViewCell {
    
    var data        : ChatModel!  = nil
    var customView  : UIView      =  UIView()
    var bubbleImage : UIImageView = UIImageView()
    var avatarImage : UIImageView = UIImageView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        //First Call Super
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle  = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor(patternImage: UIImage(named: "main_back.png")!)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func setupData(data : ChatModel, someoneImage : UIImage) {
        
        
        self.addSubview(self.bubbleImage)
        
        self.data = data
        
        let type = self.data.type
        
        let width  : CGFloat = self.data.view.frame.size.width
        let height : CGFloat = self.data.view.frame.size.height
        
        
        var x : CGFloat  = type == NSBubbleType.BubbleTypeSomeoneElse ? 0 : UIScreen.mainScreen().bounds.size.width - width - self.data.insets.left - self.data.insets.right
        var y : CGFloat = 0
        
        self.avatarImage.removeFromSuperview()
        self.avatarImage.image =  type == NSBubbleType.BubbleTypeSomeoneElse ? someoneImage : UIImage(data: UserData.getImageData())
        self.avatarImage.layer.cornerRadius  = 9.0
        self.avatarImage.layer.masksToBounds = true
        self.avatarImage.layer.borderColor   = UIColor(white: 0.0, alpha: 0.2).CGColor
        self.avatarImage.layer.borderWidth   = 1.0
        

        let avatarX : CGFloat = type == NSBubbleType.BubbleTypeSomeoneElse ? 2 : UIScreen.mainScreen().bounds.size.width - 52
        let avatarY : CGFloat = max(self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height, 52) - 50
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50)
        self.addSubview(self.avatarImage)
        

        
        let delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height)
        if delta > 0 {
            y = delta
        }
        if type == NSBubbleType.BubbleTypeSomeoneElse {
            x += 54
        }
        if type == NSBubbleType.BubbleTypeMine {
            x -= 54
        }
        
        self.customView.removeFromSuperview()
        self.customView = self.data.view
        self.customView.frame = CGRectMake(self.data.insets.left, self.data.insets.top, width, height)
        self.bubbleImage.addSubview(self.customView)
        
        if type == NSBubbleType.BubbleTypeSomeoneElse {
            self.bubbleImage.image = UIImage(named: "bubbleSomeone.png")?.stretchableImageWithLeftCapWidth(21, topCapHeight: 14)
        } else {
            self.bubbleImage.image = UIImage(named: "bubbleMine.png")?.stretchableImageWithLeftCapWidth(15, topCapHeight: 14)
        }
        self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom)

        
    }

}
