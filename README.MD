# OneDrive Sync Sample for iOS

The OneDrive Sync Sample for iOS shows how to detect and sync file changes between a client app and the Microsoft OneDrive service in Office 365 for both online and offline scenarios.

![Files](https://github.com/OneDrive/onedrive-sample-sync-ios/blob/master/Images/FilesSync.png)

It demonstrates the following:

- Ability to sync between a client app files list and a user’s OneDrive for Business account by using the OneDrive **view.delta** API. The app will detect any modifications, including added, modified, and deleted files and folders. Any changes will be reported to the app UI.  For example, if someone deletes a file from the user’s drive on a laptop elsewhere, the client app will reflect the changes upon syncing.
- Allows the user to create an app folder and text file by using the OneDrive API for an organizational account in Office 365.


> Note: This app is written in Swift and doesn't support Microsoft account authentication. For more information on the view.delta API 
 see [View changes for a OneDrive Item and its children](https://dev.onedrive.com/items/view_delta.htm).
## Prerequisites
* [Xcode](https://developer.apple.com/xcode/downloads/) from Apple
* Installation of [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html) as a dependency manager.
* An Office 365 account. You can sign up for [an Office 365 Developer subscription](https://portal.office.com/Signup/Signup.aspx?OfferId=6881A1CB-F4EB-4db3-9F18-388898DAF510&DL=DEVELOPERPACK&ali=1#0) that includes the resources that you need to start building Office 365 apps.

> Note: If you already have a subscription, the link to sign up for a developer subscription sends you to a page with the message *Sorry, you can’t add that to your current account*. In that case, use an account from your current Office 365 subscription.
* A Microsoft Azure Tenant to register your application. Azure Active Directory (AD) provides identity services that applications use for authentication and authorization. A trial subscription can be acquired here: [Microsoft Azure](https://account.windowsazure.com/SignUp).

     > Important: You will also need to ensure your Azure subscription is bound to your Office 365 tenant. To do this, see the Active Directory team's blog post, [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). The section **Adding a new directory** will explain how to do this. You can also see [Set up your Office 365 development environment](https://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) and the section **Associate your Office 365 account with Azure AD to create and manage apps** for more information.
      
* The client id and redirect uri values of an application registered in Azure. This sample application must be granted the **Read and write user files** permission for **Office 365 SharePoint Online**. To create the registration, see **Register your native app with the Azure Management Portal** in [Manually register your app with Azure AD so it can access Office 365 APIs](https://msdn.microsoft.com/en-us/office/office365/howto/add-common-consent-manually) and [grant proper permissions](https://github.com/OneDrive/onedrive-sample-sync-ios/wiki/Grant-permissions-to-the-application-in-Azure) in the sample wiki to apply the proper permissions to it.


       
## Running this sample in Xcode

1. Clone this repository.
2. Use CocoaPods to import the Active Directory Authentication Library (ADAL) iOS dependency:
        
	     pod 'ADALiOS', '= 1.2.5'

 This sample app already contains a podfile that will get the ADAL components (pods) into  the project. Simply navigate to the project From **Terminal** and run: 
        
        pod install
        
   For more information, see **Using CocoaPods** in [Additional Resources](#AdditionalResources)
  
4. Open **AuthenticationConstants.swift** under **Library/Authentication**. You'll see that the **ClientID**, **RedirectUri**, and **tenant name** values can be added to the top of the file. Supply the necessary values here:

        // You will set your application's clientId, redirect URI, and tenant name. 
        static let ClientId    = "[ENTER_YOUR_CLIENT_ID]"
        static let RedirectUri = NSURL(string: "[ENTER_YOUR_REDIRECT_URI]")
        static let Authority   = "https://login.microsoftonline.com/common"
        static let ResourceId  = "https://YOUR_TENANT_NAME-my.sharepoint.com/"

5. Open **Info.plist** For the key **OneDrive base API URL** you'll need to supply your tenant name: 	**https://YOUR_TENANT_NAME-my.sharepoint.com/_api/v2.0**.   
6. Run the sample.

After authenticating you'll reach a page that lists the names of files and folders stored in the app. 

This list can be synced with the contents within the user's OneDrive for Business account by tapping the blue circular arrow icon in the bottom app bar. A blue checkmark will appear next to an item that is new or has been modified (like a file name change or the addition of a new file/folder). The red circular arrow will delete all view.delta sync tokens. Again, for more information on the view.delta API 
 see [View changes for a OneDrive Item and its children](https://dev.onedrive.com/items/view_delta.htm).



## Handling View.delta
The api **view.delta** is handled in OneDriverManager.swift under syncUsingViewDelta method. It accepts a sync token and the result is handled asynchronously by the completion block.
      
```swift
func syncUsingViewDelta(syncToken syncToken:String?,
        completion: (OneDriveManagerResult, newSyncToken: String?, deltaArray: [DeltaItem]?) -> Void) 
```        
      
        
If the number of items returned in the response is truncated: This happens if the number of items is too large or the 'top' query is used to purposely limit the number of items. In this case, paging can be used to fetch all items. This sample uses recursion to achieve paging. Basically, if view.delta's response contains **@odata.nextLink**, it calls the method recursively and appends the result to the delta item array.

```swift
func syncUsingViewDelta(syncToken syncToken:String?, nextLink: String?, var currentDeltaArray: [DeltaItem]?,
        completion: (OneDriveManagerResult, newSyncToken: String?, deltaArray: [DeltaItem]?) -> Void)
        
        ...
if let nextLink = json["@odata.nextLink"] as? String {
                            self.syncUsingViewDelta(syncToken: syncToken, nextLink: nextLink, currentDeltaArray: currentDeltaArray, completion: completion)
                        }
                        else {
                            completion(OneDriveManagerResult.Success, newSyncToken: deltaToken, deltaArray: currentDeltaArray)
                        }

        
```

## Questions and comments

We'd love to get your feedback about the OneDrive Sync Sample for iOS project. You can send your questions and suggestions to us in the [Issues](https://github.com/OneDrive/onedrive-sample-sync-ios/issues) section of this repository.

Questions about Office 365 development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions or comments are tagged with [Office365] and [OneDrive].

## Contributing
You will need to sign a [Contributor License Agreement](https://cla.microsoft.com/) before submitting your pull request. To complete the Contributor License Agreement (CLA), you will need to submit a request via the form and then electronically sign the CLA when you receive the email containing the link to the document. 


## Additional resources

* [Office Dev Center](http://dev.office.com/)
* [View changes for a OneDrive Item and its children](https://dev.onedrive.com/items/view_delta.htm).
* [Microsoft Graph overview page](https://graph.microsoft.io)
* [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## Copyright
Copyright (c) 2016 Microsoft. All rights reserved.

