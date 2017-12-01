//
//  JWTService.swift
//  VaporTodoApp2
//
//  Created by D'Alberti, Luca on 7/29/17.
//
//

import Foundation
import JWT

private let jwtSecret = "testtest"
private let issuer = "AddressBook"

final class JWTService {

    func decode(_ token: String) throws -> Payload {
        return try JWT.decode(token, algorithm: .hs256(jwtSecret.data(using: .utf8)!))
    }

    func encode(_ payload: Payload) -> String {
        return JWT.encode(.hs256(jwtSecret.data(using: .utf8)!)) { builder in
            payload.forEach { key, value in
                builder[key] = value
            }

            builder.issuer = issuer
            builder.issuedAt = Date()
            builder.expiration = builder.issuedAt?.addingTimeInterval(30 * 60)
        }
    }
}

