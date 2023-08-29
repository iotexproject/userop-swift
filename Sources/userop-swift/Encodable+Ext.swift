//
//  Encodable+Ext.swift
//  
//
//  Created by liugang zhang on 2023/8/29.
//

import Foundation
import BigInt

public protocol EncodableToHex: Encodable {
    var hexString: String { get }
}

extension KeyedEncodingContainer {
    public mutating func encodeHex<T>(_ value: T, forKey: KeyedDecodingContainer<K>.Key) throws where T: EncodableToHex {
        try encode(value.hexString, forKey: forKey)
    }

    public mutating func encodeHexIfPresent<T>(_ value: T?, forKey: KeyedDecodingContainer<K>.Key) throws where T: EncodableToHex {
        try encodeIfPresent(value?.hexString, forKey: forKey)
    }
}

extension Data: EncodableToHex {
    public var hexString: String {
        toHexString().addHexPrefix()
    }
}

extension BigUInt: EncodableToHex {
    public var hexString: String {
        String(self, radix: 16).addHexPrefix()
    }
}

extension BigInt: EncodableToHex {
    public var hexString: String {
        String(self, radix: 16).addHexPrefix()
    }
}
