/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

struct DeltaItem {
    var fileId: String
    var fileName: String?
    var parentId: String?
    
    var isFolder: Bool
    var isDelete: Bool
    
    var lastModified: String

}