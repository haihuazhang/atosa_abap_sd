@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED PGI Changed Quantity Record'
define root view entity ZR_TSD019
  as select from ztsd019
{
  key process_uuid as ProcessUUID,
  deliverynumber as Deliverynumber,
  delivery_item as DeliveryItem,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
  cast( original_quantity as zzesd076 ) as OriginalQuantity,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
  latest_quantity as LatestQuantity,
  unit_of_measure as UnitOfMeasure,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
