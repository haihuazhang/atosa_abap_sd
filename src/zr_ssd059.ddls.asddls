@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'AR Invoice No of 113.01.1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD059 
as select from I_SalesDocItmSubsqntProcFlow as _SalesDocItmSubsqntProcFlow
left outer join I_SalesDocumentItem as _SalesDocumentItem on _SalesDocItmSubsqntProcFlow.SalesDocument = _SalesDocumentItem.SalesDocument
                                                          and _SalesDocItmSubsqntProcFlow.SalesDocumentItem = _SalesDocumentItem.SalesDocumentItem
                                                          and _SalesDocItmSubsqntProcFlow.SubsequentDocumentCategory = 'M'
{
    key _SalesDocItmSubsqntProcFlow.SubsequentDocument,
    _SalesDocItmSubsqntProcFlow.SalesDocument,
    _SalesDocItmSubsqntProcFlow.SalesDocumentItem
}
