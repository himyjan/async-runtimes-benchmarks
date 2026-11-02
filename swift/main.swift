import Foundation

let numTasks = CommandLine.arguments.dropFirst().compactMap { Int($0) }.first ?? 100_000

await withTaskGroup(of: Void.self) { group in
    for _ in 0..<numTasks {
        group.addTask {
            try? await Task.sleep(nanoseconds: 10_000_000_000)
        }
    }
}

print("All tasks completed")
