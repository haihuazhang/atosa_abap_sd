@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Invoice Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PSD024
  as select from    I_BillingDocumentItem as _BIllingDocumentItem
    left outer join I_SalesDocument       as _SalesDocument on _SalesDocument.SalesDocument = _BIllingDocumentItem.SalesDocument

{
  key _BIllingDocumentItem.BillingDocument,
      max( _BIllingDocumentItem.SalesDocument )     as SalesDocument,
      max( _BIllingDocumentItem.Plant )             as Plant,
      max( _SalesDocument.PurchaseOrderByCustomer ) as PurchaseOrderByCustomer,
      max( _SalesDocument.ShippingType )            as ShippingType
}

group by
  _BIllingDocumentItem.BillingDocument
