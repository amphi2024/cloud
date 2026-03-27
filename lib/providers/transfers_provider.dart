import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transfer_state.dart';

class TransfersNotifier extends Notifier<Map<String, TransferState>> {

  @override
  Map<String, TransferState> build() {
    return {};
  }

  void insertItem(TransferState transfer) {
    state = {...state, transfer.fileId: transfer};
  }

  void removeItem(String id) {
    final transfers = {...state};
    transfers.remove(id);
    state = transfers;
  }

}

final transfersProvider = NotifierProvider<TransfersNotifier, Map<String, TransferState>>(TransfersNotifier.new);