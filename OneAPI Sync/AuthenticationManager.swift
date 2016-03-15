/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import Foundation

enum AuthenticationResult {
    case Success
    case Failure(ADAuthenticationError)
}


class AuthenticationManager {

    // MARK: Properties and variables
    // Singleton class
    class var sharedInstance: AuthenticationManager? {
        struct Singleton {
            static let instance = AuthenticationManager()
            
        }
        return Singleton.instance
    }

    // Internal properties
    var accessToken: String?
    var userInformation: ADUserInformation?
    
    // Private properties
    private let context: ADAuthenticationContext!

    // MARK: Initializer
    init?() {
        var error: ADAuthenticationError?
        guard let context = ADAuthenticationContext(authority: AuthenticationConstants.Authority, error: &error) else {
            print(error!.localizedDescription)
            self.context = nil
            return nil
        }
        self.context = context
    }
    
    // MARK: Authentication methods
    //Acquire and store access token and user information.
    func acquireAuthToken(completion: ((AuthenticationResult) -> Void)?) {
        self.context.acquireTokenWithResource(AuthenticationConstants.ResourceId,
            clientId: AuthenticationConstants.ClientId,
            redirectUri: AuthenticationConstants.RedirectUri,
            completionBlock:{
            (result:ADAuthenticationResult!) -> Void in
                
                if let handler = completion {
                    if result.status == AD_SUCCEEDED {
                        self.accessToken = result.accessToken
                        self.userInformation = result.tokenCacheStoreItem.userInformation
                        
                        handler(AuthenticationResult.Success)
                    }
                    else {
                        handler(AuthenticationResult.Failure(result.error))
                    }
                }
        })
    }
    
    
    //Clears the ADAL token cache and the cookie cache.
    func clearCredentials() {
        // Remove all the cookies from this application's sandbox. The authorization code is stored in the
        // cookies and ADAL will try to get to access tokens based on the auth code in the cookie.
        let cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = cookieStore.cookies {
            for cookie in cookies {
                cookieStore.deleteCookie(cookie)
            }
        }
        
        var error: ADAuthenticationError?
        context.tokenCacheStore.removeAllWithError(&error)
        if let _ = error {
            print(error)
        }
    }

}