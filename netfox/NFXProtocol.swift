//
//  NFXProtocol.swift
//  netfox
//
//  Copyright © 2015 kasketis. All rights reserved.
//

import Foundation

@objc
open class NFXProtocol: URLProtocol
{
    var connection: NSURLConnection?
    var model: NFXHTTPModel?
    
    override open class func canInit(with request: URLRequest) -> Bool
    {
        return canServeRequest(request)
    }
    
    override open class func canInit(with task: URLSessionTask) -> Bool
    {
        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }
    
    fileprivate class func canServeRequest(_ request: URLRequest) -> Bool
    {
        if !NFX.sharedInstance().isEnabled() {
            return false
        }
        
        if let url = request.url {
            if (!(url.absoluteString.hasPrefix("http")) && !(url.absoluteString.hasPrefix("https"))) {
                return false
            }

            for ignoredURL in NFX.sharedInstance().getIgnoredURLs() {
                if url.absoluteString.hasPrefix(ignoredURL) {
                    return false
                }
            }
            
        } else {
            return false
        }
        
        if URLProtocol.property(forKey: "NFXInternal", in: request) != nil {
            return false
        }
        
        return true
    }
    
    override open func startLoading()
    {
        self.model = NFXHTTPModel()
                
        var req: NSMutableURLRequest
        req = (NFXProtocol.canonicalRequest(for: request) as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        self.model?.saveRequest(req as URLRequest)
        
        let session = URLSession.shared
        session.dataTask(with: req as URLRequest, completionHandler: {data, response, error in
            
            if error != nil {
                self.loaded()
                self.client?.urlProtocol(self, didFailWithError: error!)
                
            } else {
                if ((data) != nil) {
                    self.model?.saveResponse(response!, data: data!)
                }
                self.loaded()
            }
            
            if (response != nil) {
                self.client!.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
            }
            
            if (data != nil) {
                self.client!.urlProtocol(self, didLoad: data!)
            }
            
            if let client = self.client {
                client.urlProtocolDidFinishLoading(self)
            }

            
        }).resume()
    }
    
    override open func stopLoading()
    {
        
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest
    {
        return request
    }
    
    func loaded()
    {
        if (self.model != nil) {
            NFXHTTPModelManager.sharedInstance.add(self.model!)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "NFXReloadData"), object: nil)
    }
    
}
