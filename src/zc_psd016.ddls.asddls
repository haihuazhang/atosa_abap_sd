@EndUserText.label: 'Packing Slip PrintOut - Serial Number'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PSD016 as projection on ZR_PSD016
{
    key Equipment,
    key DeliveryDocument,
    key DeliveryDocumentItem,
    Material,
    SerialNumber
}
