import Foundation

enum FruitsClientError: Equatable, Error {
    case imageCannotBeCreatedFromData(Data)
}
