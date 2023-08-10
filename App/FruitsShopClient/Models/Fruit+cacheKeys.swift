extension Product {

    var thumbnailCacheKey: String {
        "thumbnail_\(id)"
    }

    var imageCacheKey: String {
        "image_\(id)"
    }
}
