//
//  CSVExportItem.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/11/26.
//

import CoreTransferable
import UniformTypeIdentifiers

struct CSVExportItem: Transferable, Equatable {
    let fileURL: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { item in
            SentTransferredFile(item.fileURL)
        }
    }
}
