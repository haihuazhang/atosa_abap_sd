@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Scanned Qty for PGI - No SN'
define root view entity ZR_TSD012
  as select from ztsd012
{
  key delivery_number as DeliveryNumber,
  key delivery_item as DeliveryItem,
  material as Material,
  plant as Plant,
  storage_location as StorageLocation,
  posting_date as PostingDate,
  pgi_indicator as PgiIndicator,
  zold_serial_number as ZoldSerialNumber,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  scannedquantity as Scannedquantity,
  unitofmeasure as Unitofmeasure,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
