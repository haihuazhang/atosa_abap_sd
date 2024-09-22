@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BillingDocument and Serial Number'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD028
  as select from    I_SerialNumberDeliveryDocument as _SerialNumberDeliveryDocument
    left outer join I_DeliveryDocumentItem         as _DeliveryDocumentItem on  _DeliveryDocumentItem.DeliveryDocument     = _SerialNumberDeliveryDocument.DeliveryDocument
                                                                            and _DeliveryDocumentItem.DeliveryDocumentItem = _SerialNumberDeliveryDocument.DeliveryDocumentItem
    left outer join I_BillingDocumentItem          as _BillingDocumentItem  on  _BillingDocumentItem.SalesDocument     = _DeliveryDocumentItem.ReferenceSDDocument
                                                                            and _BillingDocumentItem.SalesDocumentItem = _DeliveryDocumentItem.ReferenceSDDocumentItem
{
  key _SerialNumberDeliveryDocument.SerialNumber,
      _BillingDocumentItem.BillingDocument,
      _BillingDocumentItem.BillingDocumentItem
}
