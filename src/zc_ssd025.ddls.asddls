@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'New & Old Serial Number CDS for Picking'
define root view entity ZC_SSD025 as projection on ZR_SSD025
{
    key DeliveryDocument,
    key DeliveryDocumentItem,
    key SerialNumber,
    key OldSerialNumber
}
