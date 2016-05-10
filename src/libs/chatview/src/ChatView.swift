import UIKit

class ChatView: UITableView, UITableViewDataSource, UITableViewDelegate{
    
    var itemes : [ChatModel] = []
    var someoneName  : String  = ""
    var someoneImage : UIImage = UIImage(named: "missingAvatar.png")!
    
    // init
    init(frame: CGRect) {
        super.init(frame: frame,  style: UITableViewStyle.Plain)
        self.backgroundColor                = UIColor(patternImage: UIImage(named: "main_back.png")!)
        self.separatorStyle                 = UITableViewCellSeparatorStyle.None
        self.showsVerticalScrollIndicator   = false
        self.showsHorizontalScrollIndicator = false
        self.registerClass(ChatViewCell.self, forCellReuseIdentifier: "tblBubbleCell")
        self.dataSource = self
        self.delegate   = self
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // セルの行数を指定
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemes.count
    }
    
    // セルの値を設定
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "tblBubbleCell"
        let cell : ChatViewCell = tableView.dequeueReusableCellWithIdentifier(cellId) as! ChatViewCell
        let data : ChatModel = self.itemes[indexPath.row]
        cell.setupData(data, someoneImage: someoneImage)
        return cell
    }
    
    // セルの高さを設定
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data    : ChatModel = self.itemes[indexPath.row]
        return max(data.insets.top + data.view.frame.size.height + data.insets.bottom, 52)
    }

    
    // Headerを追加
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 100))
        label.textAlignment = .Center
        label.backgroundColor = UIColor.blackColor()
        label.textColor = UIColor.whiteColor()
        label.text = self.someoneName
        
        return label
    }

    // Headerの高さ
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    

}
