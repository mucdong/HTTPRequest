//
//  HTTPRequest.swift
//  HTTPRequestLib
//
//  Created by Đoàn Nguyễn on 9/23/16.
//  Copyright © 2016 PlayUp. All rights reserved.
//

import Foundation
import UIKit

public enum HTTPPostMediaParameterType {
    case image
    case audio
    case video
}

/**
 * This class is Media Parameter (photo, music, video)
 */
open class HTTPPOSTMediaParameter {
    private var paramType : HTTPPostMediaParameterType
    private var fieldName : String
    private var fileName : String
    private var fieldData : Data
    
    open var ParamType : HTTPPostMediaParameterType {
        get {
            return paramType
        }
    }
    
    open var Name : String {
        get {
            return fieldName
        }
        set {
            fieldName = newValue
        }
    }
    
    open var FileName : String {
        get {
            return fileName
        }
        set {
            fileName = newValue
        }
    }
    
    open var FieldData : Data {
        get {
            return fieldData
        }
        set {
            fieldData = newValue
        }
    }
    
    public init(type : HTTPPostMediaParameterType) {
        paramType = type
        fieldName = ""
        fileName = ""
        fieldData = Data()
    }
}

public enum HTTPRequestStatus{
    case success
    case error
    case timeout
    case cancelled
}

public enum HTTPMethod {
    case get
    case post
}

public enum HTTPPostParameterType {
    case urlEncode
    case json
    case formData
}

public class HTTPRequest: NSObject, URLSessionDataDelegate {
    private weak var delegate : HTTPRequestDelegate?
    internal weak var queueDelegate : HTTPRequestQueueDelegate?
    
    private var url : String?
    private var session : Foundation.URLSession?
    private var dataTask: URLSessionDataTask?
    private var resultData : Data?
    private var userInfo : [String : String]?
    private var method : HTTPMethod
    private var responseTotalSize : Float?;
    private var isChecked : Bool
    private var isImageData : Bool
    private var isCancelled : Bool
    private var tag : String?
    private var superTag : String?
    private var requestTimeout : Float
    
    //for Header
    private var headers : [String : String]?
    
    //for POST
    private var postParamType : HTTPPostParameterType?
    private var postTextData : [(key: String, value: String)]?
    private var postMediaParams : Array<HTTPPOSTMediaParameter>?
    private var authenticationChallenge : (username:String, password:String)?
    
    // MARK: Setter, Getter
    open var Delegate : HTTPRequestDelegate? {
        get {
            return delegate
        }
        set {
            delegate = newValue
        }
    }
    open var Url : String? {
        get {
            return url
        }
    }
    
    open var ResultData : Data? {
        get {
            return resultData
        }
    }
    
    open var UserInfo : [String : String]? {
        get {
            return userInfo
        }
        set {
            userInfo = newValue
        }
    }
    
    open var Method : HTTPMethod {
        get {
            return method
        }
        set {
            method = newValue
        }
    }
    
    open var IsImageData : Bool {
        get {
            return isImageData
        }
        set {
            isImageData = newValue
        }
    }
    
    open var IsCancelled : Bool {
        get {
            return isCancelled
        }
    }
    
    open var Tag : String? {
        get {
            return tag
        }
        set {
            tag = newValue
        }
    }
    
    open var SuperTag : String? {
        get {
            return superTag
        }
        set {
            superTag = newValue
        }
    }
    
    open var RequestTimeOut : Float {
        get {
            return requestTimeout
        }
        set {
            requestTimeout = newValue
        }
    }
    
    open var HeaderParams : [String : String]? {
        get {
            return headers
        }
        set {
            headers = newValue
        }
    }
    
    open var POSTParamType : HTTPPostParameterType? {
        get {
            return postParamType
        }
        set {
            postParamType = newValue
        }
    }
    
    open var POSTTextData : [(key: String, value : String)]? {
        get {
            return postTextData
        }
        set {
            postTextData = newValue
        }
    }
    
    open var POSTMediaParams : Array<HTTPPOSTMediaParameter>? {
        get {
            return postMediaParams
        }
        set {
            postMediaParams = newValue
        }
    }
    
    open var AuthenticationChallenge : (username:String, password:String)? {
        get {
            return authenticationChallenge
        }
        set {
            authenticationChallenge = newValue
        }
    }
    
    override public init() {
        method = HTTPMethod.get
        isChecked = false
        isImageData = false
        isCancelled = false
        requestTimeout = 60
        postParamType = .formData
    }
    
    convenience public init?(_ url : String) {
        if url.isEmpty {
            return nil;
        }
        
        self.init()
        self.url = url
    }
    
    // MARK: Public Methods
    /**
     * Class method - create new HTTP Request
     * url of request
     */
    open static func createHTTPRequest(_ url : String) -> HTTPRequest {
        return HTTPRequest(url)!
    }
    
    fileprivate func startRequest() {
        if method == .get {
            let oURL = URL(string: url!)
            
            if oURL == nil {
                if delegate != nil {
                    delegate!.requestDidFinish(self, status: .error)
                }
                return
            }
            
            var request = URLRequest(url: oURL!)
            request.httpMethod = "GET"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.timeoutInterval = TimeInterval(requestTimeout)
            
            if headers != nil {
                for (key, value) in headers! {
                    request.setValue(value, forHTTPHeaderField:key)
                }
            }
            session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
            /*dataTask = session!.dataTask(with: request, completionHandler: {
                (data, response, error) in
                
                self.cancelCheckTimeout()
                
                guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                    if self.delegate != nil && !self.isCancelled {
                        self.delegate!.requestDidFinish(self, status: .error)
                    }
                    return
                }
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(dataString)
                self.resultData = data
                if self.delegate != nil && !self.isCancelled {
                    self.delegate!.requestDidFinish(self, status: .success)
                }
                
            })*/
            dataTask = session!.dataTask(with: request)
            dataTask!.resume()
            
            
        } else {
            //post
            let oURL = URL(string: url!)
            
            if oURL == nil {
                if delegate != nil {
                    delegate!.requestDidFinish(self, status: .error)
                }
                return
            }
            
            var request = URLRequest(url: oURL!)
            request.httpMethod = "POST"
            request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
            request.timeoutInterval = TimeInterval(requestTimeout)
            if headers != nil {
                for (key, value) in headers! {
                    request.setValue(value, forHTTPHeaderField:key)
                }
            }
            
            if postParamType == HTTPPostParameterType.formData{
                let boundary = "----MDHTTPFormBoundaryE19zNvXGzXaLvS5C";
                let contentType = "multipart/form-data; boundary=\(boundary)"
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
                //POST body
                let body : NSMutableData = NSMutableData()
                
                //add Text param
                if postTextData != nil {
                    for (key, value) in postTextData! {
                        var data = "--\(boundary)\r\n"
                        body.append(data.data(using: String.Encoding.utf8)!)
                        
                        data = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                        body.append(data.data(using: String.Encoding.utf8)!)
                        
                        data = "\(value)\r\n"
                        body.append(data.data(using: String.Encoding.utf8)!)
                    }
                }
                
                //add Media param
                if postMediaParams != nil {
                    for param in postMediaParams! {
                        var data = "--\(boundary)\r\n"
                        body.append(data.data(using: String.Encoding.utf8)!)
                        
                        data = "Content-Disposition: form-data; name=\"\(param.Name)\"; filename=\"\(param.FileName)\"\r\n"
                        body.append(data.data(using: String.Encoding.utf8)!)
                        
                        if param.ParamType == HTTPPostMediaParameterType.image {
                            data = "Content-Type: image/png\r\n\r\n"
                        } else if param.ParamType == HTTPPostMediaParameterType.audio {
                            data = "Content-Type: audio/mp3\r\n\r\n"
                        } else {
                            data = "Content-Type: video/mp4\r\n\r\n"
                        }
                        body.append(data.data(using: String.Encoding.utf8)!)
                        body.append(param.FieldData)
                        
                        data = "\r\n"
                        body.append(data.data(using: String.Encoding.utf8)!)
                    }
                }
                
                let data = "--\(boundary)--\r\n"
                body.append(data.data(using: String.Encoding.utf8)!)
                
                request.httpBody = body as Data
            } else {
                var content = ""
                if postParamType == HTTPPostParameterType.json {
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                } else {
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                }
                
                if postTextData != nil {
                    for (key, value) in postTextData! {
                        if content.characters.count == 0 {
                            content = content + "\(key)=\(value)"
                        } else {
                            content = content + "&\(key)=\(value)"
                        }
                    }
                    
                    let requestData : Data? = content.data(using: String.Encoding.utf8)
                    request.setValue("\(content.characters.count)", forHTTPHeaderField: "Content-Length")
                    request.httpBody = requestData
                }
            }
            
            
            session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
            /*dataTask = session!.dataTask(with: request, completionHandler: {
                (data, response, error) in
                
                self.cancelCheckTimeout()
                
                guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                    if self.delegate != nil && !self.isCancelled {
                        self.delegate!.requestDidFinish(self, status: .error)
                    }
                    return
                }
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(dataString)
                self.resultData = data
                if self.delegate != nil && !self.isCancelled {
                    self.delegate!.requestDidFinish(self, status: .success)
                }
                
            })*/
            
            dataTask = session!.dataTask(with: request)
            dataTask!.resume()
        }
        
        isCancelled = false
        isChecked = false
        self.perform(#selector(checkRequestTimeout), with: nil, afterDelay:TimeInterval(requestTimeout))
    }
    
    open func cancelRequest() {
        
        self.cancelCheckTimeout()
        
        if dataTask != nil {
            dataTask!.cancel()
        }
        
        if resultData != nil {
            resultData = nil
        }
        
        if session != nil {
            session!.invalidateAndCancel()
            session = nil
        }
        
        isCancelled = true
    }
    
    // MARK: NSURLSessionDataDelegate methods
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if resultData == nil {
            self.cancelCheckTimeout()
            resultData = data
        } else {
            resultData?.append(data);
        }
        
#if DEBUG
        let str = String(data: resultData!, encoding: .utf8)
        print(str)
#endif
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if response is  HTTPURLResponse{
            let httpResponse : HTTPURLResponse = response as! HTTPURLResponse
            if httpResponse.statusCode / 100 != 2 {
                requestCompleted(status: .error)
                cancelRequest()
                completionHandler(Foundation.URLSession.ResponseDisposition.cancel)
            } else {
                if isImageData && response.mimeType != "image/jpg" && response.mimeType == "image/jpeg" && response.mimeType == "image/png" && response.mimeType != "image/gif"{
                    completionHandler(Foundation.URLSession.ResponseDisposition.cancel)
                    requestCompleted(status: .error)
                    cancelRequest()
                }
            }
            
            completionHandler(Foundation.URLSession.ResponseDisposition.allow)
        } else {
            completionHandler(Foundation.URLSession.ResponseDisposition.cancel)
        }
    }
    
    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.previousFailureCount == 0 && authenticationChallenge != nil {
            let newCredential = URLCredential(user: authenticationChallenge!.username, password: authenticationChallenge!.password, persistence: .none)
            challenge.sender?.use(newCredential, for: challenge)
        } else {
            challenge.sender?.cancel(challenge)
        }
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            requestCompleted(status: .success)
        } else {
            requestCompleted(status: .error)
        }
        
        session.finishTasksAndInvalidate()
    }
    
    // MARK: Private methods
    private func requestCompleted(status: HTTPRequestStatus) {
        self.cancelCheckTimeout()
        
        if delegate != nil && !isCancelled && !isChecked {
            delegate!.requestDidFinish(self, status: status)
        }
        
        if queueDelegate != nil {
            queueDelegate!.requestDidFinish(self)
        }
    }
    
    @objc private func cancelCheckTimeout() {
        if !isChecked {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(checkRequestTimeout), object: nil)
        }
    }
    
    @objc private func checkRequestTimeout() {
        if !isChecked {
            isChecked = true
            
            if delegate != nil {
                delegate?.requestDidFinish(self, status: .timeout)
            }
            
            cancelRequest()
        }
    }
}

// MARK: Define Protocol
public protocol HTTPRequestDelegate : class {
    func requestDidFinish(_ request : HTTPRequest, status : HTTPRequestStatus)
}

public protocol HTTPRequestQueueDelegate : class {
    func requestDidFinish(_ request : HTTPRequest)
}

open class HTTPQueue : HTTPRequestQueueDelegate {
    private static var shareImageQueue : HTTPQueue?
    private static var shareDataQueue : HTTPQueue?
    
    private var requests : Array<HTTPRequest> = Array<HTTPRequest>()
    private var sendingIndex : Int = -1
    
    private static var ShareImageQueue : HTTPQueue! {
        get {
            if shareImageQueue == nil {
                shareImageQueue = HTTPQueue()
            }
            
            return shareImageQueue
        }
    }
    
    private static var ShareDataQueue : HTTPQueue! {
        get {
            if shareDataQueue == nil {
                shareDataQueue = HTTPQueue()
            }
            
            return shareDataQueue
        }
    }
    
    // MARK: Class methods
    class open func push(_ request : HTTPRequest) {
        if request.IsImageData {
            HTTPQueue.ShareImageQueue.add(request)
        } else {
            HTTPQueue.ShareDataQueue.add(request)
        }
    }
    
    class open func removeRequest(_ request : HTTPRequest) {
        if request.IsImageData {
            HTTPQueue.ShareImageQueue.cancelRequest(request)
        } else {
            HTTPQueue.ShareDataQueue.cancelRequest(request)
        }
    }
    
    class open func removeAllRequests() {
        HTTPQueue.ShareImageQueue.cancelAllRequests()
        HTTPQueue.ShareDataQueue.cancelAllRequests()
    }
    
    class open func removeRequestsByTag(_ tag : String!) {
        HTTPQueue.ShareImageQueue.cancelRequestsByTag(tag)
        HTTPQueue.ShareDataQueue.cancelRequestsByTag(tag)
    }
    
    class open func removeRequestsBySuperTag(_ tag : String!) {
        HTTPQueue.ShareImageQueue.cancelRequestsBySuperTag(tag)
        HTTPQueue.ShareDataQueue.cancelRequestsBySuperTag(tag)
    }
    
    // MARK: HTTPRequestDelegate methods
    public func requestDidFinish(_ request : HTTPRequest) {
        var i = 0
        while i < requests.count {
            let req = requests[i]
            if req == request {
                requests.remove(at: i)
                break
            }
            i += 1
        }
        
        if requests.count > 0 {
            sendingIndex = -1
            sendRequest()
        }
    }
    
    // MARK: Private methods
    private func add(_ request : HTTPRequest) {
        request.queueDelegate = self
        requests.append(request)
        
        if requests.count == 1 {
            sendRequest()
        }
    }
    
    private func sendRequest() {
        if requests.count == 0 {
            sendingIndex = -1
            return
        }
        
        sendingIndex = 0
        let request : HTTPRequest! = requests[sendingIndex]
        request.startRequest()
    }
    
    private func cancelRequest(_ request : HTTPRequest) {
        request.cancelRequest()
        var i = 0
        while i < requests.count {
            let req = requests[i]
            if req == request {
                requests.remove(at: i)
                
                if i == sendingIndex {
                    sendingIndex = -1
                    sendRequest()
                }
                
                break
            }
            i += 1
        }
    }
    
    private func cancelAllRequests() {
        while requests.count > 0 {
            let request = requests[0]
            request.cancelRequest()
            requests.remove(at: 0)
            
        }
    }
    
    private func cancelRequestsByTag(_ tag : String!) {
        var resend = false
        var i = 0
        while i < requests.count {
            let request = requests[i]
            if request.Tag == tag {
                request.cancelRequest()
                requests.remove(at: i)
                
                if i == sendingIndex {
                    resend = true
                }
            } else {
                i += 1
            }
        }
        
        if resend {
            sendingIndex = -1
            sendRequest()
        }
    }
    
    private func cancelRequestsBySuperTag(_ supertag : String!) {
        var resend = false
        var i : Int = 0
        while i < requests.count {
            let request = requests[i]
            if request.SuperTag == supertag {
                request.cancelRequest()
                requests.remove(at: i)
                if i == sendingIndex {
                    resend = true
                }
            } else {
                i += 1
            }
        }
        if resend {
            sendingIndex = -1
            sendRequest()
        }
    }
}
