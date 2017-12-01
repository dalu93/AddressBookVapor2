//
//  UserMiddleware.swift
//  VaporTodoApp2
//
//  Created by D'Alberti, Luca on 7/29/17.
//
//

import Vapor
import JWT

fileprivate let _jwtService = JWTService()

extension Request {

    var accessToken: String? {
        return headers["accessToken"]?.string ?? data["access_token"]?.string
    }

    func checkUser() throws {
        guard
            let token = accessToken,
            let _ = try? _jwtService.decode(token) else {
                throw Abort(.unauthorized, reason: "Unauthorized")
        }
    }

    func getUserId() throws -> Identifier {
        guard let token = accessToken else {
            throw Abort(.unauthorized, reason: "Unauthorized")
        }

        let userInfo = try _jwtService.decode(token)
        guard let userId = userInfo["id"] as? String else {
            throw Abort.badRequest
        }

        // TODO: really ugly here
        return Identifier(.string(userId))
    }
}

class UserMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        try request.checkUser()
        let response = try next.respond(to: request)
        return response
    }
}

