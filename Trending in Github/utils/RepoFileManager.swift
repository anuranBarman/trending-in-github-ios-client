//
//  FileManager.swift
//  Trending in Github
//
//  Created by Anuran Barman on 29/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//

import Foundation
import UIKit

class RepoFileManager {
    static let sharedInstance = RepoFileManager()
    
    init() {
        
    }
    
    func saveToFile(repo:Repository,completion:@escaping (_ success:Bool)->()){
        Util.savedRepos.append(repo)
        Util.createSavedRepoDict()
        self.saveFile(completion: completion)
    }
    
    func saveFile(completion:@escaping (_ success:Bool)->()){
        let file = "repos.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let data = try JSONEncoder().encode(Util.savedRepos)
                try data.write(to: fileURL, options: .atomic)
                completion(true)
            }
            catch {
                completion(false)
            }
        }else {
            completion(false)
        }
    }
    
    func removeFromFile(repo:Repository,completion:@escaping (_ success:Bool)->()){
        Util.savedRepos.removeAll { (rp) -> Bool in
            return rp.author! == repo.author! && rp.name! == repo.name!
        }
        Util.createSavedRepoDict()
        self.saveFile(completion: completion)
    }
    
    func getFromFile(completion:@escaping (_ savedRepos:[Repository]?)->()){
        let file = "repos.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let data = try Data(contentsOf: fileURL)
                let repos = try JSONDecoder().decode([Repository].self, from: data)
                Util.savedRepos = repos
                Util.createSavedRepoDict()
                completion(repos)
            }
            catch {
                completion(nil)
            }
        }
    }
    
    
}
