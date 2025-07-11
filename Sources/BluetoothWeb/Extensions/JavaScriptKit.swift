//
//  JSPromise.swift
//  BluetoothWeb
//
//  Created by Alsey Coleman Miller on 7/9/25.
//

import JavaScriptKit

internal extension JSPromise {
    
    /// Wait for the promise to complete, returning (or throwing) its result.
    func get(
        file: StaticString = #file,
        function: StaticString = #function
    ) async throws(BluetoothWebError) -> JSValue {
        typealias Result = Swift.Result<JSValue, BluetoothWebError>
        return try await withCheckedContinuation { continuation in
            self.then(
                success: {
                    let value = Result.success($0)
                    continuation.resume(returning: value)
                    return JSValue.undefined
                },
                failure: {
                    let error = $0.forceError(file: file, function: function)
                    let value = Result.failure(error)
                    continuation.resume(returning: value)
                    return JSValue.undefined
                }
            )
        }.get()
    }
}
