import Foundation

// MARK: - OtaRequest (发送给服务器的数据)
// 'Codable' 是 'Encodable' 和 'Decodable' 的组合，意味着这个结构体可以被编码成 JSON 也可以从 JSON 解码。
struct OtaRequest: Codable {
    let version: Int
    let language: String
    let flashSize: Int
    let minimumFreeHeapSize: Int
    let macAddress: String
    let chipModelName: String
    let uuid: String
    let application: ApplicationInfo
    let partitionTable: [PartitionInfo]
    let ota: OtaInfo
    let board: BoardInfo
    
    // CodingKeys 用来映射 Swift 的驼峰命名 (camelCase) 和 JSON 的下划线命名 (snake_case)
    enum CodingKeys: String, CodingKey {
        case version, language, uuid, application, ota, board
        case flashSize = "flash_size"
        case minimumFreeHeapSize = "minimum_free_heap_size"
        case macAddress = "mac_address"
        case chipModelName = "chip_model_name"
        case partitionTable = "partition_table"
    }
}

struct ApplicationInfo: Codable {
    let name: String
    let version: String
    let compileTime: String
    let idfVersion: String
    let elfSha256: String
    
    enum CodingKeys: String, CodingKey {
        case name, version
        case compileTime = "compile_time"
        case idfVersion = "idf_version"
        case elfSha256 = "elf_sha256"
    }
}

struct PartitionInfo: Codable {
    // 根据你的 Android 代码，这是一个空列表，所以我们先定义一个空的结构体
}

struct OtaInfo: Codable {
    let partition: String
}

struct BoardInfo: Codable {
    let type: String
    let name: String
    let ssid: String
    let rssi: Int
    let channel: Int
    let ip: String
    let mac: String
}

// MARK: - OtaResponse (从服务器接收的数据)
struct OtaResponse: Codable {
    let websocket: WebsocketInfo
    let activation: ActivationInfo? // '?' 表示这个字段可能是 nil
}

struct WebsocketInfo: Codable {
    let url: String
    let token: String
}

struct ActivationInfo: Codable {
    let code: String
    let message: String
}
