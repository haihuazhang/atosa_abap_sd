@EndUserText.label: 'Info for ItemQTYChangedBeforePGI Event'
define abstract entity ZR_SSD050
  //  with parameters parameter_name : parameter_type
{
  DeliveryDocument     : vbeln_vl;
  DeliveryDocumentItem : zzesd017;
  @Semantics.quantity.unitOfMeasure: 'UnitofMeasure'
  OriginalQTY          : abap.quan(13, 3);
  @Semantics.quantity.unitOfMeasure: 'UnitofMeasure'
  LatestQTY            : abap.quan(13, 3);
  @Semantics.unitOfMeasure: true
  UnitofMeasure        : abap.unit(3);

}
