//
//  Style.swift
//  TileGrabCore
//
//  Created by Taylor McIntyre on 2018-12-05.
//

import Foundation
import SWXMLHash

struct KMLStyle: XMLIndexerDeserializable {
    let iconStyle: IconStyle?
    let labelStyle: LabelStyle?
    let listStyle: ListStyle?
    let lineStyle: LineStyle?
    
    static func deserialize(_ element: XMLIndexer) throws -> KMLStyle {
        return try KMLStyle.init(
            iconStyle: element["IconStyle"].value(),
            labelStyle: element["LabelStyle"].value(),
            listStyle: element["ListStyle"].value(),
            lineStyle: element["LineStyle"].value()
        )
    }
}

struct IconStyle: XMLIndexerDeserializable {
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

struct Icon: XMLIndexerDeserializable {
    let href: String
    
    static func deserialize(_ element: XMLIndexer) throws -> Icon {
        return try Icon.init(
            href: element["href"].value()
        )
    }
}

struct LabelStyle: XMLIndexerDeserializable {
    let color: String?
    let scale: Double?
    
    static func deserialize(_ element: XMLIndexer) throws -> LabelStyle {
        return try LabelStyle.init(
            color: element["color"].value(),
            scale: element["scale"].value()
        )
    }
}

struct LineStyle: XMLIndexerDeserializable {
    let color: String?
    let width: Double?
    
    static func deserialize(_ element: XMLIndexer) throws -> LineStyle {
        return try LineStyle.init(
            color: element["color"].value(),
            width: element["width"].value()
        )
    }
}

struct ListStyle: XMLIndexerDeserializable {
    let itemIcon: ItemIcon
    
    static func deserialize(_ element: XMLIndexer) throws -> ListStyle {
        return try ListStyle.init(
            itemIcon: element["ListStyle"].value()
        )
    }
}

struct ItemIcon: XMLIndexerDeserializable {
    let href: String
    
    static func deserialize(_ element: XMLIndexer) throws -> ItemIcon {
        return try ItemIcon.init(
            href: element["href"].value()
        )
    }
}
