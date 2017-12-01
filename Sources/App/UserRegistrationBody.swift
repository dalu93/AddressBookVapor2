//
//  UserRegistrationBody.swift
//  VaporTodoApp2
//
//  Created by D'Alberti, Luca on 7/29/17.
//
//

import Vapor
import Validation

struct UserRegistrationBody: ValidBody {

    let email: String
    let password: String

    var user: User {
        return User(
            email: email,
            pwd: password
        )
    }

    init(request: Request) throws {
        guard
            let email = request.data["email"]?.string,
            let password = request.data["password"]?.string else {
                throw Abort.badRequest
        }

        // Validating email
        do {
            try email.validated(by: EmailValidator())
            self.email = email
        } catch {
            // log error
            throw Abort.badRequest
        }

        // Validating password
        do {
            try password.validated(by: Count.min(8))
            self.password = password
        } catch {
            // log error
            throw Abort.badRequest
        }
    }
}

