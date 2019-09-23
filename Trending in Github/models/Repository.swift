//
//  Repository.swift
//  Trending in Github
//
//  Created by Anuran Barman on 24/08/19.
//  Copyright © 2019 Anuran Barman. All rights reserved.
//

import Foundation
class Repository: Codable {
    var author:String?
    var name:String?
    var avatar:String?
    var url:String?
    var description:String?
    var language:String?
    var languageColor:String?
    var stars:Int?
    var forks:Int?
    var currentPeriodStars:Int?
    var builtBy:[Contributor]?
}

class Contributor: Codable {
    var username:String?
    var href:String?
    var avatar:String?
}
