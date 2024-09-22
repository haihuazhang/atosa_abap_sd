@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Select Open Qty of Backorder(DN)'
define root view entity ZR_SSD047
  as select from    I_DeliveryDocument     as _DeliveryDocument
    left outer join I_DeliveryDocumentItem as _DeliveryItem on  _DeliveryDocument.DeliveryDocument =  _DeliveryItem.DeliveryDocument
                                                            and _DeliveryItem.SDDocumentCategory   =  'J'
                                                            and _DeliveryItem.PickingStatus        <> ''
{
  key _DeliveryItem.DeliveryDocument,
  key _DeliveryItem.ReferenceSDDocument,
  key _DeliveryItem.ReferenceSDDocumentItem,
      cast(sum(_DeliveryItem.ActualDeliveryQuantity) as abap.dec(13,3)) as ActualDeliveryQuantity
}
where
  (
       _DeliveryDocument.DeliveryDocumentType       =  'LF'
    or _DeliveryDocument.DeliveryDocumentType       =  'NLCC'
  )
  and  _DeliveryDocument.OverallGoodsMovementStatus <> 'C'
  and  _DeliveryDocument.OverallGoodsMovementStatus <> ''
group by
  _DeliveryItem.DeliveryDocument,
  _DeliveryItem.ReferenceSDDocument,
  _DeliveryItem.ReferenceSDDocumentItem
