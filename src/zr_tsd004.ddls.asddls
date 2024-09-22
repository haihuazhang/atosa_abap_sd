@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD004'
@ObjectModel.sapObjectNodeType.name: 'ZZDeliveryDocument'
define root view entity ZR_TSD004
  as select from ztsd004c
{
  key delivery_number       as DeliveryNumber,
  key delivery_item         as DeliveryItem,
  key material              as Material,
  key serial_number         as SerialNumber,
      plant                 as Plant,
      storage_location      as StorageLocation,

      posting_date          as PostingDate,
      pgi_indicator         as PgiIndicator,
      zold_serial_number    as OldSerialNumber,
      
      current_process_uuid as CurrentProcessUUID,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
