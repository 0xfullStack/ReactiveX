import XCTest
import SocketIO
import RxSwift
@testable import ReactiveX

final class ReactiveXTests: XCTestCase {
    
    let bag = DisposeBag()
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ReactiveX().text, "Hello, World!")
    }
    
    enum EventNamespace: String {
        case address = "/address"
        case `default` = "/"
    }
    
    struct SocketIODataItem: Codable, SocketData {
        let id: UUID
        let scope: String
        let payload: [String: String]

        func socketRepresentation() -> SocketData {
            return [
                "id": id.uuidString,
                "scope": [scope],
                "payload": payload
            ]
        }
    }
    
    func testRxSocketIOThroughZerion() {
        let expectation = XCTestExpectation(description: "Receive data successfully")
        let url = "wss://api-v4.zerion.io"
        let apiKey = "Demo.ukEVQp6L5vfgxcz4sBke7XvS873GMYHy"
        let payload = ["api_token": apiKey]
        let mannager = SocketManager(socketURL: URL(string: url)!, config: [
            .log(false), .forceWebsockets(true),
            .version(.two), .secure(true)
        ])
        
        let proxy = SocketIOProxy(manager: mannager, namespace: EventNamespace.address.rawValue, payload: payload)
        let subscriptionID = UUID()
        let address = "0x6079433E43Bf3244Bceef85a2FBfbfFa6864C82c"
        let action = "get"
        let item = SocketIODataItem(id: subscriptionID, scope: "positions", payload: ["address": address])
        
        proxy.rx
            .connected
            .flatMapLatest({ connected -> Observable<Void> in
                return connected ? proxy.rx.emit(action, item) : .never()
            })
            .flatMapLatest({ _ -> Observable<[Any]> in
                return proxy.rx.on("received address positions").map({ $0.0 })
            })
            .subscribe(onNext: { data in
                guard let dic = data.first as? [String: [String: Any]] else {
                    return
                }
                guard let dic = dic["payload"]?["positions"],
                      let dic = dic as? [String: Any],
                      let array = dic["positions"] as? [Any] else {
                    return
                }
                guard let jsonData = try? JSONSerialization.data(withJSONObject: array) else {
                    return
                }
                
                print("lsz: \(array)")
            })
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: TimeInterval(1000000))
    }
}
