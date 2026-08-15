import 'package:hive/hive.dart';

import '../../domain/entities/batch_entity.dart';
import '../../domain/repositories/batch_repository.dart';
import '../models/batch_model.dart';

class BatchRepositoryImpl implements BatchRepository {
  BatchRepositoryImpl({Box<BatchModel>? batchesBox})
    : _batchesBox = batchesBox ?? Hive.box<BatchModel>('batchesBox');

  final Box<BatchModel> _batchesBox;

  @override
  Future<List<BatchEntity>> getAllBatches() async {
    final batches = _batchesBox.values.map(BatchEntity.fromModel).toList();
    batches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return batches;
  }

  @override
  Future<List<BatchEntity>> getActiveBatches() async {
    final batches = _batchesBox.values
        .where((batch) => batch.isActive)
        .map(BatchEntity.fromModel)
        .toList();
    batches.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return batches;
  }

  @override
  Future<BatchEntity?> getBatchById(String id) async {
    final model = _batchesBox.get(id);
    return model == null ? null : BatchEntity.fromModel(model);
  }

  @override
  Future<void> addBatch(BatchEntity batch) async {
    await _batchesBox.put(batch.id, batch.toModel());
  }

  @override
  Future<void> updateBatch(BatchEntity batch) async {
    await _batchesBox.put(
      batch.id,
      batch.copyWith(updatedAt: DateTime.now()).toModel(),
    );
  }

  @override
  Future<void> deleteBatch(String id) async {
    await _batchesBox.delete(id);
    if (Hive.isBoxOpen('batchEnrollmentsBox')) {
      final box = Hive.box('batchEnrollmentsBox');
      final keys = box.keys
          .where((key) => box.get(key)?.batchId == id)
          .toList();
      await box.deleteAll(keys);
    }
    for (final boxName in ['attendanceBox', 'feeRecordsBox']) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final keys = box.keys
            .where((key) => box.get(key)?.batchId == id)
            .toList();
        await box.deleteAll(keys);
      }
    }
  }

  @override
  Future<void> archiveBatch(String id) async {
    final batch = await getBatchById(id);
    if (batch != null) await updateBatch(batch.copyWith(isActive: false));
  }

  @override
  Future<void> restoreBatch(String id) async {
    final batch = await getBatchById(id);
    if (batch != null) await updateBatch(batch.copyWith(isActive: true));
  }

  @override
  Future<int> getTotalBatchCount() async => _batchesBox.length;

  @override
  Future<int> getActiveBatchCount() async =>
      _batchesBox.values.where((batch) => batch.isActive).length;
}
