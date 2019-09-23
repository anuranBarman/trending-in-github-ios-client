//
//  RepoTableViewCell.swift
//  Trending in Github
//
//  Created by Anuran Barman on 24/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//

import UIKit
import MaterialComponents

class RepoTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
    

    @IBOutlet var builtByCollectionView: UICollectionView!
    @IBOutlet var todayStarCountLabel: UILabel!
    @IBOutlet var todayStarImage: UIImageView!
    @IBOutlet var todayStarView: UIView!
    @IBOutlet var card: MDCCard!
    @IBOutlet var forkCountLabel: UILabel!
    @IBOutlet var forkImage: UIImageView!
    @IBOutlet var starCountLabel: UILabel!
    @IBOutlet var starImage: UIImageView!
    @IBOutlet var langNameLabel: UILabel!
    @IBOutlet var langColorView: UIView!
    @IBOutlet var repoDescLabel: UILabel!
    @IBOutlet var repoImage: UIImageView!
    @IBOutlet var repoNameLabel: UILabel!
    @IBOutlet var removeButton: UIButton!
    
    var index:Int?
    var mode:Int?
    var repo:Repository?
    var builtBys:[Contributor] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(repo:Repository,index:Int,mode:Int=0){
        self.index = index
        self.repo = repo
        self.builtBys = self.repo?.builtBy ?? []
        self.builtByCollectionView.delegate = self
        self.builtByCollectionView.dataSource = self
        self.builtByCollectionView.register(ContributorCell.self, forCellWithReuseIdentifier: "contributorCell")
        
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = true
        self.card.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        self.card.addGestureRecognizer(tapGesture)
        self.card.setShadowElevation(.cardResting, for: .normal)
        self.todayStarView.layer.cornerRadius = 10
        self.repoImage.layer.cornerRadius = 15
        self.langColorView.layer.cornerRadius = 10
        if let langColor = repo.languageColor {
            self.langColorView.backgroundColor = UIColor(hexString: langColor)
        }
        self.mode = mode
        if mode == 0 {
            self.removeButton.backgroundColor = UIColor(hexString: "#4E913C")
            self.removeButton.setTitle("Bookmark", for: .normal)
        }else {
            self.removeButton.backgroundColor = UIColor(hexString: "#FF464B")
            self.removeButton.setTitle("Remove", for: .normal)
        }
        
        self.todayStarImage.image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        self.starImage.image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        self.forkImage.image = UIImage(named: "fork")?.withRenderingMode(.alwaysTemplate)
        self.starImage.tintColor = .black
        self.forkImage.tintColor = .black
        self.todayStarImage.tintColor = UIColor(hexString: "#669C1E")
        self.todayStarCountLabel.fitSizeWithOneLine()
        self.repoDescLabel.fitSize()
        self.repoNameLabel.fitSize()
        self.langNameLabel.fitSizeWithOneLine()
        self.starCountLabel.fitSize()
        self.forkCountLabel.fitSize()
        
        self.repoNameLabel.text = "\(repo.author ?? "")/\(repo.name ?? "")"
        self.starCountLabel.text = "\(repo.stars ?? 0)"
        self.forkCountLabel.text = "\(repo.forks ?? 0)"
        self.langNameLabel.text = "\(repo.language ?? "")"
        self.repoDescLabel.text = repo.description ?? ""
        self.todayStarCountLabel.text = "\(repo.currentPeriodStars ?? 0) Stars Today"
        if let image = Util.repoImageDict["\(repo.author!):\(repo.name!)"] {
            self.repoImage.image = image
        }else {
            DispatchQueue.global(qos: .background).async {
                if let avatar = repo.avatar {
                    if let url = URL(string: avatar) {
                        do {
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                let image = UIImage(data: data)
                                self.repoImage.image = image
                                Util.repoImageDict["\(repo.author!):\(repo.name!)"] = image
                            }
                        }catch {
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc func cardTapped(_ sender:UITapGestureRecognizer){
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "CardTapped"), object: nil, userInfo: ["index":self.index!])
    }
    
    @IBAction func removeButtonTapped(_ sender: Any) {
        if self.mode! == 0 {
            DispatchQueue.global(qos: .background).async {
                RepoFileManager.sharedInstance.saveToFile(repo: self.repo!) { (success) in
                    if success {
                        
                    }else {
                        
                    }
                }
            }
        }else {
            DispatchQueue.global(qos: .background).async {
                RepoFileManager.sharedInstance.removeFromFile(repo: self.repo!, completion: { (success) in
                    if success {
                        
                    }else {
                        
                    }
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.builtBys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contributorCell", for: indexPath) as! ContributorCell
        cell.setup(contributor: self.builtBys[indexPath.row])
        return cell
    }
    
    
}

class ContributorCell: UICollectionViewCell {
    
    var imageView:UIImageView?
    var contributor:Contributor?
    
    func setup(contributor:Contributor) {
        self.contributor = contributor
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        self.contentView.isUserInteractionEnabled = true
        
        imageView = UIImageView()
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.layer.cornerRadius = 10.5
        imageView?.clipsToBounds = true
        imageView?.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView?.addGestureRecognizer(tapGesture)
        if let avatar = contributor.avatar {
            if let image = Util.contributorImageDict["\(contributor.username!)"] {
                self.imageView?.image = image
            }else {
                DispatchQueue.global(qos: .background).async {
                    if let url = URL(string: avatar) {
                        do {
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                let image = UIImage(data: data)
                                self.imageView?.image = image
                                Util.contributorImageDict["\(contributor.username!)"] = image
                            }
                        }catch {
                            
                        }
                    }
                }
            }
        }
        
        self.contentView.addSubview(imageView!)
        
        let upperConstraintImageView = NSLayoutConstraint(item: imageView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 2)
        let leftConstraintImageView = NSLayoutConstraint(item: imageView!, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 2)
        let rightConstraintImageView = NSLayoutConstraint(item: imageView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: -2)
        let bottomConstraintImageView = NSLayoutConstraint(item: imageView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -2)
        
        
        NSLayoutConstraint.activate([upperConstraintImageView,leftConstraintImageView,rightConstraintImageView,bottomConstraintImageView])
    }
    
    @objc func imageTapped(_ sender:UITapGestureRecognizer){
        NotificationCenter.default.post(name: NSNotification.Name.init("ContributorTapped"), object: nil, userInfo: ["contributor":self.contributor!])
    }
    
}
