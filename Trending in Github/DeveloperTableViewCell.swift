//
//  DeveloperTableViewCell.swift
//  Trending in Github
//
//  Created by Anuran Barman on 27/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//

import UIKit
import MaterialComponents

class DeveloperTableViewCell: UITableViewCell {

    @IBOutlet var card: MDCCard!
    @IBOutlet var repoDescLabel: UILabel!
    @IBOutlet var repoNameLabel: UILabel!
    @IBOutlet var fireImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userAvatar: UIImageView!
    var developer:Developer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(developer:Developer){
        self.developer = developer
        self.selectionStyle = .none
        self.contentView.isUserInteractionEnabled = true
        self.card.isUserInteractionEnabled = true
        self.nameLabel.isUserInteractionEnabled = true
        self.repoNameLabel.isUserInteractionEnabled = true
        self.nameLabel.tag = 0
        self.repoNameLabel.tag = 1
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(gotoLink(_:)))
        self.nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        
        let tapGestureForRepoNameLabel = UITapGestureRecognizer(target: self, action: #selector(gotoLink(_:)))
        self.repoNameLabel.addGestureRecognizer(tapGestureForRepoNameLabel)
        
        self.card.setShadowElevation(.cardResting, for: .normal)
        self.repoNameLabel.fitSizeWithOneLine()
        self.repoDescLabel.fitSize()
        self.usernameLabel.fitSizeWithOneLine()
        self.nameLabel.fitSizeWithOneLine()
        self.fireImage.image = UIImage(named: "trending")?.withRenderingMode(.alwaysTemplate)
        self.userAvatar.layer.cornerRadius = 20
        
        self.nameLabel.attributedText = self.getUnderLineAttributedText(str: developer.name ?? "")
        self.usernameLabel.text = developer.username ?? ""
        self.repoNameLabel.attributedText = self.getUnderLineAttributedText(str: developer.repo?.name ?? "")
        self.repoDescLabel.text = developer.repo?.description ?? ""
        if let image = Util.devImageDict["\(developer.username!)"] {
            self.userAvatar.image = image
        }else {
            DispatchQueue.global(qos: .background).async {
                if let avatar = developer.avatar {
                    if let url = URL(string: avatar){
                        do {
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                let image = UIImage(data: data)
                                self.userAvatar.image = image
                                Util.devImageDict["\(developer.username!)"] = image
                            }
                        }catch{
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc func gotoLink(_ sender:UITapGestureRecognizer){
        let tag = sender.view!.tag
        if tag == 0 {
            if let nameUrl = self.developer?.url {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "DeveloperNameTapped"), object: nil, userInfo: ["url":nameUrl,"title":"\(self.developer?.name ?? "")"])
            }
        }else {
            if let repoUrl = self.developer?.repo?.url {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "DeveloperRepoTapped"), object: nil, userInfo: ["url":repoUrl,"title":"\(self.developer?.username ?? "")/\(self.developer?.repo?.name ?? "")"])
            }
        }
    }
    
    func getUnderLineAttributedText(str:String)->NSAttributedString{
        let attrs:[NSAttributedString.Key:Any] = [NSAttributedString.Key.foregroundColor:UIColor.blue,NSAttributedString.Key.underlineColor:UIColor.blue,NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue]
        let attributedLink = NSMutableAttributedString(string: str, attributes: attrs)
        return attributedLink
    }
    
    
}
