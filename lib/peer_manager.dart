import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

import 'models/models.dart';
import 'peer.dart';
import 'signaling_client.dart';

class PeerManager extends StateNotifier<PeerManagerState> {
  static var localType = PeerType.unknown;
  final signalingClient = SignalingClient();
  final messages = BehaviorSubject<PeerMessage>();
  final peerMap = <String, Peer>{};

  PeerManager(super.state);

  Future<void> onRTCSetup(SignalingMessage msg) async {
    final description = Map<String, String>.from(msg.content);
    final rtcDescription = RTCSessionDescription(description['sdp'], description['type']);

    if (peerMap.containsKey(msg.senderIdentity)) {
      await peerMap[msg.senderIdentity]!.connection.setRemoteDescription(rtcDescription);
    } else {
      final peer = await Peer.create(
        localType,
        msg.senderIdentity,
        signalingClient,
        true,
      );
      peer.listenToOpen(onPeerDataChannelOpen);
      peer.listenAll((m) => messages.sink.add(m));
      peerMap[msg.senderIdentity] = peer;
    }
  }

  Stream<PeerMessage> getSpecificMessages(PeerMessageType type) {
    return messages.where((event) => event.type == type);
  }

  void onPeerDataChannelOpen(String peerId) {
    state = PeerManagerState.newPeerAvailable(
      availablePeers: [...state.availablePeers, peerId],
      localState: state.localState,
    );
  }

  Future<void> onPeerAvailable(SignalingMessage msg) async {
    final peerId = msg.content as String;
    debugPrint('Peer $peerId is available');

    if (peerMap.containsKey(peerId)) return;

    final peer = await Peer.create(
      localType,
      peerId,
      signalingClient,
      false,
    );
    peer.listenToOpen(onPeerDataChannelOpen);
    peer.listenAll((m) => messages.sink.add(m));
    peerMap[peerId] = peer;
  }

  void onPeerClosed(SignalingMessage msg) {
    final peerId = msg.content as String;
    debugPrint('Signaling says peer $peerId closed');
    final removedPeer = peerMap.remove(peerId);
    if (removedPeer != null) {
      removedPeer.dispose();
      debugPrint('Removed and disposed peer $peerId from peerMap');

      state = PeerManagerState.peerRemoved(
        availablePeers: [...state.availablePeers]..remove(peerId),
        localState: state.localState,
      );
    }
  }

  static Future<PeerManager> create(String? identity) async {
    if (localType == PeerType.unknown) {
      throw Exception('PeerManager.localType must be set!');
    }
    final peerManager = PeerManager(const PeerManagerState.initial());
    peerManager.signalingClient.listen(SignalingMessageType.rtcSetup, peerManager.onRTCSetup);
    peerManager.signalingClient.listen(SignalingMessageType.peerAvailable, peerManager.onPeerAvailable);
    peerManager.signalingClient.listen(SignalingMessageType.peerClosed, peerManager.onPeerClosed);
    await peerManager.signalingClient.init(identity);
    return peerManager;
  }

  void send(String id, PeerMessage message) {
    peerMap[id]!.send(
      message.copyWith(
        receiverIdentity: id,
        tag: message.tag ?? const Uuid().v4(),
      ),
    );
  }

  Future<PeerMessage> submit(
    String id,
    PeerMessage message,
  ) async {
    return await peerMap[id]!.submit(message);
  }

  Future<List<Future<PeerMessage>>> broadcastSubmit(
    PeerMessage message, {
    Set<PeerType> types = const {PeerType.full},
    Set<PeerState> states = const {PeerState.open},
  }) async {
    final futures = <Future<PeerMessage>>[];
    for (final peer in peerMap.values) {
      final type = await peer.type;
      final state = await peer.state;
      if (types.contains(type) && states.contains(state)) {
        futures.add(
          peer.submit(
            message.copyWith(
              tag: const Uuid().v4(),
              receiverIdentity: peer.remoteIdentity,
            ),
          ),
        );
      }
    }
    return futures;
  }

  void broadcast(
    PeerMessage message, {
    Set<PeerType> types = const {PeerType.full},
    Set<PeerState> states = const {PeerState.open},
  }) async {
    for (final peer in peerMap.values) {
      final type = await peer.type;
      final state = await peer.state;
      if (types.contains(type) && states.contains(state)) {
        peer.send(
          message.copyWith(
            tag: const Uuid().v4(),
            receiverIdentity: peer.remoteIdentity,
          ),
        );
      }
    }
  }

  Future<PeerType> typeOfPeer(String peerId) async {
    final type = await peerMap[peerId]?.type ?? PeerType.unknown;
    return type;
  }

  Future<PeerState> stateOfPeer(String peerId) async {
    return await peerMap[peerId]?.state ?? PeerState.unknown;
  }

  Future<PeerMessage> waitForMessageOfType(PeerMessageType type) async {
    return messages.firstWhere((e) => e.type == type);
  }

  Future<List<String>> waitForPeersOfType(PeerType type, {int count = 1}) async {
    final peerIds = <String>[];
    for (final entry in peerMap.entries) {
      final entryType = await entry.value.type;
      if (entryType == type) {
        peerIds.add(entry.key);
      }
    }
    if (peerIds.length == count) {
      return peerIds;
    }
    final completer = Completer();

    final removeListener = addListener(
      (state) async {
        await state.mapOrNull(
          newPeerAvailable: (val) async {
            if (completer.isCompleted) return;
            final typeOfNewPeer = await typeOfPeer(val.availablePeers.last);
            if (typeOfNewPeer == type) {
              peerIds.add(val.availablePeers.last);
            }
            if (peerIds.length == count) {
              if (!completer.isCompleted) {
                completer.complete();
              }
            }
          },
        );
      },
    );

    await completer.future;
    removeListener();
    return peerIds;
  }

  void _closeConnections() async {
    final futures = <Future<void>>[];
    for (final peer in peerMap.values) {
      futures.add(peer.dispose());
    }
    await Future.wait(futures);
    await signalingClient.dispose();
  }

  @override
  void dispose() async {
    _closeConnections();
    await messages.close();
    super.dispose();
  }
}

final identityProvider = Provider.autoDispose<String>(
  (_) => throw UnimplementedError('Override identityProvider with an identity'),
);

final peerManagerProvider = FutureProvider.autoDispose<PeerManager>(
  (ref) async {
    final manager = await PeerManager.create(ref.watch(identityProvider));
    ref.onDispose(manager.dispose);
    return manager;
  },
  dependencies: [identityProvider],
);

final peerMessageProvider = StreamProvider.autoDispose.family<PeerMessage, PeerMessageType>(
  (ref, messageType) async* {
    final manager = await ref.watch(peerManagerProvider.future);

    await for (final message in manager.getSpecificMessages(messageType)) {
      yield message;
    }
  },
  dependencies: [peerManagerProvider],
);

final peerListProvider = StreamProvider.autoDispose.family<List<String>, PeerType>(
  (ref, type) async* {
    final manager = await ref.watch(peerManagerProvider.future);
    await for (final state in manager.stream) {
      final filteredPeerIds = <String>[];
      for (final peerId in state.availablePeers) {
        final peerType = await manager.typeOfPeer(peerId);
        if (peerType == type) {
          filteredPeerIds.add(peerId);
        }
      }
      yield filteredPeerIds;
    }
  },
  dependencies: [peerManagerProvider],
);
