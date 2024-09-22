@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD013'
@ObjectModel.semanticKey: [ 'DeliveryNumber', 'DeliveryItem', 'Plant', 'StorageLocation', 'Material', 'SerialNumber', 'ScannedDate', 'ScannedTime', 'ScannedUserID', 'ScannedUserName' ]
@Search.searchable: true
@UI: {
    headerInfo: {
        typeNamePlural: 'Results'
    }
}
define root view entity ZC_TSD013
  provider contract transactional_query
  as projection on ZR_TSD013
{
  key DeliveryNumber,
  key DeliveryItem,
  key Plant,
  key StorageLocation,
  key Material,
  key SerialNumber,
  @UI.hidden: true
  key ScannedDate,
  @UI.hidden: true
  key ScannedTime,
  key ScannedUserID,
  key ScannedUserName,
  @EndUserText.label: 'Scanned Date'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_020'
  virtual ScannedDate_TZ : abp_creation_date,
  @EndUserText.label: 'Scanned Time'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_020'
  virtual ScannedTime_TZ : abp_creation_time,
  @EndUserText.label: 'Picking Completed'
  PickingCompleted,
  SalesOrder,
  CreatedBy,
  CreatedAt,
  LocalLastChangedAt
  
}
