@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'join I_BillingDocumentItem and I_SerialNumberDeliveryD'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_BILLINGSERIALNUMBER 
  as select from I_BillingDocumentItem as _BillingDocumentItem
  inner join I_SerialNumberDeliveryDocument as _SerialNumberDD on _BillingDocumentItem.ReferenceSDDocument = _SerialNumberDD.DeliveryDocument
                                                               and _BillingDocumentItem.ReferenceSDDocumentItem = _SerialNumberDD.DeliveryDocumentItem
{
    key _SerialNumberDD.SerialNumber     as SerialNumber,
    key _SerialNumberDD.DeliveryDocument as DeliveryDocument,
    key _SerialNumberDD.DeliveryDocumentItem as DeliveryDocumentItem,
    _BillingDocumentItem.BillingDocument as BillingDocument,
    _BillingDocumentItem.BillingDocumentItem as BillingDocumentItem,
    _BillingDocumentItem.ReferenceSDDocument as ReferenceSDDocument,
    _BillingDocumentItem.ReferenceSDDocumentItem as ReferenceSDDocumentItem,
    _SerialNumberDD.Material             as Material
}
