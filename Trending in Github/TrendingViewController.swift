//
//  ViewController.swift
//  Trending in Github
//
//  Created by Anuran Barman on 24/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//

import UIKit
import MaterialComponents

class TrendingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,FilterPickerDelegate {
    
    @IBOutlet var developerTableView: UITableView!
    var repos:[Repository] = []
    var developers:[Developer] = []
    @IBOutlet var repoTableView: UITableView!
    @IBOutlet var dayControl: UISegmentedControl!
    var selectedLang="None"
    var mode = "repositories"
    var by = "daily"
    var isRepository = true
    var isDeveloper = false
    var isPresented = false
    var hud:MBProgressHUD?
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Trending in Github"
        self.repoTableView.register(UINib(nibName: "RepoCell", bundle: nil), forCellReuseIdentifier: "repoCell")
        self.repoTableView.tableFooterView = UIView()
        self.repoTableView.separatorInset = UIEdgeInsets.zero
        self.repoTableView.separatorStyle = .none
        
        self.developerTableView.register(UINib(nibName: "DeveloperTableViewCell", bundle: nil), forCellReuseIdentifier: "devCell")
        self.developerTableView.tableFooterView = UIView()
        self.developerTableView.separatorInset = UIEdgeInsets.zero
        self.developerTableView.separatorStyle = .none
        
        self.dayControl.selectedSegmentIndex = 0
        
        let filterItem = UIBarButtonItem(image: UIImage(named: "filter")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(filterItemTapped(_:)))
        filterItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = filterItem
    }
    
    @objc func filterItemTapped(_ sender:UIBarButtonItem){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filterVC") as! FiltersViewController
        vc.delegate = self
        vc.selectedLang = self.selectedLang
        vc.isRepoCheckboxChecked = self.isRepository
        vc.isDevCheckboxChecked = self.isDeveloper
        let controller = MDCBottomSheetController(contentViewController: vc)
        self.present(controller,animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            RepoFileManager.sharedInstance.getFromFile { (_) in
                DispatchQueue.main.async {
                    self.repoTableView.reloadData()
                }
            }
        }
        if !self.isPresented {
            self.getRepos(by: "daily",lang: self.selectedLang,mode: self.mode)
            self.isPresented = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(cardTappedNotification(_:)), name: NSNotification.Name.init(rawValue: "CardTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(labelTappedNotification(_:)), name: NSNotification.Name.init(rawValue: "DeveloperNameTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(labelTappedNotification(_:)), name: NSNotification.Name.init(rawValue: "DeveloperRepoTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(_:)), name: NSNotification.Name.init(rawValue: "ReloadTableView"), object: nil)
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
    
    @objc func reloadTableView(_ notification:Notification){
        self.repoTableView.reloadData()
    }
    
    @objc func cardTappedNotification(_ notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any] {
            if let index = userInfo["index"] as? Int {
                let repo = self.repos[index]
                if let url = repo.url {
                    UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @objc func labelTappedNotification(_ notification:Notification){
        if let userInfo = notification.userInfo as? [String:Any] {
            if let url = userInfo["url"] as? String, let _ = userInfo["title"] as? String {
                UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch self.dayControl.selectedSegmentIndex {
        case 0:
            self.by = "daily"
            self.getRepos(by: "daily",lang: self.selectedLang,mode: self.mode)
            break
        case 1:
            self.by = "weekly"
            self.getRepos(by: "weekly",lang: self.selectedLang,mode: self.mode)
            break
        case 2:
            self.by = "monthly"
            self.getRepos(by: "monthly",lang: self.selectedLang,mode: self.mode)
            break
        default:
            print("")
        }
    }
    func getRepos(by:String,lang:String,mode:String){
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.label.text = "Please Wait"
        
        var urlString = "https://github-trending-api.now.sh/\(mode)?since=\(by)"
        if lang != "None"{
            urlString += "&language=\(lang)"
        }
        let url = URL(string: urlString)!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                self.hud?.hide(animated: true)
            }
            if error == nil && data != nil {
                do {
                    if mode == "repositories" {
                        let reposGot = try JSONDecoder().decode([Repository].self, from: data!)
                        self.repos = reposGot
                        DispatchQueue.main.async {
                            self.developerTableView.isHidden = true
                            self.repoTableView.isHidden = false
                            self.repoTableView.reloadData()
                            if self.repos.count > 0 {
                                self.repoTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                            }
                        }
                    }else if mode == "developers" {
                        let devsGot = try JSONDecoder().decode([Developer].self, from: data!)
                        self.developers = devsGot
                        DispatchQueue.main.async {
                            self.developerTableView.isHidden = false
                            self.repoTableView.isHidden = true
                            self.developerTableView.reloadData()
                            if self.developers.count > 0 {
                                self.developerTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                            }
                        }
                    }
                }catch {
                    
                }
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.repoTableView {
            return self.repos.count
        }else {
            return self.developers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.repoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell", for: indexPath) as! RepoTableViewCell
            let repo = self.repos[indexPath.row]
            cell.setup(repo: self.repos[indexPath.row],index: indexPath.row,mode: Util.savedRepoDict["\(repo.author!):\(repo.name!)"] == nil ? 0 : 1)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "devCell", for: indexPath) as! DeveloperTableViewCell
            cell.setup(developer: self.developers[indexPath.row])
            return cell
        }
    }

    
    func filterDidPick(lang: String?, mode: Int?) {
        if lang != nil {
            self.selectedLang = lang!
        }else {
            self.selectedLang = "None"
        }
        if mode != nil {
            if mode == 0 {
                self.mode = "repositories"
                self.isRepository = true
                self.isDeveloper = false
            }else if mode == 1 {
                self.mode = "developers"
                self.isRepository = false
                self.isDeveloper = true
            }else {
                self.isRepository = true
                self.isDeveloper = false
                self.mode = "repositories"
            }
        }
        self.getRepos(by: self.by, lang: self.selectedLang, mode: self.mode)
    }
    
}


