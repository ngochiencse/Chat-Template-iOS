//
//  Prefs.swift
//  ios_template_project
//
//  Created by Hien Pham on 8/22/19.
//  Copyright © 2019 BraveSoft Vietnam. All rights reserved.
//
import Foundation
import RxSwift
import CocoaLumberjack

class PrefsImpl: NSObject {
    static let `default`: PrefsImpl = PrefsImpl()
    // Make sure thread safe
    private let accessTokenQueue: DispatchQueue = DispatchQueue(label: "accessTokenSync")
    // Make sure thread safe
    private let refreshTokenQueue: DispatchQueue = DispatchQueue(label: "refreshTokenSync")
    let defaults: UserDefaults
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }
    
    private func saveCodableCustomObject<T: Encodable>(object: T?, key: String) {
        if let unwrapped = object {
            do {
                let data = try JSONEncoder().encode(unwrapped)
                defaults.set(data, forKey: key)
            } catch {
                DDLogError("Save Prefs with type \(String(describing: type(of: object))) failed.")
            }
        } else {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }
    
    private func loadCodableCustomObjectWithKey<T: Decodable>(key : String, class: T.Type) -> T? {
        if let data = defaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)
                return object
            } catch {
                DDLogError("Retrieve \(String(describing: T.self)) from Prefs failed.")
                return nil
            }
        }
        return nil
    }
}

extension PrefsImpl: PrefsUserInfo {
    func getUserInfo() -> User? {
        let userInfo : User? = loadCodableCustomObjectWithKey(key: "user", class: User.self)
        return userInfo
    }

    func saveUserInfo(_ user : User?) {
        saveCodableCustomObject(object: user, key: "user")
    }
}

extension PrefsImpl: PrefsShowTutorial {
    public func setShowTutorial(showTutorial : Bool) {
        defaults.set(showTutorial, forKey: "showTutorial")
        defaults.synchronize()
    }
    
    public func isShowTutorial() -> Bool {
        var showTutorial : Bool
        if let boolObject = defaults.object(forKey: "showTutorial") {
            showTutorial = boolObject as! Bool
        } else {
            showTutorial = false
        }
        return showTutorial
    }
}

extension PrefsImpl: PrefsAccessToken {    
    public func getAccessToken() -> String? {
        return defaults.string(forKey: "accessToken")
    }
    
    public func saveAccessToken(_ accessToken: String?) {
        accessTokenQueue.sync {
            if let unwrapped = accessToken {
                defaults.set(unwrapped, forKey: "accessToken")
            } else {
                defaults.removeObject(forKey: "accessToken")
            }
            defaults.synchronize()
        }
    }
}

extension PrefsImpl: PrefsRefreshToken {
    public func getRefreshToken() -> String? {
        return defaults.string(forKey: "refreshToken")
    }
    
    public func saveRefreshToken(_ refreshToken: String?) {
        refreshTokenQueue.sync {
            if let unwrapped = refreshToken {
                defaults.set(unwrapped, forKey: "refreshToken")
            } else {
                defaults.removeObject(forKey: "refreshToken")
            }
            defaults.synchronize()
        }
    }
}
