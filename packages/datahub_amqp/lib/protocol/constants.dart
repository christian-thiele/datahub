const frameMethod = 1;
const frameHeader = 2;
const frameBody = 3;
// documentation says 8 here: https://www.rabbitmq.com/resources/specs/amqp-xml-doc0-9-1.pdf
// but 4 here: https://www.rabbitmq.com/resources/specs/amqp0-9-1.pdf
const frameHeartbeat = 4;
const frameMinSize = 4096;
const frameEnd = 0xCE;

/// Indicates that the method completed successfully. This reply code is
/// reserved for future use - the current protocol design does not use
/// positive confirmation and reply codes are sent only in case of an error.
const replySuccess = 200;

/// The client attempted to transfer content larger than the server could
/// accept at the present time. The client may retry at a later time.
const contentTooLarge = 311;

/// When the exchange cannot deliver to a consumer when the immediate flag
/// is set. As a result of pending data on the queue or the absence of any
/// consumers of the queue.
const noConsumers = 313;

/// An operator intervened to close the connection for some reason. The client
/// may retry at some later date.
const connectionForced = 320;

/// The client tried to work with an unknown virtual host.
const invalidPath = 402;

/// The client attempted to work with a server entity to which it has no
/// access due to security settings.
const accessRefused = 403;

/// The client attempted to work with a server entity that does not exist.
const notFound = 404;

/// The client attempted to work with a server entity to which it has no
/// access.
const resourceLocked = 405;

/// The client requested a method that was not allowed because some
/// precondition failed.
const preconditionFailed = 406;

/// The sender sent a malformed frame that the recipient could not decode.
/// This strongly implies a programming error in the sending peer.
const frameError = 501;

/// The sender sent a frame that contained illegal values for one or more fields.
/// This strongly implies a programming error in the sending peer.
const syntaxError = 502;

/// The client sent an invalid sequence of frames, attempting to perform an
/// operation that was considered invalid by the server. This usually implies a
/// programming error in the client.
const commandInvalid = 503;

/// The client attempted to work with a channel that had not been correctly
/// opened. This most likely indicates a fault in the client layer.
const channelError = 504;

/// The peer sent a frame that was not expected, usually in the context of a
/// content header and body. This strongly indicates a fault in the peer's
/// content processing.
const unexpectedFrame = 505;

/// The server could not complete the method because it lacked sufficient
/// resources. This may be due to the client creating too many of some type of
/// entity.
const resourceError = 506;

/// The client tried to work with some entity in a manner that is prohibited by
/// the server, due to security settings or by some other criteria.
const notAllowed = 530;

/// The client tried to use functionality that is not implemented in the server.
const notImplemented = 540;

/// The server could not complete the method because of an internal error. The
/// server may require intervention by an operator in order to resume normal
/// operations.
const internalError = 541;

const classConnection = 10;
const classChannel = 20;
const classExchange = 40;
const classQueue = 50;
const classBasic = 60;
const classTx = 90;


const methodConnectionStart = 10;
const methodConnectionStartOk = 11;
const methodConnectionSecure = 20;
const methodConnectionSecureOk = 21;
const methodConnectionTune = 30;
const methodConnectionTuneOk = 31;
const methodConnectionOpen = 40;
const methodConnectionOpenOk = 41;
const methodConnectionClose = 50;
const methodConnectionCloseOk = 51;

const methodChannelOpen = 10;
const methodChannelOpenOk = 11;
const methodChannelFlow = 20;
const methodChannelFlowOk = 21;
const methodChannelClose = 40;
const methodChannelCloseOk = 41;