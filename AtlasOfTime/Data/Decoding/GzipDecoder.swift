import Compression
import Foundation

enum GzipDecoder {
    private static let outputChunkSize = 64 * 1024

    static func gunzip(_ data: Data) throws -> Data {
        let container = try parseContainer(data)

        do {
            let inflated = try inflate(container.deflateStream)
            try validateInflatedSize(inflated, expectedISize: container.expectedISize)
            return inflated
        } catch {
            // Fallback if a producer stored a zlib-wrapped stream.
            let fallback = try inflate(data)
            try validateInflatedSize(fallback, expectedISize: container.expectedISize)
            return fallback
        }
    }

    private static func validateInflatedSize(_ inflated: Data, expectedISize: UInt32) throws {
        let actual = UInt32(truncatingIfNeeded: inflated.count)
        guard actual == expectedISize else {
            throw AtlasDataError.decompressionFailed(
                reason: "Trailer size mismatch (expected \(expectedISize), got \(actual))."
            )
        }
    }

    private static func inflate(_ compressed: Data) throws -> Data {
        let scratch = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer { scratch.deallocate() }

        var stream = compression_stream(
            dst_ptr: scratch,
            dst_size: 0,
            src_ptr: UnsafePointer(scratch),
            src_size: 0,
            state: nil
        )
        let initStatus = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
        guard initStatus != COMPRESSION_STATUS_ERROR else {
            throw AtlasDataError.decompressionFailed(reason: "compression_stream_init failed.")
        }
        defer { compression_stream_destroy(&stream) }

        let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputChunkSize)
        defer { outputBuffer.deallocate() }

        return try compressed.withUnsafeBytes { rawBuffer -> Data in
            guard let srcBase = rawBuffer.bindMemory(to: UInt8.self).baseAddress else {
                return Data()
            }

            var result = Data()
            stream.src_ptr = srcBase
            stream.src_size = rawBuffer.count

            var streamStatus: compression_status = COMPRESSION_STATUS_OK
            repeat {
                stream.dst_ptr = outputBuffer
                stream.dst_size = outputChunkSize

                streamStatus = compression_stream_process(&stream, Int32(COMPRESSION_STREAM_FINALIZE.rawValue))

                if streamStatus == COMPRESSION_STATUS_ERROR {
                    throw AtlasDataError.decompressionFailed(reason: "compression_stream_process failed.")
                }

                let produced = outputChunkSize - stream.dst_size
                if produced > 0 {
                    result.append(outputBuffer, count: produced)
                }
            } while streamStatus == COMPRESSION_STATUS_OK

            guard streamStatus == COMPRESSION_STATUS_END else {
                throw AtlasDataError.decompressionFailed(reason: "Unexpected stream status.")
            }

            return result
        }
    }

    private static func parseContainer(_ data: Data) throws -> (deflateStream: Data, expectedISize: UInt32) {
        let bytes = [UInt8](data)

        guard bytes.count >= 18 else {
            throw AtlasDataError.decompressionFailed(reason: "Gzip payload is too small.")
        }
        guard bytes[0] == 0x1f, bytes[1] == 0x8b else {
            throw AtlasDataError.decompressionFailed(reason: "Invalid gzip magic bytes.")
        }
        guard bytes[2] == 8 else {
            throw AtlasDataError.decompressionFailed(reason: "Unsupported compression method.")
        }

        let flags = bytes[3]
        var index = 10
        let trailerStart = bytes.count - 8

        if flags & 0x04 != 0 {
            guard index + 2 <= trailerStart else {
                throw AtlasDataError.decompressionFailed(reason: "Corrupt FEXTRA header.")
            }
            let xlen = Int(UInt16(bytes[index]) | (UInt16(bytes[index + 1]) << 8))
            index += 2
            guard index + xlen <= trailerStart else {
                throw AtlasDataError.decompressionFailed(reason: "Corrupt FEXTRA payload.")
            }
            index += xlen
        }

        if flags & 0x08 != 0 {
            while index < trailerStart, bytes[index] != 0 { index += 1 }
            guard index < trailerStart else {
                throw AtlasDataError.decompressionFailed(reason: "Corrupt FNAME field.")
            }
            index += 1
        }

        if flags & 0x10 != 0 {
            while index < trailerStart, bytes[index] != 0 { index += 1 }
            guard index < trailerStart else {
                throw AtlasDataError.decompressionFailed(reason: "Corrupt FCOMMENT field.")
            }
            index += 1
        }

        if flags & 0x02 != 0 {
            guard index + 2 <= trailerStart else {
                throw AtlasDataError.decompressionFailed(reason: "Corrupt FHCRC field.")
            }
            index += 2
        }

        guard index < trailerStart else {
            throw AtlasDataError.decompressionFailed(reason: "Gzip deflate payload is empty.")
        }

        let isize = UInt32(bytes[trailerStart + 4])
            | (UInt32(bytes[trailerStart + 5]) << 8)
            | (UInt32(bytes[trailerStart + 6]) << 16)
            | (UInt32(bytes[trailerStart + 7]) << 24)

        return (Data(bytes[index..<trailerStart]), isize)
    }
}
