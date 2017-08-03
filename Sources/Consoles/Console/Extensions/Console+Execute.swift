import Foundation
import Core

// MARK: Foreground

extension Console {
    /// Execute the program using standard IO.
    public func foregroundExecute(program: String, arguments: [String]) throws {
        let stdin = FileHandle.standardInput
        let stdout = FileHandle.standardOutput
        let stderr = FileHandle.standardError

        try action(.execute(
            program: program,
            arguments: arguments,
            input: .fileHandle(stdin),
            output: .fileHandle(stdout),
            error: .fileHandle(stderr)
        ))
    }

    /// Execute a program using an array of commands.
    public func foregroundExecute(commands: [String]) throws {
        try foregroundExecute(program: commands[0], arguments: commands.dropFirst(1).array)
    }

    /// Execute a program using a variadic array.
    public func foregroundExecute(commands: String...) throws {
        try foregroundExecute(commands: commands)
    }
}

// MARK: Background

extension Console {
    /// Execute the program in the background, returning the result of the run as bytes.
    public func backgroundExecute(program: String, arguments: [String]) throws -> Bytes {
        let input = Pipe()
        let output = Pipe()
        let error = Pipe()

        try action(.execute(
            program: program,
            arguments: arguments,
            input: .pipe(input),
            output: .pipe(output),
            error: .pipe(error)
        ))

        let bytes = output
            .fileHandleForReading
            .readDataToEndOfFile()
            .makeBytes()
        return bytes
    }

    /// Execute the program in the background, intiailizing a type with the returned bytes.
    public func backgroundExecute<T: BytesInitializable>(program: String, arguments: [String]) throws -> T {
        let bytes = try backgroundExecute(program: program, arguments: arguments) as Bytes
        return try T(bytes: bytes)
    }

    /// Execute the program in the background, intiailizing a type with the returned bytes.
    public func backgroundExecute<Type: BytesInitializable>(commands: [String]) throws -> Type {
        return try backgroundExecute(program: commands[0], arguments: commands.dropFirst(1).array)
    }

    /// Execute the program in the background, intiailizing a type with the returned bytes.
    public func backgroundExecute<Type: BytesInitializable>(commands: String...) throws -> Type {
        return try backgroundExecute(commands: commands)
    }
}
