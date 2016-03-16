# OneDrive Sync Sample for iOS

The OneDrive Sync Sample for iOS shows how to detect and sync file changes between a client app and the OneDrive service in Office 365 for both online and offline scenarios. It demonstrates the following:

- Ability to sync between a client app files list, and a user’s OneDrive for Business account using the OneDrive **view.delta** API.  The app will detect any modifications including added, modified, and deleted files and folders. Any changes to will be reported to the app UI.  For example, somebody deletes a file from the user’s drive on a laptop elsewhere, the client app will reflect the changes upon syncing.
- Allows the user to create an app folder and text file using the OneDrive API for an organizational account in Office 365


> Note: This app is written in Swift and doesn't support Microsoft account authentication.
 
## Prerequisites
* [Xcode](https://developer.apple.com/xcode/downloads/) from Apple
* Installation of [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)  as a dependency manager.
* An Office 365 account. You can sign up for [an Office 365 Developer subscription](https://portal.office.com/Signup/Signup.aspx?OfferId=6881A1CB-F4EB-4db3-9F18-388898DAF510&DL=DEVELOPERPACK&ali=1#0) that includes the resources that you need to start building Office 365 apps.

     > Note: If you already have a subscription, the previous link sends you to a page with the message *Sorry, you can’t add that to your current account*. In that case, use an account from your current Office 365 subscription.
* A Microsoft Azure tenant to register your application. Azure Active Directory (AD) provides identity services that applications use for authentication and authorization. A trial subscription can be acquired here: [Microsoft Azure](https://account.windowsazure.com/SignUp).

     > Important: You will also need to ensure your Azure subscription is bound to your Office 365 tenant. To do this, see the Active Directory team's blog post, [Creating and Managing Multiple Windows Azure Active Directories](http://blogs.technet.com/b/ad/archive/2013/11/08/creating-and-managing-multiple-windows-azure-active-directories.aspx). The section **Adding a new directory** will explain how to do this. You can also see [Set up your Office 365 development environment](https://msdn.microsoft.com/office/office365/howto/setup-development-environment#bk_CreateAzureSubscription) and the section **Associate your Office 365 account with Azure AD to create and manage apps** for more information.
      
* A client id and redirect uri values of an application registered in Azure. This sample application must be granted the **Read and write user files** permission for **Office 365 SharePoint Online**. To create the registration, see **Register your native app with the Azure Management Portal** in [Manually register your app with Azure AD so it can access Office 365 APIs](https://msdn.microsoft.com/en-us/office/office365/howto/add-common-consent-manually) and [grant proper permissions](https://github.com/OneDrive/onedrive-sample-sync-ios/wiki/Grant-permissions-to-the-application-in-Azure) in the sample wiki to apply the proper permissions to it.


       
## Running this sample in Xcode

1. Clone this repository
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


## Questions and comments

We'd love to get your feedback about the OneDrive Sync Sample for iOS project. You can send your questions and suggestions to us in the [Issues](https://github.com/OneDrive/onedrive-sample-sync-ios/issues) section of this repository.

Questions about Office 365 development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions or comments are tagged with [Office365] and [OneDrive].

## Contributing
You will need to sign a [Contributor License Agreement](https://cla.microsoft.com/) before submitting your pull request. To complete the Contributor License Agreement (CLA), you will need to submit a request via the form and then electronically sign the CLA when you receive the email containing the link to the document. 


## Additional resources

* [Office Dev Center](http://dev.office.com/)
* [Microsoft Graph overview page](https://graph.microsoft.io)
* [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## Copyright
Copyright (c) 2016 Microsoft. All rights reserved.

