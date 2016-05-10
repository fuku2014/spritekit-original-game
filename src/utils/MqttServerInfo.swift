import NCMB

final class MqttServerInfo {
    
    var domain   : String
    var port     : Int
    var user     : String
    var password : String
    
    static let shared = MqttServerInfo()
    
    private init() {
        // mbaasからMQTTサーバー情報を取得
        let query = NCMBQuery(className: "ServerInfo")
        query.whereKey("status", equalTo: true)
        let serverInfo = try! query.getFirstObject()
        
        self.domain   = (serverInfo.objectForKey("domain") as? String)!
        self.port     = (serverInfo.objectForKey("port") as? Int)!
        self.user     = (serverInfo.objectForKey("user") as? String)!
        self.password = (serverInfo.objectForKey("password") as? String)!
    }
}