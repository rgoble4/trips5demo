//
//  PagingEnabledViewModel.swift
//  Trips5
//
//  Created by Rob Goble on 2/17/23.
//

import Foundation

protocol PagingEnabledViewModel: AnyObject {
    associatedtype Section
    associatedtype Item where Item: Identifiable
    
    @MainActor
    var all: [Item] { get set }
    
    @MainActor
    var itemIdxById: [Item.ID: Int] { get set }
    
    @MainActor
    var page: Int { get set }
    
    @MainActor
    var sections: [Section] { get set }
    
    @MainActor
    var totalCount: Int { get set }
    
    func setupSections() async
    func loadMoreData() async
}

extension PagingEnabledViewModel {
    @MainActor
    func bumpPage() {
        page += 1
    }
    
    @MainActor
    func setCount(_ count: Int) {
        totalCount = count
    }
    
    @MainActor
    func resetState() {
        page = 1
        sections = []
        all = []
        itemIdxById = [:]
        totalCount = 0
    }
    
    @MainActor
    func appendItems(_ items: [Item]) {
        all.append(contentsOf: items)
        
        for (idx, item) in all.enumerated() {
            itemIdxById[item.id] = idx
        }
        
        Task {
            await self.setupSections()
        }
    }
    
    @MainActor
    func itemAppeared(_ item: Item) {
        guard all.count > 0,
              let index = itemIdxById[item.id],
              index >= all.count - (Constants.pageSize / 2),
              all.count < totalCount else { return }
        
        Task {
            await loadMoreData()
        }
    }
}
