@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD013'
define root view entity ZR_TSD013
  as select from ztsd013
{
  key delivery_number as DeliveryNumber,
  key delivery_item as DeliveryItem,
  key plant as Plant,
  key storage_location as StorageLocation,
  key material as Material,
  key serial_number as SerialNumber,
  @Semantics.systemDateTime.createdAt: true
  key scanned_date as ScannedDate,
  key scanned_time as ScannedTime,
  @Semantics.user.createdBy: true
  key scanned_user_id as ScannedUserID,
  key scanned_user_name as ScannedUserName,
  picking_completed as PickingCompleted,
  sales_order as SalesOrder,
  created_by as CreatedBy,
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
