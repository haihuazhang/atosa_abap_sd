@EndUserText.label: 'Packing Slip PrintOut - Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PSD015 as projection on ZR_PSD015
{
    key DeliveryDocument,
    key DeliveryDocumentItem,
    Material,
    ActualDeliveryQuantity,
    DeliveryQuantityUnit,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_009'
    virtual Description : abap.sstring( 255 ),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_008'
    virtual MaterialNote: abap.sstring( 255 ),
    /* Associations */
    _SerialNumber: redirected to ZC_PSD016
}
