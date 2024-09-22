@EndUserText.label: 'Current Process Record of PGI'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_TSD020 
provider contract transactional_interface
as projection on ZR_TSD020
{
    key Deliverynumber,
    CurrentProcessUUID,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
}
