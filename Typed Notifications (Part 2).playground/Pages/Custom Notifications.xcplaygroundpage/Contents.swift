import Foundation
import PlaygroundSupport

let center = NotificationCenter.default

struct NotificationDescriptor<A> {
    let name: Notification.Name
    let convert: (Notification) -> A
}

struct CustomNotificationDescriptor<A> {
    let name: Notification.Name
}

struct PlaygroundPagePayload {
    let page: PlaygroundPage
    let needsIndefiniteExecution: Bool
}

extension PlaygroundPagePayload {
    init(note: Notification) {
        page = note.object as! PlaygroundPage
        needsIndefiniteExecution = note.userInfo?["PlaygroundPageNeedsIndefiniteExecution"] as! Bool
    }
}

extension PlaygroundPage {
    static let needsIndefiniteExecutionChanged = NotificationDescriptor<PlaygroundPagePayload>(name: Notification.Name("PlaygroundPageNeedsIndefiniteExecutionDidChangeNotification"), convert: PlaygroundPagePayload.init)
}

class Token {
    let token: NSObjectProtocol
    let center: NotificationCenter
    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}

extension NotificationCenter {
    func addObserver<A>(descriptor: NotificationDescriptor<A>, using block: @escaping (A) -> ()) -> Token {
        let token = addObserver(forName: descriptor.name, object: nil, queue: nil, using: { note in
            block(descriptor.convert(note))
        })
        return Token(token: token, center: self)
    }

    func addObserver<A>(descriptor: CustomNotificationDescriptor<A>, queue: OperationQueue? = nil, using block: @escaping (A) -> ()) -> Token {
        let token = addObserver(forName: descriptor.name, object: nil, queue: queue, using: { note in
            block(note.object as! A)
        })
        return Token(token: token, center: self)
    }
    
    func post<A>(descriptor: CustomNotificationDescriptor<A>, value: A) {
        post(name: descriptor.name, object: value)
    }
}


var token: Token? = center.addObserver(descriptor: PlaygroundPage.needsIndefiniteExecutionChanged, using: {
    print($0)
})


PlaygroundPage.current.needsIndefiniteExecution = true
