//
//  ClientManager.swift
//  ElasticSwiftSample-iOS
//
//  Created by Prafull Kumar Soni on 3/11/18.
//  Copyright © 2018 pksprojects. All rights reserved.
//

import Foundation
import NotificationCenter
import ElasticSwift
import ElasticSwiftNetworking

class ClientManager {
    
    private var _client: ElasticClient? {
        didSet {
            NotificationCenter.default.post(name: AppNotifications.connectionUpdated, object: _client)
        }
    }
    
    init() {
        self.connect(scheme: "http", host: "192.168.1.142", port: 9200, username: nil, password: nil)
    }
    
    public var client: ElasticClient {
        get {
            return _client!
        }
    }
    
    public func connect(scheme: String, host: String, port: Int, username: String?, password: String?) {
        
        let certPath = Bundle.main.path(forResource: "elastic-certificates", ofType: "der")
        let sslConfig =  SSLConfiguration(certPath: certPath!, isSelf: true)
        var cred: BasicClientCredential?
        var component = URLComponents()
        var host = host
        if(host.starts(with: "https://")) {
            host = host.replacingOccurrences(of: "https://", with: "")
            component.scheme = "https"
        } else if(host.starts(with: "http://")) {
            host = host.replacingOccurrences(of: "http://", with: "")
        }
        
        if let uname = username, let pass = password {
            cred = BasicClientCredential(username: uname, password: pass)
        }
        component.scheme = scheme
        component.host =  host
        component.port = port
        
        let url = component.url
        let adaptorConfig = URLSessionAdaptorConfiguration(sslConfig: sslConfig)
        let settings = Settings.init(forHosts: [(url?.absoluteString)!], withCredentials: cred, adaptorConfig: adaptorConfig)
        
        _client = ElasticClient(settings: settings)
        
    }
}
