//
//  AuthenticationManager.swift
//  TowerForge
//
//  Created by Vanessa Mae on 08/04/24.
//

import Foundation
import FirebaseAuth

protocol AuthenticationDelegate: AnyObject {
    func onLogout()
    func onLogin()
}

class AuthenticationManager: AuthenticationProtocol {
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var delegate: AuthenticationDelegate?
   deinit {
       // Remove the authentication state listener when deinitializing the manager
       if let handle = authStateHandle {
           Auth.auth().removeStateDidChangeListener(handle)
       }
   }
    func isUserLoggedIn() -> Bool {
        Auth.auth().currentUser != nil
    }
    func setListener(delegate: AuthenticationDelegate) {
       authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
           self?.delegate = delegate
           if let user = user, let email = user.email {
               let userData = AuthenticationData(userId: user.uid,
                                                 email: email,
                                                 username: user.displayName)
               print("SOmething listened")
               self?.delegate?.onLogin()
           } else {
               self?.delegate?.onLogout()
           }
       }
   }
    func registerUser(email: String, username: String, password: String, onFinish: @escaping (AuthenticationData?, Error?) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if error != nil {
                onFinish(nil, error)
            } else {
                Auth.auth().signIn(withEmail: email, password: password)
                let user = Auth.auth().currentUser
                let request = user?.createProfileChangeRequest()
                request?.displayName = username
                request?.commitChanges(completion: { err in
                    if err == nil, let id = user?.uid {
                        onFinish(AuthenticationData(userId: id,
                                                    email: email,
                                                    username: user?.displayName), nil)
                    } else {
                        onFinish(nil, err)
                    }
                })
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
                                              email: email,
                                              username: user.displayName)
            self.delegate?.onLogin()
            completion(userData, nil)
        }
    }

    func logoutUser(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            self.delegate?.onLogout()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    func getUserData(completion: @escaping (AuthenticationData?, Error?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            // User is currently logged in, fetch user data
            let userData = AuthenticationData(userId: currentUser.uid,
                                              email: currentUser.email ?? "",
                                              username: currentUser.displayName)
            completion(userData, nil)
        } else {
            let error = NSError(domain: "Authentication",
                                code: 401,
                                userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(nil, error)
        }
    }

}