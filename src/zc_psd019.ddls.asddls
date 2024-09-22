@EndUserText.label: 'Print CDS of Shipping Label'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PSD019 
    as projection on ZR_PSD019
{
    key OutboundDelivery,
    SalesDocument,
    PurchaseOrderByCustomer,
    ShippingTypeName,
    YY1_BusinessName_SDH,
    StreetName,
    CityRegionPostalCode,
    Country,
    YY1_WhiteGlovesShipto_SDH,
    SoldToParty,
    SalesOrganization,
    Plant
}
