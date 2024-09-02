// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser

@main
struct Executable: ParsableCommand {
    @Argument var fileName: String
    @Flag(name: .short) var debug: Bool = false
    
    public func run() throws {
        DEBUG = debug
        let (content, _) = try FileParser().getFileContents(fileName)

        do {
            let parsedContent = try JSONParser(content: content).parseObject()
            debugPrint(parsedContent)
            print("Parsing SUCCEEDED")
            Executable.exit(withError: ExitCode(rawValue: 0))
        } catch {
            print("Parsing FAILED: \(error)")
            Executable.exit(withError: ExitCode(rawValue: 1))
        }
    }
}

var DEBUG: Bool = false
func debugPrint(_ content: String) {
    if DEBUG {
        print(content)
    }
}
