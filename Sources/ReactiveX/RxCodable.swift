//
//  RxCodable.swift
//  
//
//  Created by linshizai on 2022/6/12.
//

import Foundation
import RxSwift

public extension PrimitiveSequenceType where Trait == MaybeTrait, Element == Data {
    func map<T>(_ type: T.Type, using decoder: JSONDecoder? = nil) -> PrimitiveSequence<Trait, T> where T: Decodable {
        return self.map { data -> T in
            let decoder = decoder ?? JSONDecoder()
            return try decoder.decode(type, from: data)
        }
    }
}

public extension PrimitiveSequenceType where Trait == MaybeTrait, Element == String {
    func map<T>(_ type: T.Type, using decoder: JSONDecoder? = nil) -> PrimitiveSequence<Trait, T> where T: Decodable {
        return self
            .map { string in string.data(using: .utf8) ?? Data() }
            .map(type, using: decoder)
    }
}


public extension PrimitiveSequenceType where Trait == SingleTrait, Element == Data {
    func map<T>(_ type: T.Type, using decoder: JSONDecoder? = nil) -> PrimitiveSequence<Trait, T> where T: Decodable {
        return self.map { data -> T in
            let decoder = decoder ?? JSONDecoder()
            return try decoder.decode(type, from: data)
        }
    }
}

public extension PrimitiveSequenceType where Trait == SingleTrait, Element == String {
    func map<T>(_ type: T.Type, using decoder: JSONDecoder? = nil) -> PrimitiveSequence<Trait, T> where T: Decodable {
        return self
            .map { string in string.data(using: .utf8) ?? Data() }
            .map(type, using: decoder)
    }
}

public extension ObservableType where Element == Data {
    func map<T>(_ type: T.Type, using decoder: JSONDecoder? = nil) -> Observable<T> where T: Decodable {
        return self.map { data -> T in
            let decoder = decoder ?? JSONDecoder()
            return try decoder.decode(type, from: data)
        }
    }
}

public extension ObservableType where Element == String {
    func map<T>(_ type: T.Type, using decoder: JSONDecoder? = nil) -> Observable<T> where T: Decodable {
        return self
            .map { string in string.data(using: .utf8) ?? Data() }
            .map(type, using: decoder)
    }
}
