//
//  Kdb4KeyBuilder.swift
//  KeePassCore
//
//  Created by igork on 1/17/20.
//

import Foundation
import CommonCrypto

class Kdb4KeyBuilder {
    func createCompositeKey(with credentials: KdbCredentials) throws -> Data {
        var shaContext = CC_SHA256_CTX()
        CC_SHA256_Init(&shaContext)
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        if case .password(let password) = credentials,
            let passwordData = password.data(using: .utf8) {
            _ = passwordData.withUnsafeBytes {
                CC_SHA256($0, CC_LONG(passwordData.count), &hash)
            }
        }
        
        
        _ = CC_SHA256_Update(&shaContext, &hash, CC_LONG(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256_Final(&hash, &shaContext)
        return Data(bytes: hash)
    }
    
    func createMasterKeyWith(compositeKey: Data,
                             masterSeed: Data,
                             transformSeed: Data,
                             rounds: UInt64) throws -> Data {
        var bufferSize = 0
        let cryptorRef = UnsafeMutablePointer<CCCryptorRef?>.allocate(capacity: 1)
        var result: CCCryptorStatus = transformSeed.withUnsafeBytes {
            return CCCryptorCreate(CCOperation(kCCEncrypt),
                                   CCAlgorithm(kCCAlgorithmAES128),
                                   CCOptions(kCCOptionECBMode),
                                   $0,
                                   kCCKeySizeAES256,
                                   nil,
                                   cryptorRef)
        }
        
        guard result == CCCryptorStatus(kCCSuccess) else {
            throw KdbReaderError.invalidMasterKey
        }
        
        let transformedKeyPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: compositeKey.count)
        compositeKey.copyBytes(to: transformedKeyPtr, count: compositeKey.count)
        for _ in 0..<rounds {
            result = CCCryptorUpdate(cryptorRef.pointee,
                                     transformedKeyPtr,
                                     32,
                                     transformedKeyPtr,
                                     32,
                                     &bufferSize)
            guard result == CCCryptorStatus(kCCSuccess) else {
                throw KdbReaderError.invalidMasterKey
            }
        }
        
        cryptorRef.deallocate()
        CC_SHA256(transformedKeyPtr, 32, transformedKeyPtr)
        
        var shaContext = CC_SHA256_CTX()
        CC_SHA256_Init(&shaContext)
        masterSeed.withUnsafeBytes { bytes -> Void in
            CC_SHA256_Update(&shaContext, bytes, CC_LONG(masterSeed.count))
        }
        
        CC_SHA256_Update(&shaContext, transformedKeyPtr, 32)
        transformedKeyPtr.deallocate()
        
        var masterKey = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256_Final(&masterKey, &shaContext)
        
        return Data(masterKey)
    }

    func createMasterKeyWith(credentials: KdbCredentials,
                             masterSeed: Data,
                             transformSeed: Data,
                             rounds: UInt64) throws -> Data {
        let compositeKey = try createCompositeKey(with: credentials)
        let masterKey = try createMasterKeyWith(compositeKey: compositeKey,
                                            masterSeed: masterSeed,
                                            transformSeed: transformSeed,
                                            rounds: rounds)
        return masterKey
    }
}
