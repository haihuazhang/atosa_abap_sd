@EndUserText.label: 'Print CDS of Order Confirmation Output'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_SD_019'
define custom entity ZR_PSD025
{
  key SalesDocument : zzesd014;
  SalesDocumentType : abap.char( 4 );
  PurchaseOrderByCustomer : abap.char( 35 );
  CreationDate : abap.dats;
  RequestedDeliveryDate : abap.dats;
  BillToCustomerID : abap.sstring( 255 );
  ShipToID    : abap.sstring( 255 );
  BillToLine1 : abap.sstring( 255 );
  BillToLine2 : abap.sstring( 255 );
  BillToLine3 : abap.sstring( 255 );
  PaymentTermsName : abap.char( 30 );
  ShipToLine1 : abap.sstring( 255 );
  ShipToLine2 : abap.sstring( 255 );
  ShipToLine3 : abap.sstring( 255 );
  YY1_ContactName_SDH : abap.sstring( 255 );
  YY1_ContactPhone_SDH : abap.sstring( 255 );
  ShippingTypeName : abap.char( 20 );
  YY1_TrackingNumber_SDH : abap.sstring( 255 );
  ShipFrom : abap.sstring( 255 );
  SalesRep : abap.sstring( 255 );
  CustomerNote : abap.sstring( 255 );
  YY1_WhiteGlovesShipto_SDH : abap.sstring( 255 );
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  TotalNetAmount : abap.curr( 15, 2 );
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  SumTaxAmount : abap.curr( 15, 2 );
  TransactionCurrency : abap.cuky( 5 );
  @ObjectModel.filter.enabled: false
  _Item : association [0..*] to ZR_PSD029 on _Item.SalesDocument = $projection.SalesDocument;
}
