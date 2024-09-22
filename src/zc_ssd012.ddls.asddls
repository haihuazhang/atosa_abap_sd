@EndUserText.label: 'Outbound Delivery CDS for Picking'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_SSD012
  as projection on ZR_SSD012
{
    key OutboundDelivery,
    ShippingType,
    ShippingTypeName,
    /* Associations */
//    ZR_SSD012._ShippingType,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_002'
    virtual LongText : abap.sstring( 255 ),
    ZR_SSD012.SalesOrder,
    ZR_SSD012.Plant,
    ZR_SSD012.OverallPickingStatus,
    ZR_SSD012.TotalCreditCheckStatus,
    ZR_SSD012.SoldToPartyName,
    ZR_SSD012.DNCreatedBy,
    ZR_SSD012.CreatedByUser,
    ZR_SSD012.CreationDate,
    ZR_SSD012.CreationTime,
    ZR_SSD012.LastChangedByUser,
    ZR_SSD012.LastChangeDate
}
