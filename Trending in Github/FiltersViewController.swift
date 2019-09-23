//
//  FiltersViewController.swift
//  Trending in Github
//
//  Created by Anuran Barman on 26/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//

import UIKit
import DropDown

protocol FilterPickerDelegate {
    func filterDidPick(lang:String?,mode:Int?)
}

class FiltersViewController: UIViewController {

    @IBOutlet var langLabel: UILabel!
    @IBOutlet var devCheckBox: UIImageView!
    @IBOutlet var repoCheckBox: UIImageView!
    
    var isRepoCheckboxChecked = false
    var isDevCheckboxChecked = false
    var dropDown:DropDown?
    var languges:[String] = ["None"]
    var supportedLangs:[SupportedLanguages] = []
    var delegate:FilterPickerDelegate?
    var selectedLang:String?
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let noneSupportedLang = SupportedLanguages()
        noneSupportedLang.name = "None"
        noneSupportedLang.urlParam = "None"
        self.supportedLangs.append(noneSupportedLang)
        
        self.setupCheckboxes()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(langTapped(_:)))
        self.langLabel.addGestureRecognizer(tapGesture)
    
        let tapGestureForCheckboxRepo = UITapGestureRecognizer(target: self, action: #selector(checkboxTapped(_:)))
        let tapGestureForCheckboxDev = UITapGestureRecognizer(target: self, action: #selector(checkboxTapped(_:)))
        self.repoCheckBox.addGestureRecognizer(tapGestureForCheckboxRepo)
        self.devCheckBox.addGestureRecognizer(tapGestureForCheckboxDev)
        
        if let path = Bundle.main.path(forResource: "languages", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let langs = try JSONDecoder().decode([SupportedLanguages].self, from: data)
                self.supportedLangs.append(contentsOf: langs)
                for lang in langs {
                    self.languges.append(lang.name!)
                }
            }catch {
                
            }
        }
        
        dropDown = DropDown()
        dropDown?.anchorView = self.langLabel
        dropDown?.dataSource = languges
        dropDown?.selectRow(self.supportedLangs.firstIndex(where: { (sl) -> Bool in
            return sl.urlParam! == self.selectedLang!
        })!)
        dropDown?.selectionAction = { [unowned self] (index: Int, item: String) in
            self.langLabel.text = item
            self.selectedLang = self.supportedLangs[index].urlParam!
        }
        
        if self.selectedLang! != "None" {
            self.langLabel.text = self.supportedLangs.first(where: { (sl) -> Bool in
                return sl.urlParam! == self.selectedLang!
            })!.name!
        }
    }
    
    @objc func checkboxTapped(_ sender:UITapGestureRecognizer){
        if sender.view! == self.repoCheckBox {
            if self.isRepoCheckboxChecked {
                self.isRepoCheckboxChecked = false
                self.isDevCheckboxChecked = true
            }else {
                self.isRepoCheckboxChecked = true
                self.isDevCheckboxChecked = false
            }
        }else if sender.view! == self.devCheckBox {
            if self.isDevCheckboxChecked {
                self.isRepoCheckboxChecked = true
                self.isDevCheckboxChecked = false
            }else {
                self.isRepoCheckboxChecked = false
                self.isDevCheckboxChecked = true
            }
        }
        
        self.setupCheckboxes()
    }
    
    func setupCheckboxes(){
        
        if self.isRepoCheckboxChecked {
            self.repoCheckBox.image = UIImage(named: "checkbox_checked")?.withRenderingMode(.alwaysTemplate)
            self.devCheckBox.image = UIImage(named: "checkbox_blank")?.withRenderingMode(.alwaysTemplate)
        }else if self.isDevCheckboxChecked{
            self.devCheckBox.image = UIImage(named: "checkbox_checked")?.withRenderingMode(.alwaysTemplate)
            self.repoCheckBox.image = UIImage(named: "checkbox_blank")?.withRenderingMode(.alwaysTemplate)
        }else {
            self.repoCheckBox.image = UIImage(named: "checkbox_blank")?.withRenderingMode(.alwaysTemplate)
            self.devCheckBox.image = UIImage(named: "checkbox_blank")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc func langTapped(_ sender:UITapGestureRecognizer){
        dropDown?.show()
    }
    @IBAction func doneButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            var mode = -1
            if self.isRepoCheckboxChecked {
                mode = 0
            }else if self.isDevCheckboxChecked{
                mode = 1
            }
            self.delegate?.filterDidPick(lang: self.selectedLang, mode: mode)
        }
    }
    
}
