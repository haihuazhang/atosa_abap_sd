@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'print CDS of salesdocument'
define view entity ZR_PSD002 
as select from I_DeliveryDocumentItem as _OutboundDeliveryItem
left outer join I_Plant as _Plant on _Plant.Plant = _OutboundDeliveryItem.Plant
{
    key _OutboundDeliveryItem.DeliveryDocument as DeliveryDocument,
        max(_OutboundDeliveryItem.Plant) as Plant,
        max(_Plant.PlantName) as PlantName
}
group by _OutboundDeliveryItem.DeliveryDocument
//union
//select from I_CustomerReturnDeliveryItem as _OutboundDeliveryItem
//left outer join I_Plant as _Plant on _Plant.Plant = _OutboundDeliveryItem.Plant
//{
//    key _OutboundDeliveryItem.CustomerReturnDelivery as DeliveryDocument,
//        max(_OutboundDeliveryItem.Plant) as Plant,
//        max(_Plant.PlantName) as PlantName
//}
//group by _OutboundDeliveryItem.CustomerReturnDelivery
