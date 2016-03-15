/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import Foundation

// You'll set your application's ClientId and RedirectURI here. These values are provided by your Microsoft Azure app
//registration. See README.MD for more details.

struct AuthenticationConstants {

    static let ClientId    = "[ENTER_YOUR_CLIENT_ID]"
    static let RedirectUri = NSURL(string: "[ENTER_YOUR_REDIRECT_URI]")
    static let Authority   = "https://login.microsoftonline.com/common"
    static let ResourceId  = "https://YOUR_TENANT_NAME-my.sharepoint.com/"

}


