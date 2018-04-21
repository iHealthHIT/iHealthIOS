//
//  WebUIController.swift
//  iHealthProject
//
//  Created by HealthJudge on 2018/4/21.
//  Copyright © 2018年 HealthHIT. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebUIController : UIViewController, WKUIDelegate {
    var url : URL?
    

    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: url!)
        webview.load(request)
    }
}
