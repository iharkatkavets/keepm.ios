//
//  GoogleDriveAuthorization.swift
//  iOSApp
//
//  Created by igork on 5/14/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import GTMAppAuth
import os.log

enum GoogleDriveAuthorizationError: Error {
    case signInError
}

typealias GDAuthCompletion = (Result<GTLRDriveService, GoogleDriveAuthorizationError>) -> Void

class GoogleDriveAuthorizationManager: NSObject {
    private var authCompletion: GDAuthCompletion?

    override init() {
        GIDSignIn.sharedInstance().clientID = "677190928280-modgi47oalv945l5816f2d1jdut073mc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDrive]
    }

    func signInWithPresentationViewController(_ viewController: UIViewController,
                                              completion: @escaping GDAuthCompletion) {
        assert(authCompletion == nil, "multiple attempts to perform login")
        authCompletion = completion

        DispatchQueue.main.async {
            GIDSignIn.sharedInstance().delegate = self
            if GIDSignIn.sharedInstance().hasPreviousSignIn() {
                GIDSignIn.sharedInstance().restorePreviousSignIn()
            }
            else {
                GIDSignIn.sharedInstance()?.presentingViewController = viewController
                GIDSignIn.sharedInstance()?.signIn()
            }
        }
    }

    func canSignInSilent() -> Bool {
        return GIDSignIn.sharedInstance().hasPreviousSignIn()
    }

    func signInSilent(completion: @escaping GDAuthCompletion) {
        assert(authCompletion == nil, "multiple attempts to perform login")
        authCompletion = completion
        
        DispatchQueue.main.async {
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().restorePreviousSignIn()
        }
    }
}

extension GoogleDriveAuthorizationManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        self.authCompletion = nil
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            self.authCompletion?(Result.failure(GoogleDriveAuthorizationError.signInError))
        }
        else {
            if let authorizer = user.authentication.fetcherAuthorizer() {
                let service = GTLRDriveService()
                service.authorizer = authorizer
                self.authCompletion?(Result.success(service))
            }
        }
        self.authCompletion = nil
    }
}
