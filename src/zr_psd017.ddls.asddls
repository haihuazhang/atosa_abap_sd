@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'select text from I_PRODUCTTEXT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PSD017 
as select from I_ProductText as _ProductText
{
   key  _ProductText.Product,
   key  _ProductText.Language,
    _ProductText.ProductName
   
}
