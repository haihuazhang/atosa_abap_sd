@EndUserText.label: 'Print CDS of Order Confirmation Output Item'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_SD_019'
define custom entity ZR_PSD029
{
  key SalesDocument : zzesd014;
  key SalesDocumentItem : zzesd017;
  Material : zzesd021;
  SalesDocumentItemText : abap.sstring( 255 );
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  UnitPrice : abap.curr( 15, 2 );
  TransactionCurrency : abap.cuky( 5 );
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  Dis : abap.curr( 15, 2 );
  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  OrderQuantity : abap.quan( 15, 3 );
  OrderQuantityUnit : abap.unit( 3 );
  MaterialByCustomer : matnr;
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  NetAmount : abap.curr( 15, 2 );
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  Subtotal1Amount : abap.curr( 15, 2 );
  MaterialNote : abap.sstring( 255 );
  @ObjectModel.filter.enabled: false
  @ObjectModel.sort.enabled: false
  _WarrantyInfo : association [1..1] to ZR_PSD008 on _WarrantyInfo.SalesDocument = $projection.SalesDocument
                                                 and _WarrantyInfo.SalesDocumentItem = $projection.SalesDocumentItem;
}
