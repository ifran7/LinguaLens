import '../entities/batch_entity.dart';

abstract class BatchRepository {
  Future<List<BatchEntity>> getAllBatches();
  Future<List<BatchEntity>> getActiveBatches();
  Future<BatchEntity?> getBatchById(String id);
  Future<void> addBatch(BatchEntity batch);
  Future<void> updateBatch(BatchEntity batch);
  Future<void> deleteBatch(String id);
  Future<void> archiveBatch(String id);
  Future<void> restoreBatch(String id);
  Future<int> getTotalBatchCount();
  Future<int> getActiveBatchCount();
}
