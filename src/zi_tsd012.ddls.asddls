@EndUserText.label: 'Interface of PGI - No Serial Number'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_TSD012 
provider contract transactional_interface
as projection on ZR_TSD012
{
    key DeliveryNumber,
    key DeliveryItem,
    Material,
    Plant,
    StorageLocation,
    PostingDate,
    PgiIndicator,
    ZoldSerialNumber,
    Scannedquantity,
    Unitofmeasure,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
