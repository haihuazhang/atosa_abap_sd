@EndUserText.label: 'Packing Slip PrintOut - Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PSD013 
provider contract transactional_query
as projection on ZR_PSD013
{
    key DeliveryDocument,
    CreationDate,
    OverallPickingStatus,
    OverallPickingStatusDesc,
    ShippingType,
    ShippingTypeName,
    SalesDocument,
    PurchaseOrderByCustomer,
    SoldToParty,
    BillToAddrLine1,
    BillToAddrLine2,
    BillToAddrLine3,
    BillToAddrLine4,
    BillToAddrLine5,
    ShipToParty,
    ShipToAddrLine1,
    ShipToAddrLine2,
    ShipToAddrLine3,
    ShipToAddrLine4,
    ShipToAddrLine5,
    Plant,
    ShipForm,
    AtosaWillCall,
    SalesOrganization,
    /* Associations */
    _Item : redirected to ZC_PSD015
}
