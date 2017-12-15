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
        request = HTTPRequest.createHTTPRequest("http://google.com");
        request.delegate = self
        request.method = .get
        request.superTag = "GOOGLE"
        request.tag = "Search"
        HTTPQueue.push(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func requestDidFinish(_ request : HTTPRequest, status : HTTPRequestStatus) {
        if request.tag == "Search" {
            if status == .success {
                let str = String(data: request.ResultData!, encoding: .utf8)
                #if DEBUG
                    print(str)
                #endif
            }
        }
    }
}

