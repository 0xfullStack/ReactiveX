//
//  RxSocketIO.swift
//  
//
//  Created by linshizai on 2022/6/14.
//

import Foundation
import RxSwift
import SocketIO
import RxCocoa

public class SocketIOProxy {
    
    fileprivate let subject = PublishSubject<SocketClientEvent>()
    private let manager: SocketManager
    private let namespace: String
    private let payload: [String: Any]?
    
    var client: SocketIOClient {
        manager.socket(forNamespace: namespace)
    }
    
    public init(manager: SocketManager, namespace: String, payload: [String: Any]? = nil) {
        self.manager = manager
        self.namespace = namespace
        self.payload = payload
        
        client.on(clientEvent: .connect) { [weak self] data, ack in
            guard let self = self else { return }
            self.subject.onNext(.connect)
        }
        client.on(clientEvent: .disconnect) { [weak self] data, ack in
            guard let self = self else { return }
            self.subject.onNext(.disconnect)
        }
        client.on(clientEvent: .error) { [weak self] data, ack in
            guard let self = self else { return }
            self.subject.onNext(.error)
        }
        connectIfNeed()
    }
    
    public func connectIfNeed() {
        client.connect(withPayload: payload)
    }
    
    public func disconnected() {
        client.disconnect()
    }
    
    deinit {
        subject.onCompleted()
    }
}

extension Reactive where Base: SocketIOProxy {
    
    public var response: Observable<SocketClientEvent>{
        return base.subject
    }
    
    public var connected: Observable<Bool> {
        return response
            .filter {
                switch $0 {
                case .connect, .disconnect, .error: return true
                default: return false
                }
            }
            .map {
                switch $0 {
                    case .connect: return true
                    default: return false
                }
            }
    }
    
    public func emit(_ event: String, _ items: SocketData...) -> Observable<Void> {
        return Observable.create { observer in
            self.base.client.emit(event, with: items) {
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    public func emitWithAck(_ event: String, _ items: SocketData...) -> Observable<OnAckCallback> {
        return Observable.create { observer in
            observer.onNext( self.base.client.emitWithAck(event, items) )
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    public func on(_ event: String) -> Observable<([Any], SocketAckEmitter)> {
        return Observable.create { observer in
            self.base.client.on(event) { data, ack in
                observer.onNext((data, ack))
            }
            return Disposables.create()
        }
    }
}

extension SocketIOProxy: ReactiveCompatible {}
