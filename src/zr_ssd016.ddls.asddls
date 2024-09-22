@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'Delivery Document with Plant/StorageLocation'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_SSD016
  as select from I_OutboundDeliveryItem

{
  key OutboundDelivery,
      //    key OutboundDeliveryItem,
      //        DeliveryDocumentItemCategory,
      //    SalesDocumentItemType,
      max( Plant )               as Plant,
      max( ReferenceSDDocument ) as ReferenceSDDocument
      //        StorageLocation,


}
//where PickingStatus <> ''
group by
  OutboundDelivery

union select from I_CustomerReturnDeliveryItem
{
  key CustomerReturnDelivery     as OutboundDelivery,
      max( Plant )               as Plant,
      max( ReferenceSDDocument ) as ReferenceSDDocument
}

group by
  CustomerReturnDelivery
