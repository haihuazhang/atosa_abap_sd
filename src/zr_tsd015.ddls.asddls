@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD015'
define root view entity ZR_TSD015
  as select from ztsd015
{
  key delivery_number as DeliveryNumber,
  key delivery_item as DeliveryItem,
  material as Material,
  plant as Plant,
  storage_location as StorageLocation,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  scannedquantity as Scannedquantity,
  unitofmeasure as Unitofmeasure,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
