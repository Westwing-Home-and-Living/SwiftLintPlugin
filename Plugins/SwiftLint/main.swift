//
//  main.swift
//  Plugins/SwiftLint
//
//  Created by Lukas Pistrol on 23.06.22.
//
//  Big thanks to @marcoboerner on GitHub
//  https://github.com/realm/SwiftLint/issues/3840#issuecomment-1085699163
//

import PackagePlugin

@main
struct SwiftLintPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        return [
            .buildCommand(
                displayName: "Running SwiftLint for \(target.name)",
                executable: try context.tool(named: "swiftlint").path,
                arguments: [
                    "lint",
                    "--in-process-sourcekit",
                    "--path",
                    target.directory.string,
                    "--config",
                    "\(context.package.directory.string)/.swiftlint.yml",
                    "--cache-path",
                    "\(context.pluginWorkDirectory.string)/cache"
                ],
                environment: [:]
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
import Foundation

extension SwiftLintPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let rootDirectory = context.xcodeProject.directory.appending(subpath: "..").string
        let envFilePath = context.xcodeProject.directory.appending("..", ".env")
        if
            FileManager.default.fileExists(atPath: envFilePath.string),
            let fileContents = try? String(contentsOf: URL(fileURLWithPath: envFilePath.string)),
            fileContents.contains("SKIP_SWIFTLINT_BUILD_PHASE=true")
        {
            return []
        }
        return [
            .buildCommand(
                displayName: "Running SwiftLint for \(target.displayName)",
                executable: try context.tool(named: "swiftlint").path,
                arguments: [
                    "lint",
                    "--in-process-sourcekit",
                    "--path",
                    context.xcodeProject.directory.string,
                    "--config",
                    "\(rootDirectory)/.swiftlint.yml",
                    "--cache-path",
                    "\(context.pluginWorkDirectory.string)/cache"
                ],
                environment: [:]
            )
        ]
    }
}
#endif
