/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

class PersistentStore {

    
    init() {
        if let archivedItems = NSKeyedUnarchiver.unarchiveObjectWithFile(fileRecordsArchiveURL.path!) as? [FileRecord] {
            fileRecords += archivedItems
        }
        else {
            fileRecords = [FileRecord]()
        }
    }
    
    // MARK: Sync Token
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var syncToken: String? {
        get {
            return defaults.objectForKey("syncToken") as! String?
        }
        set(newSyncToken) {
            if let _ = newSyncToken {
                defaults.setObject(newSyncToken, forKey: "syncToken")
            }
            else {
                defaults.removeObjectForKey("syncToken")
            }
        }
    }
   
    // MARK: File records
    var fileRecords = [FileRecord]()
    
    let fileRecordsArchiveURL: NSURL = {
        let documentsDirectories =
        NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent("fileRecords.archive")
    }()
    
    
    
    func processDeltaArrayForFoldeWithId(folderId:String, items: [DeltaItem]?) {
        
        for item:FileRecord in fileRecords {
            item.isNew = false;
        }
        
        if let nonNilItems = items {
            for item:DeltaItem in nonNilItems {
                if item.parentId == folderId {
                    print("\(item.fileId)   \(item.fileName)  isFolder:\(item.isFolder)    isDelete:\(item.isDelete)")
                    
                    if item.isDelete {
                        tryDeleteFile(item.fileId)
                    }
                    else {
                        tryCreateOrUpdateFile(item.fileId, fileName: item.fileName!, isFolder: item.isFolder, lastModified: item.lastModified)
                    }
                }
            }
        }
    }
    
    func tryDeleteFile(fileId: String) {
        for var index = fileRecords.count - 1; index >= 0 ; index-- {
            if fileRecords[index].fileId == fileId {
                print("==> delete \(fileRecords[index].fileName)")
                fileRecords.removeAtIndex(index)
            }
        }
    }
    
    func tryCreateOrUpdateFile(fileId: String, fileName: String, isFolder: Bool, lastModified: String) {

        // flag to indicate update 
        var updated = false
        
        for fileRecord: FileRecord in fileRecords {
            if fileRecord.fileId == fileId {
                print("file updated  \(fileRecord.fileName)  \(fileName)")
                updated = true
                fileRecord.fileName = fileName
                fileRecord.isNew = true
                fileRecord.dateModified = lastModified
            }
        }
        
        if updated == false {
            print("new file  \(fileName)   isFolder:\(isFolder)")
            let newRecord = FileRecord(fileId: fileId, fileName: fileName, dateModified: lastModified, isNew: true, isFolder: isFolder)
            fileRecords.append(newRecord)
        }
    }
    
    func createRecord(record: FileRecord) {
        fileRecords.append(record)
    }
    
    // MARK: Reset
    func resetStorage() {
        self.syncToken = nil
        fileRecords.removeAll()
    }
    
    func saveFileRecordChanges() -> Bool {
        return NSKeyedArchiver.archiveRootObject(fileRecords, toFile: fileRecordsArchiveURL.path!)
    }
    
    
    
    
}
