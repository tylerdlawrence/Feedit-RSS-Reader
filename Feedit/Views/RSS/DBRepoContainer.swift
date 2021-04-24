//
//  DBRepoContainer.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 4/23/21.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class PersistenceManager {
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    lazy var persistentContainer: NSPersistentContainer  = {
        let container = NSPersistentContainer(name: "RSS")
        container.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        return container
    }()
}

// MARK: - NSManagedObjectContext

extension NSManagedObjectContext {
    
    func configureAsReadOnlyContext() {
        automaticallyMergesChangesFromParent = true
        mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        undoManager = nil
        shouldDeleteInaccessibleFaults = true
    }
    
    func configureAsUpdateContext() {
        mergePolicy = NSOverwriteMergePolicy
        undoManager = nil
    }
}

protocol PersistentStore {
    typealias DBOperation<Result> = (NSManagedObjectContext) throws -> Result
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error>
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>,
                     map: @escaping (T) throws -> V?) -> AnyPublisher<Array<V>, Error>
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error>
}


struct CoreDataStack: PersistentStore {
    
    private let container: NSPersistentContainer
    private let isStoreLoaded = CurrentValueSubject<Bool, Error>(false)
    private let bgQueue = DispatchQueue(label: "com.acumen.rss.coredata")
    
    private var onStoreIsReady: AnyPublisher<Void, Error> {
        return isStoreLoaded
            .filter { $0 }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    init(directory: FileManager.SearchPathDirectory = .documentDirectory,
         domainMask: FileManager.SearchPathDomainMask = .userDomainMask,
         version vNumber: UInt) {
        let version = Version(vNumber)
        container = NSPersistentContainer(name: version.modelName)
        if let url = version.dbFileURL(directory, domainMask) {
            let store = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [store]
        }
        container.loadPersistentStores { [weak isStoreLoaded, weak container] (storeDescription, error) in
            if let error = error {
                isStoreLoaded?.send(completion: .failure(error))
            } else {
                container?.viewContext.configureAsReadOnlyContext()
                isStoreLoaded?.value = true
            }
        }
        
//        container.managedObjectModel
//        bgQueue.async { [weak isStoreLoaded, weak container] in
//        }
    }
    
    func count<T>(_ fetchRequest: NSFetchRequest<T>) -> AnyPublisher<Int, Error> where T : NSFetchRequestResult {
        return onStoreIsReady
            .flatMap { [weak container] in
                Future<Int, Error> { promise in
                    do {
                        let count = try container?.viewContext.count(for: fetchRequest) ?? 0
                        promise(.success(count))
                    } catch let error {
                        promise(.failure(error))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    func fetch<T, V>(_ fetchRequest: NSFetchRequest<T>, map: @escaping (T) throws -> V?) -> AnyPublisher<Array<V>, Error> where T : NSFetchRequestResult {
        assert(Thread.isMainThread)
        let fetch = Future<Array<V>, Error> { [weak container] promise in
            guard let context = container?.viewContext else { return }
            context.performAndWait {
                do {
                    let managedObjects = try context.fetch(fetchRequest)
                    let result = managedObjects.compactMap { reqResult -> V? in
                        do {
                            let mapped = try map(reqResult)
                            if let mo = reqResult as? NSManagedObject {
                                context.refresh(mo, mergeChanges: false)
                            }
                            return mapped
                        } catch {
                            print("compactMap error: \(error)")
                            return nil
                        }
                    }
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        return onStoreIsReady
            .flatMap { fetch }
            .eraseToAnyPublisher()
    }
    
    func update<Result>(_ operation: @escaping DBOperation<Result>) -> AnyPublisher<Result, Error> {
        let update = Future<Result, Error> { [weak bgQueue, weak container] promise in
            bgQueue?.async {
                guard let context = container?.newBackgroundContext() else { return }
                context.configureAsUpdateContext()
                context.performAndWait {
                    do {
                        let result = try operation(context)
                        if context.hasChanges {
                            try context.save()
                        }
                        context.reset()
                        promise(.success(result))
                    } catch {
                        context.reset()
                        promise(.failure(error))
                    }
                }
            }
        }
        return onStoreIsReady
            .flatMap { update }
            .receive(on: DispatchQueue.main) // bgqueue
            .eraseToAnyPublisher()
    }
}

extension CoreDataStack.Version {
    static var actual: UInt { 1 }
}

extension CoreDataStack {
    struct Version {
        private let number: UInt
        
        init(_ number: UInt) {
            self.number = number
        }
        
        var modelName: String {
            return "RSS"
        }
        
        func dbFileURL(_ directory: FileManager.SearchPathDirectory,
                       _ domainMask: FileManager.SearchPathDomainMask) -> URL? {
            return FileManager.default
                .urls(for: directory, in: domainMask).first?
                .appendingPathComponent(subpathToDB)
        }
        
        private var subpathToDB: String {
            return "\(modelName).sql"
        }
    }
}


protocol RSSSourcesInteractor {
    
    func load(sources: Binding<[RSS]>)
    func store(source: RSS)
    func store(url: String, title: String, desc: String?, image: String?)
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
    
    func store(url: String, title: String, desc: String?, image: String?) {
        let cancelBag = CancelBag()
        dbRepository.store(url: url, title: title, desc: desc, image: image).sink(receiveCompletion: { subscriptionCompletion in
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

protocol RSSSourcesDBRepository {
    func hasLoadedSources() -> AnyPublisher<Bool, Error>
    func sources() -> AnyPublisher<Array<RSS>, Error>
    func store(sources: [RSS]) -> AnyPublisher<Void, Error>
    
    func store(url: String, title: String, desc: String?, image: String?) -> AnyPublisher<Void, Error>
}

struct RealRSSSourcesDBRepository: RSSSourcesDBRepository {
    
    let persistentStore: PersistentStore
    
    func hasLoadedSources() -> AnyPublisher<Bool, Error> {
        let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()
    }
    
    func sources() -> AnyPublisher<Array<RSS>, Error> {
        let fetchRequest: NSFetchRequest<RSS> = RSS.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createTime", ascending: false)]
        return persistentStore
            .fetch(fetchRequest) { $0 }
            .eraseToAnyPublisher()
    }
    
    func store(sources: [RSS]) -> AnyPublisher<Void, Error> {
        let cancelBag = CancelBag()
        return persistentStore
            .update { context in
                sources.forEach {
                    $0.store(in: context)
                    fetchNewRSS(model: $0).sink(receiveCompletion: { subscriptionCompletion in
                        if case Subscribers.Completion.failure(let error) = subscriptionCompletion {
                            print("error = \(error)")
                        }
                    }, receiveValue: { value in
                        print("value = \(String(describing: value))")
                    })
                    .store(in: cancelBag)
                }
        }
    }
    
    func store(url: String, title: String, desc: String?, image: String?) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                RSS.create(url: url, title: title, desc: desc ?? "", image: image ?? "", in: context)

            }
    }
}


struct SubRSSSourcesInteractor: RSSSourcesInteractor {
    func load(sources: Binding<[RSS]>) {
    }
    
    func store(source: RSS) {
        
    }
    
    func store(url: String, title: String, desc: String?, image: String?) {
        
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

extension DIContainer {
    struct Interactors {
        
        let rssSourcesInteractor: RSSSourcesInteractor
        
        static var stub: Self {
            .init(rssSourcesInteractor: SubRSSSourcesInteractor())
        }
    }
}

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
