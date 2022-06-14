//
//  RxResponse+Serializable.swift
//  
//
//  Created by linshizai on 2022/6/10.
//

import Foundation
import Moya
import RxSwift
import Serialization

// MARK: - Observable

/// Extension for processing Responses into objects objects through JSONDecoder
public extension ObservableType where Element == Response {

    func mapObject<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String? = nil, extractor: Extrator = Extrator.default) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return .just(try response.mapObject(T.self, atKeyPath: keyPath, extractor: extractor))
        }
    }
}

// MARK: - Single

/// Extension for processing Responses into  objects through JSONDecoder
public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {

    func mapObject<T: Decodable>(_ type: T.Type, atKeyPath keyPath: String? = nil, extractor: Extrator = Extrator.default) -> Single<T> {
        return flatMap { response -> Single<T> in
            return .just(try response.mapObject(type, atKeyPath: keyPath, extractor: extractor))
        }
    }
}
