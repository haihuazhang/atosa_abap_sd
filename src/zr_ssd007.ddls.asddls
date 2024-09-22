@EndUserText.label: 'Parameter of Create Scanned Record1'
define abstract entity ZR_SSD007

{
  OutboundDelivery     : zzesd016;
  OutboundDeliveryItem : zzesd017;
  Product              : matnr;
  SerialNumber         : abap.char( 40 );
//  @Semantics.quantity.unitOfMeasure: 'UnitofMeasure'
//  ScannedQuantity      : abap.quan(13, 3);
//  @Semantics.unitOfMeasure: true
//  UnitofMeasure        : abap.unit(3);
}
