@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Order Confirmation Output Item Plant'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PSD009
    as select from I_SalesDocumentItem as _SalesDocumentItem
    left outer join I_PlantStdVH as _PlantStdVH on _PlantStdVH.Plant = _SalesDocumentItem.Plant
{
    key _SalesDocumentItem.SalesDocument,
    max( _SalesDocumentItem.Plant ) as Plant,
    max( _PlantStdVH.PlantName ) as PlantName
}
group by _SalesDocumentItem.SalesDocument
