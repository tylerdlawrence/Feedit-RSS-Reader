//
//  DIContainer.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 2/6/21.
//

import SwiftUI
import Combine
import Foundation

struct DIContainer: EnvironmentKey {
    
    let appState: Store<AppState>
    let interactors: Interactors
    
    init(appState: Store<AppState>, interactors: Interactors) {
        self.appState = appState
        self.interactors = interactors
    }
    
    init(appState: AppState, interactors: Interactors) {
        self.init(appState: Store<AppState>(appState), interactors: interactors)
    }
    
    static var defaultValue: Self { Self.default }
    
    private static let `default` = DIContainer(appState: AppState(), interactors: .stub)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}


extension View {
    
    func inject(_ appState: AppState,
                _ interactors: DIContainer.Interactors) -> some View {
        let container = DIContainer(appState: .init(appState),
                                    interactors: interactors)
        return inject(container)
    }
    
    func inject(_ container: DIContainer) -> some View {
        return self
            .modifier(RootViewAppearance())
            .environment(\.injected, container)
    }
}
extension DIContainer {
    struct Interactors {
        
        let rssSourcesInteractor: RSSSourcesInteractor
        
        static var stub: Self {
            .init(rssSourcesInteractor: SubRSSSourcesInteractor())
        }
    }
}

typealias Store<State> = CurrentValueSubject<State, Never>

extension Store {
    
    subscript<T>(keyPath:  WritableKeyPath<Output, T>) -> T where T: Equatable {
        get { value[keyPath: keyPath] }
        set {
            var value = self.value
            if value[keyPath: keyPath] != newValue {
                value[keyPath:keyPath] = newValue
                self.value = value
            }
        }
    }
    
    func updates<Value>(for keyPath: KeyPath<Output, Value>) ->
        AnyPublisher<Value, Failure> where Value: Equatable {
        return map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}

extension Binding where Value: Equatable {
    func dispatched<State>(to state: Store<State>,
                           _ keyPath: WritableKeyPath<State, Value>) -> Self {
        return onSet { state[keyPath] = $0 }
    }
}

extension Binding {
    typealias ValueClosure = (Value) -> Void
    
    func onSet(_ perform: @escaping ValueClosure) -> Self {
        return .init(get: { () -> Value in
            self.wrappedValue
        }, set: { value in
            self.wrappedValue = value
            perform(value)
        })
    }
}

struct AppState {
    var userData = UserData()
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
    }
}

extension AppState {
    struct UserData: Equatable {
        
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        
    }
}

extension AppState {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        return lhs.userData == rhs.userData && rhs.routing == rhs.routing && lhs.system == rhs.system
    }
}
protocol RSSSourcesInteractor {
    
    func load(sources: Binding<[RSS]>)
    func store(source: RSS)
    func store(url: String, title: String?, desc: String?)
}

protocol RSSSourcesDBRepository {
    func hasLoadedCountries() -> AnyPublisher<Bool, Error>
    func sources() -> AnyPublisher<Array<RSS>, Error>
    func store(sources: [RSS]) -> AnyPublisher<Void, Error>
    
    func store(url: String, title: String?, desc: String?) -> AnyPublisher<Void, Error>
}

struct RealRSSSourcesInteractor: RSSSourcesInteractor {
    
    let dbRepository: RSSSourcesDBRepository
    let appState: Store<AppState>
    
    func load(sources: Binding<[RSS]>) {
        let cancelBag = CancelBag()
        dbRepository.sources().sink(receiveCompletion: { subscriptionCompletion in
            if case Subscribers.Completion.failure(let error) = subscriptionCompletion {
                print("error = \(error)")
            }
        }, receiveValue: { value in
            sources.wrappedValue = value
        })
        .store(in: cancelBag)
    }
    
    func store(url: String, title: String?, desc: String?) {
        let cancelBag = CancelBag()
        dbRepository.store(url: url, title: title, desc: desc).sink(receiveCompletion: { subscriptionCompletion in
            if case Subscribers.Completion.failure(let error) = subscriptionCompletion {
                print("error = \(error)")
            }
        }, receiveValue: {
        })
        .store(in: cancelBag)
    }
    
    func store(source: RSS) {
        let cancelBag = CancelBag()
        dbRepository.store(sources: [source]).sink(receiveCompletion: { subscriptionCompletion in
            if case Subscribers.Completion.failure(let error) = subscriptionCompletion {
                print("error = \(error)")
            }
        }, receiveValue: {
        })
        .store(in: cancelBag)
    }
}

struct SubRSSSourcesInteractor: RSSSourcesInteractor {
    func load(sources: Binding<[RSS]>) {
    }
    
    func store(source: RSS) {
        
    }
    
    func store(url: String, title: String?, desc: String?) {
        
    }
}

final class CancelBag {
    var subscriptions = Set<AnyCancellable>()
    
    func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}

extension AnyCancellable {
    
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}

struct RootViewAppearance: ViewModifier {
    
    @Environment(\.injected) private var injected: DIContainer
    @State private var isActive: Bool = false
    let inspection = PassthroughSubject<((AnyView) -> Void), Never>()
    
    func body(content: Content) -> some View {
        content
            .onReceive(stateUpdate) { self.isActive = $0 }
            .onReceive(inspection) { callback in
                callback(AnyView(self.body(content: content)))
            }
    }
    
    private var stateUpdate: AnyPublisher<Bool, Never> {
        injected.appState.updates(for: \.system.isActive)
    }
}
