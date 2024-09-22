@EndUserText.label: 'PGI Changed Quantity Record'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_TSD019 
provider contract transactional_interface
as projection on ZR_TSD019
{
    key ProcessUUID,
    Deliverynumber,
    DeliveryItem,
    OriginalQuantity,
    LatestQuantity,
    UnitOfMeasure,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
