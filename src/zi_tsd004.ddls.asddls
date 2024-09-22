@EndUserText.label: 'Interface of PGI - Serial Number'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.sapObjectNodeType.name: 'ZZDeliveryDocument'
define root view entity ZI_TSD004 
provider contract transactional_interface
as projection on ZR_TSD004
{
    key DeliveryNumber,
    key DeliveryItem,
    key Material,
    key SerialNumber,
    Plant,
    StorageLocation,
    PostingDate,
    PgiIndicator,
    OldSerialNumber,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
