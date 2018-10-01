//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import ReactiveKit

public protocol SectionedDataSourceProtocol {
    var numberOfSections: Int { get }
    func numberOfItems(inSection section: Int) -> Int
}

public protocol QueryableSectionedDataSourceProtocol: SectionedDataSourceProtocol {
    associatedtype Item
    func item(at indexPath: IndexPath) -> Item
}

extension Array: QueryableSectionedDataSourceProtocol {

    public var numberOfSections: Int {
        return 1
    }

    public func numberOfItems(inSection section: Int) -> Int {
        return count
    }

    public func item(at indexPath: IndexPath) -> Element {
        return self[indexPath[1]]
    }
}

extension TreeArray: SectionedDataSourceProtocol {

    public var numberOfSections: Int {
        return children.count
    }

    public func numberOfItems(inSection section: Int) -> Int {
        return children[section].children.count
    }
}

extension TreeArray: QueryableSectionedDataSourceProtocol where ChildValue: Array2DElementProtocol {

    public typealias Item = ChildValue.Item

    public func item(at indexPath: IndexPath) -> ChildValue.Item {
        return self[indexPath].value.item!
    }
}

public protocol SectionedDataIndexPathConvertable {
    var asSectionDataIndexPath: IndexPath { get }
}

extension IndexPath: SectionedDataIndexPathConvertable {

    public var asSectionDataIndexPath: IndexPath {
        return self
    }
}

extension Int: SectionedDataIndexPathConvertable {

    public var asSectionDataIndexPath: IndexPath {
        return [0, self]
    }
}

public protocol SectionedDataSourceChangeset: ChangesetProtocol where Diff: ArrayBasedDiffProtocol, Diff.Index: SectionedDataIndexPathConvertable, Collection: SectionedDataSourceProtocol {
}

extension SectionedDataSourceChangeset {

    public var indexPathArrayBasedDiff: ArrayBasedDiff<IndexPath> {
        return diff.asArrayBasedDiff.map { $0.asSectionDataIndexPath }
    }
}

extension CollectionChangeset: SectionedDataSourceChangeset where Diff.Index: SectionedDataIndexPathConvertable, Collection: SectionedDataSourceProtocol {}

extension TreeChangeset: SectionedDataSourceChangeset where Collection: SectionedDataSourceProtocol {}
