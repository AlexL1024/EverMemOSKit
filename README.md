# EverMemOSKit

EverMemOSKit is a Swift SDK for integrating EverMemOS memory into iOS and macOS apps.

## 1. Project

### What this project is

EverMemOSKit is a standalone Swift Package Manager SDK that provides a typed client for the EverMemOS API. It is designed for apps that want persistent memory, retrieval, and memory-aware chat without writing raw networking and decoding logic from scratch.

### Main features

- Swift Package Manager package for easy integration
- Async/await API client
- Bearer token and HMAC authentication
- Memory write, fetch, search, delete, and redact support
- SSE chat streaming support
- Typed request and response models
- Automated tests for core API behavior

### All source code

This repository contains all source code for the project, including:

- SDK source code in `Sources/`
- Tests in `Tests/`
- Example integration notes in `Examples/`
- Documentation site files in `docs/`

### How I use memory

This SDK exposes memory-native APIs so apps can:

- store new information with `memorize`
- retrieve prior memories with `fetchMemories`
- search relevant context with `searchMemories`
- stream memory-aware chat with `chatStream`

A typical app flow is:

1. Save important user or conversation information into EverMemOS.
2. Retrieve that information later when the user returns.
3. Use retrieved memory to produce better, more contextual responses and behavior.

### How this memory helps users

Memory helps users by allowing apps to remember context across sessions instead of starting from zero every time.

This can help with:

- continuity in conversations
- remembering user preferences
- recalling prior interactions
- producing more useful and personalized responses

## 2. Video

English demo video:

[LINK TO BE ADDED]

The video covers:

- the main features of EverMemOSKit
- how memory is used through the SDK
- how persistent memory helps end users

## 3. Deployed URL

Project page / deployed URL:

[LINK TO BE ADDED]

This URL lets visitors view a public overview of the project.

## Installation

Add the package in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AlexL1024/EverMemOSKit.git", from: "0.1.0")
]
