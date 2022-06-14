//
// The MIT License (MIT)
//
// Copyright (c) 2015 RxSwift Community
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
import Foundation
import Reachability
import RxCocoa
import RxSwift

extension Reachability: ReactiveCompatible { }

public extension Reactive where Base: Reachability {

  /// Global to observe when `Reachability` status changes.
  static var reachabilityChanged: Observable<Reachability> {
      return NotificationCenter.default.rx.notification(Notification.Name.reachabilityChanged)
          .flatMap { notification -> Observable<Reachability> in
              guard let reachability = notification.object as? Reachability else {
                  return .empty()
              }
              return .just(reachability)
          }
  }

  /// Global to observe when `Reachability.Connection` status changes.
  static var status: Observable<Reachability.Connection> {
      reachabilityChanged.map { $0.connection }
  }

  /// Global to observe a `Bool` when `Reachability.Connection != .none` .
  static var isReachable: Observable<Bool> {
      reachabilityChanged.map { $0.connection != .none }
  }

  /// Global to observe a `Void` when `Reachability.Connection != .none` .
  static var isConnected: Observable<Void> {
      isReachable.filter { $0 }.map { _ in Void() }
  }

  /// Global to observe a `Void` when `Reachability.Connection == .none` .
  static var isDisconnected: Observable<Void> {
      isReachable.filter { !$0 }.map { _ in Void() }
  }
}

public extension Reactive where Base: Reachability {

  /// Rx `Observable` to observe when `Reachability` status changes.
  var reachabilityChanged: Observable<Reachability> {
      return NotificationCenter.default.rx.notification(Notification.Name.reachabilityChanged, object: base)
          .flatMap { notification -> Observable<Reachability> in
              guard let reachability = notification.object as? Reachability else {
                  return .empty()
              }
              return .just(reachability)
          }
  }

  /// Rx `Observable` to observe when `Reachability.Connection` value changes.
  var status: Observable<Reachability.Connection> {
    reachabilityChanged.map { $0.connection }
  }

  /// Instance variable to observe a `Bool` when `Reachability.Connection != .none` .
  var isReachable: Observable<Bool> {
      reachabilityChanged.map { $0.connection != .none }
  }

  /// Instance variable to observe a `Void` when `Reachability.Connection != .none` .
  var isConnected: Observable<Void> {
      isReachable.filter { $0 }.map { _ in Void() }
  }

  /// Instance variable to observe a `Void` when `Reachability.Connection == .none` .
  var isDisconnected: Observable<Void> {
      isReachable.filter { !$0 }.map { _ in Void() }
  }
}

public extension ObservableType {

  /// An oberverable to execute retry and execute code on reconnect after a timeout `timeout`
  /// - Parameter timeout: Seconds for timeout
  /// - Returns: An observable sequence with a RxError.timeout in case of a timeout.
  func retryOnConnect(timeout: DispatchTimeInterval) -> Observable<Element> {
      return retry { _ in
          return Reachability.rx.isConnected
              .timeout(timeout, scheduler: MainScheduler.asyncInstance)
      }
  }

  /// An filtered oberverable to execute retry and execute code on reconnect after a timeout `timeout`
  /// - Parameters:
  ///   - timeout: Seconds for timeout
  ///   - predicate: A function to test each source element for a condition.
  /// - Returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
  func retryOnConnect(timeout: DispatchTimeInterval, predicate: @escaping (Swift.Error) -> Bool) -> Observable<Element> {
      return retry {
          $0.filter(predicate).flatMap { _ in
              Reachability.rx.isConnected.timeout(timeout, scheduler: MainScheduler.asyncInstance)
          }
      }
  }

  /// An filtered oberverable to execute retry and execute code on reconnect after a timeout `timeout`
  /// - Parameters:
  ///   - timeout: Seconds for timeout
  ///   - predicate: A function to test each source element for a condition.
  /// - Returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
  func retryLatestOnConnect(timeout: DispatchTimeInterval, predicate: @escaping (Swift.Error) -> Bool) -> Observable<Element> {
      return retry {
          $0.filter(predicate).flatMapLatest { _ in
              Reachability.rx.isConnected.timeout(timeout, scheduler: MainScheduler.asyncInstance)
          }
      }
    }
}
