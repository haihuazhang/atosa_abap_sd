@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Warranty Report - Active Status Entry 3'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY8
  as select from ZR_WARRANTY7 as _WARRANTY7


    join         ZR_WARRANTY6 as _Max on  _WARRANTY7.SerialNumber = _Max.SerialNumber
                                      and _WARRANTY7.ZDateTimeL   = _Max.MaxDateTime                                   
    inner join   I_DeliveryDocumentItem as _DeliveryDocumentItem on _WARRANTY7.DeliveryDocument = _DeliveryDocumentItem.DeliveryDocument
                                                                 and _WARRANTY7.DeliveryDocumentItem = _DeliveryDocumentItem.DeliveryDocumentItem
    inner join   I_BillingDocumentItem as _BillDocumentItem on _DeliveryDocumentItem.DeliveryDocument = _BillDocumentItem.ReferenceSDDocument
                                                            and _DeliveryDocumentItem.DeliveryDocumentItem = _BillDocumentItem.ReferenceSDDocumentItem
    inner join   ZR_WARRANTY11 as _WARRANTY11 on _DeliveryDocumentItem.ReferenceSDDocument = _WARRANTY11.SalesDocument
                                              and _BillDocumentItem.BillingDocument = _WARRANTY11.MaxBillingNumber
{
  key _WARRANTY7.DeliveryDocument,
  key _WARRANTY7.DeliveryDocumentItem,
  key _BillDocumentItem.BillingDocument,
  key _WARRANTY7.SerialNumber,
      //      max(
      //      concat(_SalesDocument.CreationDate,_SalesDocument.CreationTime) as ZDateTimeL
      cast('X' as abap.char(1) ) as ZActive
      //      max( _SalesDocument.CreationDate ) as CreationDate

}


union

select from I_DeliveryDocumentItem         as _DeliveryDocumentItem
//    join I_SalesDocumentItem as _SalesDocumentItem on $projection.SalesDocument = _SalesDocumentItem.SalesDocument
  join      ZR_WARRANTY9                   as _SerialNuberDN on  _DeliveryDocumentItem.DeliveryDocument     = _SerialNuberDN.DeliveryDocument
                                                             and _DeliveryDocumentItem.DeliveryDocumentItem = _SerialNuberDN.DeliveryDocumentItem
  inner join I_SalesDocument               as _SalesDocument on _DeliveryDocumentItem.ReferenceSDDocument = _SalesDocument.SalesDocument
  inner join I_SalesDocumentItem           as _SalesDocumentItem on _SalesDocumentItem.SalesDocument = _SalesDocument.SalesDocument                                                           
  inner join   I_BillingDocumentItem as _BillDocumentItem on _DeliveryDocumentItem.DeliveryDocument = _BillDocumentItem.ReferenceSDDocument
                                                            and _DeliveryDocumentItem.DeliveryDocumentItem = _BillDocumentItem.ReferenceSDDocumentItem
  join      ZR_WARRANTY5                   as _Count         on _SerialNuberDN.SerialNumber = _Count.SerialNumber
{

  key _DeliveryDocumentItem.DeliveryDocument,
  key _DeliveryDocumentItem.DeliveryDocumentItem,
  key _BillDocumentItem.BillingDocument,
  key _SerialNuberDN.SerialNumber,
  
      cast('X' as abap.char(1) ) as ZActive
}

where
 _SalesDocumentItem.SalesDocumentRjcnReason is initial 
 and
  _Count.OrderTypeCount = 1

