@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Warranty Report - Count Order type for Active Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY5 as select from I_DeliveryDocumentItem as _DeliveryDocumentItem
//    join I_SalesDocumentItem as _SalesDocumentItem on $projection.SalesDocument = _SalesDocumentItem.SalesDocument
    join ZR_WARRANTY9 as _SerialNuberDN on _DeliveryDocumentItem.DeliveryDocument = _SerialNuberDN.DeliveryDocument
                                                          and _DeliveryDocumentItem.DeliveryDocumentItem = _SerialNuberDN.DeliveryDocumentItem
    inner join I_SalesDocument      as _SalesDocument on _DeliveryDocumentItem.ReferenceSDDocument = _SalesDocument.SalesDocument
//    inner join ZR_WARRANTY11          as _zwarranty11   on _SalesDocument.SalesDocument = _zwarranty11.SalesDocument
                                                          
{
    key _SerialNuberDN.SerialNumber,
    count( distinct  _SalesDocument.SalesDocumentType ) as OrderTypeCount
}
 group by  _SerialNuberDN.SerialNumber
