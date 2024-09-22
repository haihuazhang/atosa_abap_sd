@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Warranty Report- Active of Billing Number'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY11 
  as select from I_BillingDocumentItem       as _BillingDocumentItem
  inner join I_SalesDocument             as _SalesDocument on _BillingDocumentItem.SalesDocument = _SalesDocument.SalesDocument
//  join       ZR_WARRANTY10               as _BCount        on _SalesDocument.SalesDocument = _BCount.SalesDocument
{
  key _SalesDocument.SalesDocument,
    max( _BillingDocumentItem.BillingDocument ) as MaxBillingNumber
}
where
  _BillingDocumentItem.BillingDocumentType = 'F2'
//where 
//  _BCount.BillingNumberCount > 1
group by _SalesDocument.SalesDocument
