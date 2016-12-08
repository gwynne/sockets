//
//  OptionsTests.swift
//  Socks
//
//  Created by Andreas Ley on 20.10.16.
//
//

#if os(Linux)
    import Glibc
    private let s_socket = Glibc.socket
    private let s_close = Glibc.close
#else
    import Darwin
    private let s_socket = Darwin.socket
    private let s_close = Darwin.close
#endif

import XCTest
@testable import SocksCore

class OptionsTests: XCTestCase {
    
    func testSocketOptions() throws {
        let address = InternetAddress(hostname: "0.0.0.0", port: 0)
        let socket = try TCPInternetSocket(address: address)
        
        try socket.setReuseAddress(true)
        let reuseAddress = try socket.getReuseAddress()
        XCTAssert(reuseAddress == true)
        
        try socket.setKeepAlive(true)
        let keepAlive = try socket.getKeepAlive()
        XCTAssertEqual(keepAlive, true)
        
        let expectedTimeout = timeval(seconds: 0.987)
        
        try socket.setSendingTimeout(expectedTimeout)
        let sendingTimeout = try socket.getSendingTimeout()
        XCTAssertEqual(sendingTimeout, expectedTimeout)
        
        try socket.setReceivingTimeout(expectedTimeout)
        let receivingTimeout = try socket.getReceivingTimeout()
        XCTAssertEqual(receivingTimeout, expectedTimeout)
    }
    
    func testReadingSocketOptionOnClosedSocket() throws {
        let address = InternetAddress(hostname: "0.0.0.0", port: 0)
        let socket = try TCPInternetSocket(address: address)

        try socket.close()
        do {
            _ = try socket.getSendingTimeout()
        }
        catch let error as SocksError {
            guard case ErrorReason.optionGetFailed(level: SOL_SOCKET, name: SO_SNDTIMEO, type: "timeval") = error.type else {
                XCTFail()
                return
            }
        }
        catch {
            XCTFail("Wrong error")
        }
        
    }
}
