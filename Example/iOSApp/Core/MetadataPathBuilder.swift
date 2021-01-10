//
//  MetadataPathBuilder.swift
//  iOSApp
//
//  Created by Igor Kotkovets on 6/15/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct MetadataPathBuilder {

    func createMetadataFileURLForFileURL(_ url: URL) -> URL {
        let originFileName = url.lastPathComponent
        let metaFileName = originFileName.appending(metadataFilesSuffix)
        let urlWithoutOriginFileName = url.deletingLastPathComponent()
        let metaFileURL = urlWithoutOriginFileName.appendingPathComponent(metaFileName)
        return metaFileURL
    }

    func buildMetadataFilePathForOriginFileURL(_ url: URL) -> String {
        let fullURL = createMetadataFileURLForFileURL(url)
        return fullURL.path
    }


}
