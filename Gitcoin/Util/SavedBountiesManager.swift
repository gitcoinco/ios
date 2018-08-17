//
//  SavedBountiesManager.swift
//  Gitcoin
//
//  Created by John Brunelle on 6/7/18.
//  Copyright © 2018 Gitcoin. All rights reserved.
//

import Foundation

class SavedBountiesManager: NSObject {
    static let shared = SavedBountiesManager()
    private override init() {}

    func currentIds() -> [Int] {
        return  UserDefaults.standard.object(forKey: Config.kGitCoinSavedBounties) as? [Int] ?? [Int]()
    }

    static func save(id: Int?) {

        guard let id = id else { return }
        var bountyArr = shared.currentIds()
        bountyArr.append(id)

        UserDefaults.standard.set(bountyArr, forKey: Config.kGitCoinSavedBounties)

        print("save bounty  = \(id)")
        shared.printSavedBounties()
    }

    static func remove(id: Int?) {

        guard let id = id else { return }
        var bountyArr = shared.currentIds()

        if let index = bountyArr.index(of: id) {
            bountyArr.remove(at: index)
        }

        UserDefaults.standard.set(bountyArr, forKey: Config.kGitCoinSavedBounties)

        print("removed bounty  = \(id)")
        shared.printSavedBounties()
    }

    static func removeByList(of bounties: [Bounty]) {
        for (_, item) in bounties.enumerated() {
            SavedBountiesManager.remove(id: item.standardBountiesId)
        }
    }

    static func bountyExists(id: Int?) -> Bool {

        guard let id = id else { return false}
        return shared.currentIds().contains(where: { $0 == id })
    }

    static func list() -> String {

        let bountyArr = shared.currentIds()
        let convertedArr = bountyArr.map {String($0)}.joined(separator: ", ")

        print("convertedArr = \(convertedArr)")
        shared.printSavedBounties()

        return convertedArr

    }

    fileprivate func printSavedBounties() {
        let bountyArr = currentIds()
        print("Current Saved Bounties = \(bountyArr)")

    }

}
