/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

enum OneDriveManagerResult {
    case Success
    case Failure(OneDriveAPIError)
}

enum OneDriveAPIError: ErrorType {
    case ResourceNotFound
    case JSONParseError
    case UnspecifiedError(NSURLResponse?)
    case GeneralError(ErrorType?)
}

class OneDriveManager : NSObject {
    
    var baseURL: String = NSBundle.mainBundle().objectForInfoDictionaryKey("OneDrive base API URL") as! String
    
    var accessToken: String! {
        get {
            return AuthenticationManager.sharedInstance?.accessToken
        }
    }
    
    // MARK: Definitions
    let kAppFolderPath = "OneAPI"
    
    
    override init() {
        super.init()
    }
    
    
    // MARK: Step 1 - folder creation/retrieval
    func getAppFolderId(completion: (OneDriveManagerResult, appFolderId: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(baseURL)/me/drive/special/approot:/")!)
        
        request.HTTPMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            if let someError = error {
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.GeneralError(someError)), appFolderId: nil)
                return
            }
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            print("status code = \(statusCode)")
            
            switch(statusCode) {
                
            case 200:
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                    
                    guard let folderId = json["id"] as? String else {
                        completion(OneDriveManagerResult.Failure(OneDriveAPIError.UnspecifiedError(response)), appFolderId: nil)
                        return
                    }
                    completion(OneDriveManagerResult.Success, appFolderId: folderId)
                }
                catch{
                    completion(OneDriveManagerResult.Failure(OneDriveAPIError.JSONParseError), appFolderId: nil)
                }
                
            case 404:
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.ResourceNotFound), appFolderId: nil)
                
            default:
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.UnspecifiedError(response)), appFolderId: nil)
                
            }
        })
        
        task.resume()
    }
    
    
    
    func createTextFile(fileName:String, folderId:String, completion: (OneDriveManagerResult) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(baseURL)/me/drive/special/approot:/\(fileName):/content")!)
        request.HTTPMethod = "PUT"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")


        request.HTTPBody = ("This is a test text file" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            
            if let someError = error {
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.GeneralError(someError)))
                return
            }
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            print("status code = \(statusCode)")
            
            switch(statusCode) {
            case 200, 201:
                completion(OneDriveManagerResult.Success)
            default:
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.UnspecifiedError(response)))
            }
        })
        task.resume()
    }

    
    func createFolder(folderName:String, folderId:String, completion: (OneDriveManagerResult) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(baseURL)/me/drive/special/approot:/\(folderName)")!)
        request.HTTPMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let emptyParams = Dictionary<String, String>()
        let params = ["name":folderName,
                      "folder":emptyParams,
                      "@name.conflictBehavior":"rename"]
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            
            if let someError = error {
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.GeneralError(someError)))
                return
            }
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            switch(statusCode) {
            case 200, 201:
                completion(OneDriveManagerResult.Success)
            default:
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.UnspecifiedError(response)))
            }
        })
        task.resume()
    }

    
    
        
    func syncUsingViewDelta(syncToken syncToken:String?,
        completion: (OneDriveManagerResult, newSyncToken: String?, deltaArray: [DeltaItem]?) -> Void) {

            let request: NSMutableURLRequest
            
            
            if let sToken = syncToken {
                request = NSMutableURLRequest(URL: NSURL(string: "\(baseURL)/me/drive/root/view.delta?token=\(sToken)")!)
            }
            else {
                request = NSMutableURLRequest(URL: NSURL(string: "\(baseURL)/me/drive/root/view.delta")!)
            }
            
            
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            
            if let someError = error {
                print("error \(error?.localizedDescription)")
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.GeneralError(someError)),newSyncToken: nil, deltaArray: nil)
                return
            }
            
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            print("status code = \(statusCode)")
            
            switch(statusCode) {
            case 200:
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                    
                    guard let deltaToken = json["@delta.token"] as? String else {
                        completion(OneDriveManagerResult.Failure(OneDriveAPIError.UnspecifiedError(response)), newSyncToken: nil, deltaArray: nil)
                        return
                    }
                    
                    print("delta token = \(deltaToken)")
                    
                    var deltaItems = [DeltaItem]()
                    
                    if let items = json["value"] as? [[String: AnyObject]] {
                        for item in items {
                            var fileId: String
                            var fileName: String?
                            var isFolder: Bool
                            var isDelete: Bool
                            var parentId: String?
                            var lastModified: String
                            
                            fileId = item["id"] as! String

                            let lastModifiedRaw = item["lastModifiedDateTime"] as! String
                            lastModified = self.localTimeStringFromGMTTime(lastModifiedRaw)
                            
                            fileName = item["name"] as? String

                            
                            if let _ = item["folder"] {
                                isFolder = true
                            }
                            else {
                                isFolder = false
                            }
                            
                            if let _ = item["deleted"] {
                                isDelete = true
                            }
                            else {
                                isDelete = false
                            }
                            
                            if let parentReference = item["parentReference"] as? [String: AnyObject] {
                                parentId = parentReference["id"] as? String
                            }
                            
                            let deltaItem = DeltaItem(
                                fileId: fileId,
                                fileName: fileName,
                                parentId: parentId,
                                isFolder: isFolder,
                                isDelete: isDelete,
                                lastModified: lastModified)
                            
                            deltaItems.append(deltaItem)
                        }
                    }
                    completion(OneDriveManagerResult.Success, newSyncToken: deltaToken, deltaArray: deltaItems)
                }
                catch{
                    completion(OneDriveManagerResult.Failure(OneDriveAPIError.JSONParseError), newSyncToken: nil, deltaArray: nil)
                }
                
            default:
                completion(OneDriveManagerResult.Failure(OneDriveAPIError.UnspecifiedError(response)), newSyncToken: nil, deltaArray: nil)
            }
        })
        
        task.resume()
    }
    
    func localTimeStringFromGMTTime(gmtTime: String) -> String {
        
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateFormatterFrom = NSDateFormatter()
        dateFormatterFrom.locale = locale
        dateFormatterFrom.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatterFrom.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        
        let lastModifiedDate = dateFormatterFrom.dateFromString(gmtTime)
        
        let dateFormatterTo = NSDateFormatter()
        dateFormatterTo.locale = locale
        dateFormatterTo.timeZone = NSTimeZone.localTimeZone()
        dateFormatterTo.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        
        return dateFormatterTo.stringFromDate(lastModifiedDate!)
    }
    
}








