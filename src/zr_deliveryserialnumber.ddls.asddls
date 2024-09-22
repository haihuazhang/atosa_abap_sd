@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'join I_DeliveryDocumentItem and I_SerialNumberDeliveryD'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_DELIVERYSERIALNUMBER 
  as select from I_DeliveryDocumentItem as _DeliveryDocumentItemH
  left outer join I_SerialNumberDeliveryDocument as _SerialNumberDDH on _DeliveryDocumentItemH.DeliveryDocument = _SerialNumberDDH.DeliveryDocument
                                                                and _DeliveryDocumentItemH.DeliveryDocumentItem = _SerialNumberDDH.DeliveryDocumentItem
{
    key _SerialNumberDDH.SerialNumber     as SerialNumber,
    key _SerialNumberDDH.DeliveryDocument as DeliveryDocument,
    key _SerialNumberDDH.DeliveryDocumentItem as DeliveryDocumentItem,
//    _DeliveryDocumentItemH.DeliveryDocument as DeliveryDocument,
//    _DeliveryDocumentItemH.DeliveryDocumentItem as DeliveryDocumentItem,
    _DeliveryDocumentItemH.ReferenceSDDocument as ReferenceSDDocument,
    _DeliveryDocumentItemH.ReferenceSDDocumentItem as ReferenceSDDocumentItem,
    _DeliveryDocumentItemH.YY1_WarrantyMaterial_DLI,
    _DeliveryDocumentItemH.YY1_WarrantySerial_DLI,
    _SerialNumberDDH.Material             as Material
}
