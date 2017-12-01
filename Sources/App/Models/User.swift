//
//  User.swift
//  App
//
//  Created by D'Alberti, Luca on 9/30/17.
//

import Vapor
import FluentProvider
import HTTP

final class User: Model {
    let storage = Storage()

    // MARK: Properties and database keys

    /// The email of the user
    var email: String

    /// The password of the user
    fileprivate var password: String

    /// The user access token to server
    var accessToken: String?

    /// The column names user in database
    static let idKey = "id"
    static let emailKey = "email"
    static let passwordKey = "pwd"
    static let accessTokenKey = "accessToken"

    /// Creates a new User
    init(email: String, pwd: String) {
        self.email = email
        self.password = pwd
    }

    // MARK: Fluent Serialization

    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        email = try row.get(User.emailKey)
        password = try row.get(User.passwordKey)
    }

    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.emailKey, email)
        try row.set(User.passwordKey, password)
        return row
    }
}

// MARK: Fluent Preparation
extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.emailKey, optional: false, unique: true)
            builder.string(User.passwordKey, optional: false)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            email: json.get(User.emailKey),
            pwd: json.get(User.passwordKey)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id)
        try json.set(User.emailKey, email)
        try json.set(User.accessTokenKey, accessToken)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

// MARK: - API
extension User {
    static func get(with email: String) throws -> User {
        let foundUsers = try User
            .makeQuery()
            .filter(User.emailKey, email)
            .all()

        guard foundUsers.count == 1 else {
            throw Abort(
                .internalServerError,
                reason: "Email is a unique field. Found more than one record with same value. Not expected")
        }

        return foundUsers.first!
    }

    static func fromLoginWith(_ email: String, and password: String) throws -> User {
        let foundUsers = try User
            .makeQuery()
            .filter(User.emailKey, email)
            .filter(User.passwordKey, password)
            .all()

        guard foundUsers.count > 0 else {
            throw Abort.notFound
        }

        guard foundUsers.count == 1 else {
            throw Abort(
                .internalServerError,
                reason: "Email is a unique field. Found more than one record with same value. Not expected")
        }

        return foundUsers.first!
    }
}
