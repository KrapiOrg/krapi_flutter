import 'package:freezed_annotation/freezed_annotation.dart';

import '../block/block.dart';
import '../block_header/block_header.dart';
import '../block_header/block_headers_response_content.dart';
import '../peer_models/peer_state.dart';
import '../peer_models/peer_type.dart';
import '../set_transaction_status_content/set_transaction_status_content.dart';
import '../transaction/transaction.dart';
part 'peer_message.freezed.dart';
part 'peer_message.g.dart';

@JsonEnum(
  alwaysCreate: true,
  fieldRename: FieldRename.snake,
)
enum PeerMessageType {
  peerTypeRequest,
  peerTypeResponse,
  addTransaction,
  removeTransactions,
  setTransactionStatus,
  syncBlockchain,
  requestBlocks,
  blocksResponse,
  blockHeadersRequest,
  blockHeadersResponse,
  blockRequest,
  blockResponse,
  blockNotFoundResponse,
  peerStateRequest,
  peerStateResponse,
  peerStateUpdate,
  addBlock,
  blockRejected,
  blockAccepted,
  getLastBlockRequest,
  getLastBlockResponse,
  transactionsInRequest,
  transactionsInResponse,
  transactionsOutRequest,
  transactionsOutResponse,
  controlIsStartingPing,
  controlIsEndingPing,
  controlStarted,
  controlStopped,
  controlOperateBetween,
  controlResult,
  isControlStartedRequest,
  isControlStartedResponse,
}

abstract class KrapiMessageInterface {
  PeerMessageType get type;
  String get senderIdentity;
  String? get receiverIdentity;
  String? get tag;
}

@Freezed(
  unionValueCase: FreezedUnionCase.snake,
  toJson: true,
  fromJson: true,
  addImplicitFinal: true,
  unionKey: 'type',
)
class PeerMessage with _$PeerMessage {
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.peerTypeRequest({
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.peerTypeRequest) PeerMessageType type,
    dynamic content,
    required int timestamp,
  }) = _PeerMessagePeerTypeRequest;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.peerTypeResponse({
    required PeerType content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.peerTypeResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessagePeerTypeResponse;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.addTransaction({
    required Transaction content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.addTransaction) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageAddTransaction;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.blockHeadersRequest({
    required BlockHeader content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.blockHeadersRequest) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageBlockHeadersRequest;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.blockHeadersResponse({
    required BlockHeadersResponseContent content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.blockHeadersResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageBlockHeadersResponse;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.blockRequest({
    required BlockHeader content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.blockRequest) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageBlockRequest;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.blockResponse({
    required Block content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.blockResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageBlockResponse;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.blockNotFoundResponse({
    required BlockHeader content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.blockNotFoundResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageBlockNotFoundResponse;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.peerStateRequest({
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.peerStateRequest) PeerMessageType type,
    dynamic content,
    required int timestamp,
  }) = _PeerMessagePeerStateRequest;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.peerStateResponse({
    required PeerState content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.peerStateResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessagePeerStateResponse;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.peerStateUpdate({
    required PeerState content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.peerStateUpdate) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessagePeerStateUpdate;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.addBlock({
    required Block content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.addBlock) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageAddBlock;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.blockRejected(
    BlockHeader header, {
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.blockRejected) PeerMessageType type,
    dynamic content,
    required int timestamp,
  }) = _PeerMessageBlockRejected;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.blockAccepted({
    required BlockHeader content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.blockAccepted) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageBlockAccepted;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.getLastBlockRequest({
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.getLastBlockRequest) PeerMessageType type,
    dynamic content,
    required int timestamp,
  }) = _PeerMessageGetLastBlockRequest;
  @Implements<KrapiMessageInterface>()
  const factory PeerMessage.getLastBlockResponse({
    required Block content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.getLastBlockResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageGetLastBlockResponse;
  const factory PeerMessage.setTransactionStatus({
    required SetTransactionStatusContent content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.setTransactionStatus) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageSetTransactionStatus;
  const factory PeerMessage.transactionsInRequest({
    required String content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.transactionsInRequest) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageTransactionsInRequest;
  const factory PeerMessage.transactionsInResponse({
    required int content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.transactionsInResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageTransactionsInResponse;
  const factory PeerMessage.transactionsOutRequest({
    required String content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.transactionsOutRequest) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageTransactionsOutRequest;
  const factory PeerMessage.transactionsOutResponse({
    required int content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.transactionsOutResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageTransactionsOutResponse;
  const factory PeerMessage.controlIsStartingPing({
    required String content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.controlIsStartingPing) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageControlIsStartingPing;
  const factory PeerMessage.controlIsEndingPing({
    required String content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.controlIsEndingPing) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageControlIsEndingPing;
  const factory PeerMessage.controlStarted({
    dynamic content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.controlStarted) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageControlStarted;
  const factory PeerMessage.controlStopped({
    dynamic content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.controlStopped) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageControlStopped;
  const factory PeerMessage.controlOperateBetween({
    required Map<String, int> content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.controlStopped) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageOperateBetween;
  const factory PeerMessage.controlResult({
    required Map<String, int> content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.controlResult) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageControlResult;

  const factory PeerMessage.isControlStartedRequest({
    dynamic content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.isControlStartedRequest) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageIsControlStartedRequest;
  const factory PeerMessage.isControlStartedResponse({
    required bool content,
    required String senderIdentity,
    String? receiverIdentity,
    String? tag,
    @Default(PeerMessageType.isControlStartedResponse) PeerMessageType type,
    required int timestamp,
  }) = _PeerMessageIsControlStartedResponse;

  factory PeerMessage.fromJson(Map<String, dynamic> json) => _$PeerMessageFromJson(json);
}
