@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'New & Old Serial Number CDS for Picking'
@Metadata.ignorePropagatedAnnotations:true
define root view entity ZR_SSD025
    as select from I_SerialNumberDeliveryDocument as _SerialNumberDeliveryDocument
    association [0..1] to ZR_TMM001 on _SerialNumberDeliveryDocument.SerialNumber = ZR_TMM001.Zserialnumber
                                        and _SerialNumberDeliveryDocument.Material = ZR_TMM001.Product
{
    key _SerialNumberDeliveryDocument.DeliveryDocument,
    key _SerialNumberDeliveryDocument.DeliveryDocumentItem,
    key _SerialNumberDeliveryDocument.SerialNumber,
    key ZR_TMM001.Zoldserialnumber as OldSerialNumber
}
