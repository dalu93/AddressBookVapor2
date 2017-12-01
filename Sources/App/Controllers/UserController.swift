//
//  UserController.swift
//  App
//
//  Created by D'Alberti, Luca on 10/1/17.
//

import Vapor

protocol UserControllerType {
    func loginUser(using body: UserLoginBody) throws -> User
    func registerUser(using body: UserRegistrationBody) throws -> User
}

struct UserController: UserControllerType {
    private let _jwtService = JWTService()

    func loginUser(using body: UserLoginBody) throws -> User {
        let user = try User.fromLoginWith(body.email, and: body.password)
        guard user.id != nil else {
            throw Abort.serverError
        }

        user.accessToken = _accessToken(for: user)
        return user
    }

    func registerUser(using body: UserRegistrationBody) throws -> User {
        let userToRegister = body.user
        let usersWithSameEmail = try User.makeQuery().filter(User.emailKey, userToRegister.email).all()
        guard usersWithSameEmail.count == 0 else {
            throw Abort(.forbidden)
        }

        try userToRegister.save()
        userToRegister.accessToken = _accessToken(for: userToRegister)
        return userToRegister
    }

    private func _accessToken(for user: User) -> String {
        return _jwtService.encode([
            "id": user.id!.string!,
            "email": user.email
        ])
    }
}
