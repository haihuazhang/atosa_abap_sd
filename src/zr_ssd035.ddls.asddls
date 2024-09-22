@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Scanned Serial Number Latest Changed'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD035 
    as select from ZR_TSD013
{
    key ZR_TSD013.DeliveryNumber,
    key ZR_TSD013.DeliveryItem,
    max(ZR_TSD013.ScannedDate) as ScannedDate,
    max(ZR_TSD013.ScannedTime) as ScannedTime
}
group by ZR_TSD013.DeliveryNumber,
ZR_TSD013.DeliveryItem
