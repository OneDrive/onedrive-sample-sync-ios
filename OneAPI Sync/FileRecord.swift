/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit


class FileRecord: NSObject, NSCoding {

    // indicate if this file has been modified/introduced in last sync
    var isNew: Bool

    // file attributes
    let fileId: String
    var fileName: String
    var isFolder: Bool
    var dateModified: String
    
    // keys for encoder/decoder
    let kFileIdKey: String       = "fileId"
    let kFileNameKey: String     = "fileName"
    let kIsNewKey: String        = "isNew"
    let kIsFolderKey: String     = "isFolder"
    let kDateModifiedKey: String = "dateModified"
    
    required init?(coder aDecoder: NSCoder) {
        fileId = aDecoder.decodeObjectForKey(kFileIdKey) as! String
        fileName = aDecoder.decodeObjectForKey(kFileNameKey) as! String
        isFolder = aDecoder.decodeBoolForKey(kIsFolderKey)
        dateModified = aDecoder.decodeObjectForKey(kDateModifiedKey) as! String
        
        isNew = aDecoder.decodeBoolForKey(kIsNewKey)

        super.init()
    }
    
    init(fileId: String, fileName: String, dateModified: String, isNew: Bool, isFolder: Bool) {
        self.fileId = fileId
        self.fileName = fileName
        self.isFolder = isFolder
        self.dateModified = dateModified
        
        self.isNew = isNew
        
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(fileId, forKey: kFileIdKey)
        aCoder.encodeObject(fileName, forKey: kFileNameKey)
        aCoder.encodeObject(dateModified, forKey: kDateModifiedKey)
        aCoder.encodeBool(isNew, forKey: kIsNewKey)
        aCoder.encodeBool(isFolder, forKey: kIsFolderKey)
        
    }
    
    
}
