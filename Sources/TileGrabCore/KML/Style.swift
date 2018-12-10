//
//  Style.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

typealias JSONStyle = KMLStyle
struct KMLStyle: XMLIndexerDeserializable, Encodable {
    let id: String
    let iconStyle: IconStyle?
    let labelStyle: LabelStyle?
    let listStyle: ListStyle?
    let lineStyle: LineStyle?
    let polyStyle: PolyStyle?
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLStyle {
        let id: String = try element.value(ofAttribute: "id")
        return try KMLStyle.init(
            id: "#\(id)",
            iconStyle: element["IconStyle"].value(),
            labelStyle: element["LabelStyle"].value(),
            listStyle: element["ListStyle"].value(),
            lineStyle: element["LineStyle"].value(),
            polyStyle: element["PolyStyle"].value()
        )
    }
}

extension KMLStyle: Equatable, Hashable {
    static func ==(lhs: KMLStyle, rhs: KMLStyle) -> Bool {
        return lhs.id == rhs.id
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

struct PolyStyle: XMLIndexerDeserializable, Encodable {
    let color: String?
    
    static func deserialize(_ element: XMLIndexer) throws -> PolyStyle {
        return try PolyStyle.init(
            color: element["color"].value()
        )
    }
}

struct IconStyle: XMLIndexerDeserializable, Encodable {
    let color: String?
    let scale: Double?
    let icon: Icon?
    
    static func deserialize(_ element: XMLIndexer) throws -> IconStyle {
        return try IconStyle.init(
            color: element["color"].value(),
            scale: element["scale"].value(),
            icon: element["Icon"].value()
        )
    }
}

struct Icon: XMLIndexerDeserializable, Encodable {
    let href: String
    
    static func deserialize(_ element: XMLIndexer) throws -> Icon {
        return try Icon.init(
            href: element["href"].value()
        )
    }
}

struct LabelStyle: XMLIndexerDeserializable, Encodable {
    let color: String?
    let scale: Double?
    
    static func deserialize(_ element: XMLIndexer) throws -> LabelStyle {
        return try LabelStyle.init(
            color: element["color"].value(),
            scale: element["scale"].value()
        )
    }
}

struct LineStyle: XMLIndexerDeserializable, Encodable {
    let color: String?
    let width: Double?
    
    static func deserialize(_ element: XMLIndexer) throws -> LineStyle {
        return try LineStyle.init(
            color: element["color"].value(),
            width: element["width"].value()
        )
    }
}

struct ListStyle: XMLIndexerDeserializable, Encodable {
    let itemIcon: ItemIcon?
    let listItemType: String?
    
    static func deserialize(_ element: XMLIndexer) throws -> ListStyle {
        return try ListStyle.init(
            itemIcon: element["ItemIcon"].value(),
            listItemType: element["listItemType"].value()
        )
    }
}

struct ItemIcon: XMLIndexerDeserializable, Encodable {
    let href: String

    static func deserialize(_ element: XMLIndexer) throws -> ItemIcon {
        return try ItemIcon.init(
            href: element["href"].value()
        )
    }
}
