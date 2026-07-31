import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sale_documents_table.dart';
import '../tables/sale_items_table.dart';

part 'sale_dao.g.dart';

@DriftAccessor(tables: [SaleDocuments, SaleItems])
class SaleDao extends DatabaseAccessor<AppDatabase> with _$SaleDaoMixin {
  SaleDao(super.db);

  Future<List<SaleDocumentData>> getAllSales() => select(saleDocuments).get();
  
  Stream<List<SaleDocumentData>> watchAllSales() => select(saleDocuments).watch();
  
  Future<int> insertSaleDocument(SaleDocumentsCompanion sale) => into(saleDocuments).insert(sale);
  
  Future<void> insertSaleItems(List<SaleItemsCompanion> items) async {
    await batch((batch) {
      batch.insertAll(saleItems, items);
    });
  }
}
