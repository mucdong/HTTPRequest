//
//  ViewController.swift
//  HTTPRequest
//
//  Created by mucdong on 07/10/2017.
//  Copyright (c) 2017 mucdong. All rights reserved.
//

import UIKit
import HTTPRequest

class ViewController: UIViewController, HTTPRequestDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var request : HTTPRequest
        request = HTTPRequest.createHTTPRequest("http://vnexpress.net");
        request.Delegate = self
        request.Method = .get
        request.SuperTag = "GOOGLE"
        request.Tag = "Search"
        HTTPQueue.push(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func requestDidFinish(_ request : HTTPRequest, status : HTTPRequestStatus) {
        if request.Tag == "Search" {
            if status == .success {
                let str = String(data: request.ResultData!, encoding: .utf8)
                #if DEBUG
                    print(str)
                #endif
            }
        }
    }
}

