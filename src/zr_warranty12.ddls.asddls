@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'get count of condition type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY12 
as select from ZR_WARRANTY10 as _count
{
   key _count.SalesDoc,
   count( distinct (_count.ConditionType) ) as countConditionType
}
group by _count.SalesDoc
