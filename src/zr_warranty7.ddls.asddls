@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Warranty Report - Active Status Entry 2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY7
  as select from I_DeliveryDocumentItem         as _DeliveryDocumentItem
  //    join I_SalesDocumentItem as _SalesDocumentItem on $projection.SalesDocument = _SalesDocumentItem.SalesDocument
    join         ZR_WARRANTY9                 as _SerialNuberDN on  _DeliveryDocumentItem.DeliveryDocument     = _SerialNuberDN.DeliveryDocument
                                                                  and _DeliveryDocumentItem.DeliveryDocumentItem = _SerialNuberDN.DeliveryDocumentItem
    inner join I_SalesDocument                as _SalesDocument on _DeliveryDocumentItem.ReferenceSDDocument = _SalesDocument.SalesDocument
    inner join I_SalesDocumentItem            as _SalesDocumentItem on _SalesDocumentItem.SalesDocument = _SalesDocument.SalesDocument                                                       
       
    join         ZR_WARRANTY5                   as _Count         on _SerialNuberDN.SerialNumber = _Count.SerialNumber
  //    join         ZR_WARRANTY6                   as _Max on _SerialNuberDN.SerialNumber = _Max.SerialNumber
  //                                                        and concat( _SalesDocument.CreationDate,_SalesDocument.CreationTime ) = _Max.MaxDateTime
{
  key _DeliveryDocumentItem.DeliveryDocument,
  key _DeliveryDocumentItem.DeliveryDocumentItem,
  key _SerialNuberDN.SerialNumber,
      //      max(
      concat(_SalesDocument.CreationDate,_SalesDocument.CreationTime) as ZDateTimeL
      //      cast('X' as abap_boolean ) as ZActive
      //      max( _SalesDocument.CreationDate ) as CreationDate

}
where
 _SalesDocumentItem.SalesDocumentRjcnReason is initial and
  _Count.OrderTypeCount > 1
//  and 
