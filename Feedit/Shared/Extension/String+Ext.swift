//
//  String+Ext.swift
//  Feedit
//
//  Created by Tyler D Lawrence on 8/10/20.
//

import Foundation
import UIKit
import Compression

extension String {

    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
    
    var trimHTMLTag: String {
        return replacingOccurrences(of:"<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var trimWhiteAndSpace: String {
        return replacingOccurrences(of: "\n", with: "")
    }
    
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
     
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    func toPermissiveDate() -> Date? {
        return RFC822DateFormatter().date(from: self) ??
            (RFC3339DateFormatter().date(from: self) ??
            ISO8601DateFormatter().date(from: self))
    }
    
}

public extension String {

    /// Escapes special HTML characters.
    ///
    /// Escaped characters are `&`, `<`, `>`, `"`, and `'`.
    var escapedHTML: String {
        var escaped = String()

        for char in self {
            switch char {
                case "&":
                    escaped.append("&amp;")
                case "<":
                    escaped.append("&lt;")
                case ">":
                    escaped.append("&gt;")
                case "\"":
                    escaped.append("&quot;")
                case "'":
                    escaped.append("&apos;")
                default:
                    escaped.append(char)
            }
        }

        return escaped
    }
    
}

public extension Bool {
    /// SwifterSwift: Return 1 if true, or 0 if false.
    ///
    ///        false.int -> 0
    ///        true.int -> 1
    ///
    var int: Int {
        return self ? 1 : 0
    }

    /// SwifterSwift: Return "true" if true, or "false" if false.
    ///
    ///        false.string -> "false"
    ///        true.string -> "true"
    ///
    var string: String {
        return self ? "true" : "false"
    }
}

public extension String {

    /// The IDNA-encoded representation of a Unicode domain.
    ///
    /// This will properly split domains on periods; e.g.,
    /// "www.bücher.ch" becomes "www.xn--bcher-kva.ch".
    var idnaEncoded: String? {
        guard let mapped = try? self.mapUTS46() else { return nil }

        let nonASCII = CharacterSet(charactersIn: UnicodeScalar(0)...UnicodeScalar(127)).inverted
        var result = ""

        let s = Scanner(string: mapped.precomposedStringWithCanonicalMapping)
        let dotAt = CharacterSet(charactersIn: ".@")

        while !s.isAtEnd {
            if let input = s.shimScanUpToCharacters(from: dotAt) {
                if !input.isValidLabel { return nil }

                if input.rangeOfCharacter(from: nonASCII) != nil {
                    result.append("xn--")

                    if let encoded = input.punycodeEncoded {
                        result.append(encoded)
                    }
                } else {
                    result.append(input)
                }
            }

            if let input = s.shimScanCharacters(from: dotAt) {
                result.append(input)
            }
        }

        return result
    }

    /// The Unicode representation of an IDNA-encoded domain.
    ///
    /// This will properly split domains on periods; e.g.,
    /// "www.xn--bcher-kva.ch" becomes "www.bücher.ch".
    var idnaDecoded: String? {
        var result = ""
        let s = Scanner(string: self)
        let dotAt = CharacterSet(charactersIn: ".@")

        while !s.isAtEnd {
            if let input = s.shimScanUpToCharacters(from: dotAt) {
                if input.lowercased().hasPrefix("xn--") {
                    let start = input.index(input.startIndex, offsetBy: 4)
                    guard let substr = input[start...].punycodeDecoded else { return nil }
                    guard substr.isValidLabel else { return nil }
                    result.append(substr)
                } else {
                    result.append(input)
                }
            }

            if let input = s.shimScanCharacters(from: dotAt) {
                result.append(input)
            }
        }

        return result
    }

    /// The IDNA- and percent-encoded representation of a URL string.
    var encodedURLString: String? {
        let urlParts = self.urlParts
        var pathAndQuery = urlParts.pathAndQuery

        var allowedCharacters = CharacterSet.urlPathAllowed
        allowedCharacters.insert(charactersIn: "%?")
        pathAndQuery = pathAndQuery.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? ""

        var result = "\(urlParts.scheme)\(urlParts.delim)"

        if let username = urlParts.username?.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) {
            if let password = urlParts.password?.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed) {
                result.append("\(username):\(password)@")
            } else {
                result.append("\(username)@")
            }
        }

        guard let host = urlParts.host.idnaEncoded else { return nil }

        result.append("\(host)\(pathAndQuery)")

        if var fragment = urlParts.fragment {
            var fragmentAlloweCharacters = CharacterSet.urlFragmentAllowed
            fragmentAlloweCharacters.insert(charactersIn: "%")
            fragment = fragment.addingPercentEncoding(withAllowedCharacters: fragmentAlloweCharacters) ?? ""

            result.append("#\(fragment)")
        }

        return result
    }

    /// The Unicode representation of an IDNA- and percent-encoded URL string.
    var decodedURLString: String? {
        let urlParts = self.urlParts
        var usernamePassword = ""

        if let username = urlParts.username?.removingPercentEncoding {
            if let password = urlParts.password?.removingPercentEncoding {
                usernamePassword = "\(username):\(password)@"
            } else {
                usernamePassword = "\(username)@"
            }
        }

        guard let host = urlParts.host.idnaDecoded else { return nil }

        var result = "\(urlParts.scheme)\(urlParts.delim)\(usernamePassword)\(host)\(urlParts.pathAndQuery.removingPercentEncoding ?? "")"

        if let fragment = urlParts.fragment?.removingPercentEncoding {
            result.append("#\(fragment)")
        }

        return result
    }

}

public extension URL {

    /// Initializes a URL with a Unicode URL string.
    ///
    /// If `unicodeString` can be successfully encoded, equivalent to
    ///
    /// ```
    /// URL(string: unicodeString.encodedURLString!)
    /// ```
    ///
    /// - Parameter unicodeString: The unicode URL string with which to create a URL.
    init?(unicodeString: String) {
        if let url = URL(string: unicodeString) {
            self = url
            return
        }

        guard let encodedString = unicodeString.encodedURLString else { return nil }
        self.init(string: encodedString)
    }

    /// The IDNA- and percent-decoded representation of the URL.
    ///
    /// Equivalent to
    ///
    ///    ```
    /// self.absoluteString.decodedURLString
    /// ```
    var decodedURLString: String? {
        return self.absoluteString.decodedURLString
    }

    /// Initializes a URL from a relative Unicode string and a base URL.
    /// - Parameters:
    ///   - unicodeString: The URL string with which to initialize the NSURL object. `unicodeString` is interpreted relative to `baseURL`.
    ///   - url: The base URL for the URL object
    init?(unicodeString: String, relativeTo url: URL?) {
        if let url = URL(string: unicodeString, relativeTo: url) {
            self = url
            return
        }

        let parts = unicodeString.urlParts

        if !parts.host.isEmpty {
            guard let encodedString = unicodeString.encodedURLString else { return nil }
            self.init(string: encodedString, relativeTo: url)
        } else {
            var allowedCharacters = CharacterSet.urlPathAllowed
            allowedCharacters.insert(charactersIn: "%?#")
            guard let encoded = unicodeString.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
            self.init(string: encoded, relativeTo: url)
        }
    }

}

extension StringProtocol {

    /// Punycode-encodes a string.
    ///
    /// Returns `nil` on error.
    /// - Todo: Throw errors on failure instead of returning `nil`.
    var punycodeEncoded: String? {
        var result = ""
        let scalars = self.unicodeScalars
        let inputLength = scalars.count

        var n = Punycode.initialN
        var delta: UInt32 = 0
        var outLen: UInt32 = 0
        var bias = Punycode.initialBias

        for scalar in scalars where scalar.isASCII {
            result.unicodeScalars.append(scalar)
            outLen += 1
        }

        let b: UInt32 = outLen
        var h: UInt32 = outLen

        if b > 0 {
            result.append(Punycode.delimiter)
        }

        // Main encoding loop:

        while h < inputLength {
            var m = UInt32.max

            for c in scalars {
                if c.value >= n && c.value < m {
                    m = c.value
                }
            }

            if m - n > (UInt32.max - delta) / (h + 1) {
                return nil // overflow
            }

            delta += (m - n) * (h + 1)
            n = m

            for c in scalars {

                if c.value < n {
                    delta += 1

                    if delta == 0 {
                        return nil // overflow
                    }
                }

                if c.value == n {
                    var q = delta
                    var k = Punycode.base

                    while true {
                        let t = k <= bias ? Punycode.tmin :
                            k >= bias + Punycode.tmax ? Punycode.tmax : k - bias

                        if q < t {
                            break
                        }

                        let encodedDigit = Punycode.encodeDigit(t + (q - t) % (Punycode.base - t), flag: false)

                        result.unicodeScalars.append(UnicodeScalar(encodedDigit)!)
                        q = (q - t) / (Punycode.base - t)

                        k += Punycode.base
                    }

                    result.unicodeScalars.append(UnicodeScalar(Punycode.encodeDigit(q, flag: false))!)
                    bias = Punycode.adapt(delta: delta, numPoints: h + 1, firstTime: h == b)
                    delta = 0
                    h += 1
                }
            }

            delta += 1
            n += 1
        }

        return result
    }

    /// Punycode-decodes a string.
    ///
    /// Returns `nil` on error.
    /// - Todo: Throw errors on failure instead of returning `nil`.
    var punycodeDecoded: String? {
        var result = ""
        let scalars = self.unicodeScalars

        let endIndex = scalars.endIndex
        var n = Punycode.initialN
        var outLen: UInt32 = 0
        var i: UInt32 = 0
        var bias = Punycode.initialBias

        var b = scalars.startIndex

        for j in scalars.indices {
            if Character(self.unicodeScalars[j]) == Punycode.delimiter {
                b = j
                break
            }
        }

        for j in scalars.indices {
            if j >= b {
                break
            }

            let scalar = scalars[j]

            if !scalar.isASCII {
                return nil // bad input
            }

            result.unicodeScalars.append(scalar)
            outLen += 1

        }

        var inPos = b > scalars.startIndex ? scalars.index(after: b) : scalars.startIndex

        while inPos < endIndex {

            var k = Punycode.base
            var w: UInt32 = 1
            let oldi = i

            while true {
                if inPos >= endIndex {
                    return nil // bad input
                }

                let digit = Punycode.decodeDigit(scalars[inPos].value)

                inPos = scalars.index(after: inPos)

                if digit >= Punycode.base { return nil } // bad input
                if digit > (UInt32.max - i) / w { return nil } // overflow

                i += digit * w
                let t = k <= bias ? Punycode.tmin :
                    k >= bias + Punycode.tmax ? Punycode.tmax : k - bias

                if digit < t {
                    break
                }

                if w > UInt32.max / (Punycode.base - t) { return nil } // overflow

                w *= Punycode.base - t

                k += Punycode.base
            }

            bias = Punycode.adapt(delta: i - oldi, numPoints: outLen + 1, firstTime: oldi == 0)

            if i / (outLen + 1) > UInt32.max - n { return nil } // overflow

            n += i / (outLen + 1)
            i %= outLen + 1

            let index = result.unicodeScalars.index(result.unicodeScalars.startIndex, offsetBy: Int(i))
            result.unicodeScalars.insert(UnicodeScalar(n)!, at: index)
            
            outLen += 1
            i += 1
        }

        return result
    }

}

// Wrapper functions for < 10.15 compatibility
// TODO: Remove when support for < 10.15 is dropped.
extension Scanner {

    func shimScanUpToCharacters(from set: CharacterSet) -> String? {
        if #available(macOS 10.15, iOS 13.0, *) {
            return self.scanUpToCharacters(from: set)
        } else {
            var str: NSString?
            self.scanUpToCharacters(from: set, into: &str)
            return str as String?
        }
    }

    func shimScanCharacters(from set: CharacterSet) -> String? {
        if #available(macOS 10.15, iOS 13.0, *) {
            return self.scanCharacters(from: set)
        } else {
            var str: NSString?
            self.scanCharacters(from: set, into: &str)
            return str as String?
        }
    }

    func shimScanUpToString(_ substring: String) -> String? {
        if #available(macOS 10.15, iOS 13.0, *) {
            return self.scanUpToString(substring)
        } else {
            var str: NSString?
            self.scanUpTo(substring, into: &str)
            return str as String?
        }
    }

    func shimScanString(_ searchString: String) -> String? {
        if #available(macOS 10.15, iOS 13.0, *) {
            return self.scanString(searchString)
        } else {
            var str: NSString?
            self.scanString(searchString, into: &str)
            return str as String?
        }
    }

}


extension String {

    var urlParts: URLParts {
        let colonSlash = CharacterSet(charactersIn: ":/")
        let slashQuestion = CharacterSet(charactersIn: "/?")
        let s = Scanner(string: self)
        var scheme = ""
        var delim = ""
        var host = ""
        var path = ""
        var username: String?
        var password: String?
        var fragment: String?

        if let hostOrScheme = s.shimScanUpToCharacters(from: colonSlash) {
            let maybeDelim = s.shimScanCharacters(from: colonSlash) ?? ""

            if maybeDelim.hasPrefix(":") {
                delim = maybeDelim
                scheme = hostOrScheme
                host = s.shimScanUpToCharacters(from: slashQuestion) ?? ""
            } else {
                path.append(hostOrScheme)
                path.append(maybeDelim)
            }
        } else if let maybeDelim = s.shimScanString("//") {
            delim = maybeDelim

            if let maybeHost = s.shimScanUpToCharacters(from: slashQuestion) {
                host = maybeHost
            }
        }

        path.append(s.shimScanUpToString("#") ?? "")

        if s.shimScanString("#") != nil {
            fragment = s.shimScanUpToCharacters(from: .newlines) ?? ""
        }

        let usernamePasswordHostPort = host.components(separatedBy: "@")

        switch usernamePasswordHostPort.count {
            case 1:
                host = usernamePasswordHostPort[0]
            case 0:
                break // error
            default:
                let usernamePassword = usernamePasswordHostPort[0].components(separatedBy: ":")
                username = usernamePassword[0]
                password = usernamePassword.count > 1 ? usernamePassword[1] : nil
                host = usernamePasswordHostPort[1]
        }

        return URLParts(scheme: scheme, delim: delim, host: host, pathAndQuery: path, username: username, password: password, fragment: fragment)
    }

    enum UTS46MapError: Error {
        /// A disallowed codepoint was found in the string.
        case disallowedCodepoint(scalar: UnicodeScalar)
    }

    /// Perform a single-pass mapping using UTS #46.
    ///
    /// - Returns: The mapped string.
    /// - Throws: `UTS46Error`.
    func mapUTS46() throws -> String {
        try UTS46.loadIfNecessary()

        var result = ""

        for scalar in self.unicodeScalars {
            if UTS46.disallowedCharacters.contains(scalar) {
                throw UTS46MapError.disallowedCodepoint(scalar: scalar)
            }

            if UTS46.ignoredCharacters.contains(scalar) {
                continue
            }

            if let mapped = UTS46.characterMap[scalar.value] {
                result.append(mapped)
            } else {
                result.unicodeScalars.append(scalar)
            }
        }

        return result
    }

    var isValidLabel: Bool {
        guard self.precomposedStringWithCanonicalMapping.unicodeScalars.elementsEqual(self.unicodeScalars) else { return false }

        guard (try? self.mapUTS46()) != nil else { return false }

        if let category = self.unicodeScalars.first?.properties.generalCategory {
            if category == .nonspacingMark || category == .spacingMark || category == .enclosingMark { return false }
        }

        return self.hasValidJoiners
    }

    /// Whether a string's joiners (if any) are valid according to IDNA 2008 ContextJ.
    ///
    /// See [RFC 5892, Appendix A.1 and A.2](https://tools.ietf.org/html/rfc5892#appendix-A).
    var hasValidJoiners: Bool {
        try! UTS46.loadIfNecessary()
        
        let scalars = self.unicodeScalars

        for index in scalars.indices {
            let scalar = scalars[index]

            if scalar.value == 0x200C { // Zero-width non-joiner
                if index == scalars.indices.first { return false }

                var subindex = scalars.index(before: index)
                var previous = scalars[subindex]

                if previous.properties.canonicalCombiningClass == .virama { continue }

                while true {
                    guard let joiningType = UTS46.joiningTypes[previous.value] else { return false }

                    if joiningType == .transparent {
                        if subindex == scalars.startIndex {
                            return false
                        }

                        subindex = scalars.index(before: subindex)
                        previous = scalars[subindex]
                    } else if joiningType == .dual || joiningType == .left {
                        break
                    } else {
                        return false
                    }
                }

                subindex = scalars.index(after: index)
                var next = scalars[subindex]

                while true {
                    if subindex == scalars.endIndex {
                        return false
                    }

                    guard let joiningType = UTS46.joiningTypes[next.value] else { return false }

                    if joiningType == .transparent {
                        subindex = scalars.index(after: index)
                        next = scalars[subindex]
                    } else if joiningType == .right || joiningType == .dual {
                        break
                    } else {
                        return false
                    }
                }
            } else if scalar.value == 0x200D { // Zero-width joiner
                if index == scalars.startIndex { return false }

                let subindex = scalars.index(before: index)
                let previous = scalars[subindex]

                if previous.properties.canonicalCombiningClass != .virama { return false }
            }
        }

        return true
    }

}

enum Punycode {
    static let base = UInt32(36)
    static let tmin = UInt32(1)
    static let tmax = UInt32(26)
    static let skew = UInt32(38)
    static let damp = UInt32(700)
    static let initialBias = UInt32(72)
    static let initialN = UInt32(0x80)
    static let delimiter: Character = "-"

    static func decodeDigit(_ cp: UInt32) -> UInt32 {
        return cp &- 48 < 10 ? cp &- 22 : cp &- 65 < 26 ? cp &- 65 :
            cp &- 97 < 26 ? cp &- 97 : Self.base
    }

    static func encodeDigit(_ d: UInt32, flag: Bool) -> UInt32 {
        return d + 22 + 75 * UInt32(d < 26 ? 1 : 0) - ((flag ? 1 : 0) << 5)
    }

    static let maxint = UInt32.max

    static func adapt(delta: UInt32, numPoints: UInt32, firstTime: Bool) -> UInt32 {

        var delta = delta

        delta = firstTime ? delta / Self.damp : delta >> 1
        delta += delta / numPoints

        var k: UInt32 = 0

        while delta > ((Self.base - Self.tmin) * Self.tmax) / 2 {
            delta /= Self.base - Self.tmin
            k += Self.base
        }

        return k + (Self.base - Self.tmin + 1) * delta / (delta + Self.skew)
    }
}

struct URLParts {
    var scheme: String
    var delim: String
    var host: String
    var pathAndQuery: String

    var username: String?
    var password: String?
    var fragment: String?
}

class UTS46 {

    static var characterMap: [UInt32: String] = [:]
    static var ignoredCharacters: CharacterSet = []
    static var disallowedCharacters: CharacterSet = []
    static var joiningTypes = [UInt32: JoiningType]()

    static var isLoaded = false

    enum Marker {
        static let characterMap = UInt8.max
        static let ignoredCharacters = UInt8.max - 1
        static let disallowedCharacters = UInt8.max - 2
        static let joiningTypes = UInt8.max - 3

        static let min = UInt8.max - 10 // No valid UTF-8 byte can fall here.

        static let sequenceTerminator: UInt8 = 0
    }

    enum JoiningType: Character {
        case causing = "C"
        case dual = "D"
        case right = "R"
        case left = "L"
        case transparent = "T"
    }

    enum UTS46Error: Error {
        case badSize
        case compressionError
        case decompressionError
        case badMarker
        case unknownVersion
    }

    /// Identical values to `NSData.CompressionAlgorithm + 1`.
    enum CompressionAlgorithm: UInt8 {
        case none = 0
        case lzfse = 1
        case lz4 = 2
        case lzma = 3
        case zlib = 4

        var rawAlgorithm: compression_algorithm? {
            switch self {
                case .lzfse:
                    return COMPRESSION_LZFSE
                case .lz4:
                    return COMPRESSION_LZ4
                case .lzma:
                    return COMPRESSION_LZMA
                case .zlib:
                    return COMPRESSION_ZLIB
                default:
                    return nil
            }
        }
    }

    struct Header: RawRepresentable, CustomDebugStringConvertible {
        typealias RawValue = [UInt8]

        var rawValue: [UInt8] {
            let value = Self.signature + [version, flags.rawValue]
            assert(value.count == 8)
            return value
        }

        private static let compressionMask: UInt8 = 0x07
        private static let signature: [UInt8] = Array("UTS#46".utf8)

        private struct Flags: RawRepresentable {
            var rawValue: UInt8 {
                return (hasCRC ? hasCRCMask : 0) | compression.rawValue
            }

            var hasCRC: Bool
            var compression: CompressionAlgorithm

            private let hasCRCMask: UInt8 = 1 << 3
            private let compressionMask: UInt8 = 0x7

            init(rawValue: UInt8) {
                hasCRC = rawValue & hasCRCMask != 0
                let compressionBits = rawValue & compressionMask

                compression = CompressionAlgorithm(rawValue: compressionBits) ?? .none
            }

            init(compression: CompressionAlgorithm = .none, hasCRC: Bool = false) {
                self.compression = compression
                self.hasCRC = hasCRC
            }
        }

        let version: UInt8
        private var flags: Flags
        var hasCRC: Bool { flags.hasCRC }
        var compression: CompressionAlgorithm { flags.compression }
        var dataOffset: Int { 8 + (flags.hasCRC ? 4 : 0) }

        init?<T: DataProtocol>(rawValue: T) where T.Index == Int {
            guard rawValue.count == 8 else { return nil }
            guard rawValue.prefix(Self.signature.count).elementsEqual(Self.signature) else { return nil }

            version = rawValue[rawValue.index(rawValue.startIndex, offsetBy: 6)]
            flags = Flags(rawValue: rawValue[rawValue.index(rawValue.startIndex, offsetBy: 7)])
        }

        init(compression: CompressionAlgorithm = .none, hasCRC: Bool = false) {
            self.version = 1
            self.flags = Flags(compression: compression, hasCRC: hasCRC)
        }

        var debugDescription: String { "has CRC: \(hasCRC); compression: \(String(describing: compression))" }
    }

}

extension UTS46 {

    private static func parseHeader(from data: Data) throws -> Header? {
        let headerData = data.prefix(8)

        guard headerData.count == 8 else { throw UTS46Error.badSize }

        return Header(rawValue: headerData)
    }

    static func load(from url: URL) throws {
        let fileData = try Data(contentsOf: url)

        guard let header = try? parseHeader(from: fileData) else { return }

        guard header.version == 1 else { throw UTS46Error.unknownVersion }

        let offset = header.dataOffset

        guard fileData.count > offset else { throw UTS46Error.badSize }

        let compressedData = fileData[offset...]

        guard let data = self.decompress(data: compressedData, algorithm: header.compression) else {
            throw UTS46Error.decompressionError
        }

        var index = 0

        while index < data.count {
            let marker = data[index]

            index += 1

            switch marker {
                case Marker.characterMap:
                    index = parseCharacterMap(from: data, start: index)
                case Marker.ignoredCharacters:
                    index = parseIgnoredCharacters(from: data, start: index)
                case Marker.disallowedCharacters:
                    index = parseDisallowedCharacters(from: data, start: index)
                case Marker.joiningTypes:
                    index = parseJoiningTypes(from: data, start: index)
                default:
                    throw UTS46Error.badMarker
            }
        }

        isLoaded = true
    }

    static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: Self.self)
        #endif
    }

    static func loadIfNecessary() throws {
        guard !isLoaded else { return }
        guard let url = Self.bundle.url(forResource: "uts46", withExtension: nil) else { throw CocoaError(.fileNoSuchFile) }

        try load(from: url)
    }

    private static func decompress(data: Data, algorithm: CompressionAlgorithm?) -> Data? {

        guard let rawAlgorithm = algorithm?.rawAlgorithm else { return data }

        let capacity = 131_072 // 128 KB
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)

        let decompressed = data.withUnsafeBytes { (rawBuffer) -> Data? in
            let bound = rawBuffer.bindMemory(to: UInt8.self)
            let decodedCount = compression_decode_buffer(destinationBuffer, capacity, bound.baseAddress!, rawBuffer.count, nil, rawAlgorithm)

            if decodedCount == 0 || decodedCount == capacity {
                return nil
            }

            return Data(bytes: destinationBuffer, count: decodedCount)
        }

        return decompressed
    }

    private static func parseCharacterMap(from data: Data, start: Int) -> Int {
        characterMap.removeAll()
        var index = start

        main: while index < data.count {
            var accumulator = Data()

            while data[index] != Marker.sequenceTerminator {
                if data[index] > Marker.min { break main }

                accumulator.append(data[index])
                index += 1
            }

            let str = String(data: accumulator, encoding: .utf8)!

            // FIXME: throw an error here.
            guard str.count > 0 else { continue }

            let codepoint = str.unicodeScalars.first!.value

            characterMap[codepoint] = String(str.unicodeScalars.dropFirst())

            index += 1
        }

        return index
    }

    private static func parseRanges(from: String) -> [ClosedRange<UnicodeScalar>]? {
        guard from.unicodeScalars.count % 2 == 0 else { return nil }

        var ranges = [ClosedRange<UnicodeScalar>]()
        var first: UnicodeScalar?

        for (index, scalar) in from.unicodeScalars.enumerated() {
            if index % 2 == 0 {
                first = scalar
            } else if let first = first {
                ranges.append(first...scalar)
            }
        }

        return ranges
    }

    static func parseCharacterSet(from data: Data, start: Int) -> (index: Int, charset: CharacterSet?) {
        var index = start
        var accumulator = Data()

        while index < data.count, data[index] < Marker.min {
            accumulator.append(data[index])
            index += 1
        }

        let str = String(data: accumulator, encoding: .utf8)!

        guard let ranges = parseRanges(from: str) else {
            return (index: index, charset: nil)
        }

        var charset = CharacterSet()

        for range in ranges {
            charset.insert(charactersIn: range)
        }

        return (index: index, charset: charset)
    }

    static func parseIgnoredCharacters(from data: Data, start: Int) -> Int {
        let (index, charset) = parseCharacterSet(from: data, start: start)

        if let charset = charset {
            ignoredCharacters = charset
        }

        return index
    }

    static func parseDisallowedCharacters(from data: Data, start: Int) -> Int {
        let (index, charset) = parseCharacterSet(from: data, start: start)

        if let charset = charset {
            disallowedCharacters = charset
        }

        return index
    }

    static func parseJoiningTypes(from data: Data, start: Int) -> Int {
        var index = start
        joiningTypes.removeAll()

        main: while index < data.count, data[index] < Marker.min {
            var accumulator = Data()

            while index < data.count {
                if data[index] > Marker.min { break main }
                accumulator.append(data[index])

                index += 1
            }

            let str = String(data: accumulator, encoding: .utf8)!

            var type: JoiningType?
            var first: UnicodeScalar?

            for scalar in str.unicodeScalars {
                if scalar.isASCII {
                    type = JoiningType(rawValue: Character(scalar))
                } else if let type = type {
                    if first == nil {
                        first = scalar
                    } else {
                        for value in first!.value...scalar.value {
                            joiningTypes[value] = type
                        }

                        first = nil
                    }
                }
            }
        }

        return index
    }

}
