//
//  BookmarksViewController.swift
//  Trending in Github
//
//  Created by Anuran Barman on 29/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//

import UIKit

class BookmarksViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var savedRepoTableView: UITableView!
    var savedRepos:[Repository] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Bookmarked Repos"
        self.savedRepoTableView.delegate = self
        self.savedRepoTableView.dataSource = self
        self.savedRepoTableView.tableFooterView = UIView()
        self.savedRepoTableView.separatorStyle = .none
        self.savedRepoTableView.register(UINib(nibName: "RepoCell", bundle: nil), forCellReuseIdentifier: "savedRepoCell")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchAndReload()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(_:)), name: NSNotification.Name.init(rawValue: "ReloadTableView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cardTappedNotification(_:)), name: NSNotification.Name.init(rawValue: "CardTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contributorTapped(_:)), name: NSNotification.Name.init("ContributorTapped"), object: nil)
    }
    
    @objc func contributorTapped(_ notification:Notification){
        if let userInfo = notification.userInfo as? [String:Contributor]{
            if let contributor = userInfo["contributor"] {
                if let url = contributor.href {
                    UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @objc func cardTappedNotification(_ notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any] {
            if let index = userInfo["index"] as? Int {
                let repo = self.savedRepos[index]
                if let url = repo.url {
                    UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadTableView(_ notification:Notification){
        self.fetchAndReload()
    }
    
    func fetchAndReload(){
        self.savedRepos = Util.savedRepos
        DispatchQueue.main.async {
            self.savedRepoTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedRepos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedRepoCell", for: indexPath) as! RepoTableViewCell
        cell.setup(repo: self.savedRepos[indexPath.row], index: indexPath.row,mode: 1)
        return cell
    }
    
    
}
