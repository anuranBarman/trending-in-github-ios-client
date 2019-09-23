//
//  Util.swift
//  Trending in Github
//
//  Created by Anuran Barman on 28/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//


import UIKit
class Util {
    static var repoImageDict:[String:UIImage] = [:]
    static var devImageDict:[String:UIImage] = [:]
    static var contributorImageDict:[String:UIImage] = [:]
    static var savedRepoDict:[String:Repository] = [:]
    static var savedRepos:[Repository] = []
    
    static func createSavedRepoDict(){
        self.savedRepoDict = [:]
        for repo in self.savedRepos {
            self.savedRepoDict["\(repo.author!):\(repo.name!)"] = repo
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "ReloadTableView"), object: nil)
        }
    }
}
