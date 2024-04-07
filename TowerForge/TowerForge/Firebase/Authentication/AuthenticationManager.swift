//
//  AuthenticationManager.swift
//  TowerForge
//
//  Created by MacBook Pro on 08/04/24.
//

import Foundation
import FirebaseAuth

protocol AuthenticationDelegate: AnyObject {
    func onLogout()
    func onLogin(email: String)
}

class AuthenticationManager: AuthenticationProtocol {
   private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var delegate: AuthenticationDelegate?
    init(delegate: AuthenticationDelegate) {
       // Start observing authentication state changes
        self.delegate = delegate
       authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
           if let user = user, let email = user.email {
               let userData = AuthenticationData(userId: user.uid, email: email)
               self?.delegate?.onLogin(email: email)
           } else {
               self?.delegate?.onLogout()
           }
       }
   }
   
   deinit {
       // Remove the authentication state listener when deinitializing the manager
       if let handle = authStateHandle {
           Auth.auth().removeStateDidChangeListener(handle)
       }
   }
    func registerUser(data: AuthenticationData, password: String, completion: @escaping (AuthenticationData?, Error?) -> Void) {
        guard !data.email.isEmpty, !password.isEmpty else {
            return
        }
        Auth.auth().createUser(withEmail: data.email, password: password) { _, error in
            if error != nil {
                print("Error in creating user")
            } else {
                Auth.auth().signIn(withEmail: data.email, password: password)
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (AuthenticationData?, Error?) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if let err = err, res == nil {
                completion(nil, err)
            }
            guard let user = res?.user, !email.isEmpty else {
                let error = NSError(domain: "Authentication",
                                    code: 500,
                                    userInfo: [NSLocalizedDescriptionKey: "Unexpected error occurred"])
                completion(nil, error)
                return
            }
            let userData = AuthenticationData(userId: user.uid,
                                              email: email)
            completion(userData, nil)
        }
    }
    
    func logoutUser(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    func getUserData(completion: @escaping (AuthenticationData?, Error?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            // User is currently logged in, fetch user data
            let userData = AuthenticationData(userId: currentUser.uid,
                                              email: currentUser.email ?? "")
            completion(userData, nil)
        } else {
            let error = NSError(domain: "Authentication",
                                code: 401,
                                userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(nil, error)
        }
    }
    
}
