@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Outbound Delivery CDS for PGI'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SSD017
  as select from I_OutboundDelivery as _OutboundDelivery
  //association [0..1] to I_OutboundDeliveryTextTP as _OutboundDeliveryText on _OutboundDeliveryText.OutboundDelivery = $projection.OutboundDelivery
  //                                                                        and _OutboundDeliveryText.LongTextID = 'TX07'
  //                                                                        and _OutboundDeliveryText.Language = 'E'
    inner join   ZR_SSD016          as _AuthHeader on _AuthHeader.OutboundDelivery = _OutboundDelivery.OutboundDelivery

  association [0..1] to I_BusinessUserBasic as _BusinessUser     on _BusinessUser.UserID = _OutboundDelivery.LastChangedByUser
  association [0..1] to I_DeliveryDocument  as _DeliveryDocument on _DeliveryDocument.DeliveryDocument = $projection.OutboundDelivery
  association [0..1] to I_Customer          as _SoldToParty      on _SoldToParty.Customer = _OutboundDelivery.SoldToParty
  association [0..1] to I_ShippingTypeText      as _ShippingTypeText on $projection.ShippingType = _ShippingTypeText.ShippingType
                                                                        and _ShippingTypeText.Language = $session.system_language
{
  key _OutboundDelivery.OutboundDelivery,

//      @ObjectModel.text.association: '_ShippingType'
      _OutboundDelivery.ShippingType,

      //      @ObjectModel.virtualElement:true
      //      @ObjectModel.virtualElementCalculatedBy: 'ABAP:CL_LE_LONGTEXT_SADL_OBD_HEAD'
      //      cast( '' as abap.sstring( 255 ) ) as LongText,
      //       virtual LongText : abap.sstirng( 255 ),
      cast( _AuthHeader.ReferenceSDDocument as zzesd014 ) as SalesOrder,
      _AuthHeader.Plant,
      _BusinessUser.PersonFullName                        as DNPickedBy,
      _OutboundDelivery.CreatedByUser,
      _OutboundDelivery.CreationDate,
      _OutboundDelivery.CreationTime,
      _OutboundDelivery.LastChangedByUser,
      _OutboundDelivery.LastChangeDate,
      _DeliveryDocument.YY1_BLNumber_DLH,
      _DeliveryDocument.YY1_TrackingNumber_DLH,
      _OutboundDelivery.DeliveryDocumentType,
      _OutboundDelivery.SoldToParty,
      _SoldToParty.CustomerFullName                       as SoldToPartyName,
      _OutboundDelivery.DeliveryBlockReason,
      _OutboundDelivery.OverallPickingStatus,
      _OutboundDelivery.OverallGoodsMovementStatus,
      _OutboundDelivery.TotalCreditCheckStatus,

      _OutboundDelivery._ShippingType,
      _ShippingTypeText,

      _DeliveryDocument,
      _SoldToParty

}
where
        _OutboundDelivery.OverallPickingStatus   =  'C'
  and   _OutboundDelivery.DeliveryBlockReason    =  ''
  and   _OutboundDelivery.OverallGoodsMovementStatus = 'A'
  and(
        _OutboundDelivery.TotalCreditCheckStatus <> 'B'
    and _OutboundDelivery.TotalCreditCheckStatus <> 'C'
  )

union select from I_CustomerReturnDelivery as _CustomerReturnDelivery
  inner join      ZR_SSD016                as _AuthHeader on _AuthHeader.OutboundDelivery = _CustomerReturnDelivery.CustomerReturnDelivery
association [0..1] to I_BusinessUserBasic as _BusinessUser     on _BusinessUser.UserID = _CustomerReturnDelivery.LastChangedByUser
association [0..1] to I_DeliveryDocument  as _DeliveryDocument on _DeliveryDocument.DeliveryDocument = $projection.OutboundDelivery
association [0..1] to I_Customer          as _SoldToParty      on _SoldToParty.Customer = _CustomerReturnDelivery.SoldToParty
association [0..1] to I_ShippingTypeText      as _ShippingTypeText on $projection.ShippingType = _ShippingTypeText.ShippingType
                                                                        and _ShippingTypeText.Language = $session.system_language
{
  key _CustomerReturnDelivery.CustomerReturnDelivery      as OutboundDelivery,

      //      @ObjectModel.text.association: '_ShippingType'
      _CustomerReturnDelivery.ShippingType,


      cast( _AuthHeader.ReferenceSDDocument as zzesd014 ) as SalesOrder,
      _AuthHeader.Plant,
      _BusinessUser.PersonFullName                        as DNPickedBy,
      _CustomerReturnDelivery.CreatedByUser,
      _CustomerReturnDelivery.CreationDate,
      _CustomerReturnDelivery.CreationTime,
      _CustomerReturnDelivery.LastChangedByUser,
      _CustomerReturnDelivery.LastChangeDate,
      _DeliveryDocument.YY1_BLNumber_DLH,
      _DeliveryDocument.YY1_TrackingNumber_DLH,
      _CustomerReturnDelivery.DeliveryDocumentType,
      _CustomerReturnDelivery.SoldToParty,
      _SoldToParty.CustomerFullName                       as SoldToPartyName,
      _CustomerReturnDelivery.DeliveryBlockReason,
      _CustomerReturnDelivery.OverallPickingStatus,
      _CustomerReturnDelivery.OverallGoodsMovementStatus,
      //      _CustomerReturnDelivery.TotalCreditCheckStatus,
      cast( 'D' as abap.char( 1 ))                        as TotalCreditCheckStatus,

      _CustomerReturnDelivery._ShippingType,
      _ShippingTypeText,
      _DeliveryDocument,
      _SoldToParty


}
where
        _CustomerReturnDelivery.OverallPickingStatus   =  'C'
  and   _CustomerReturnDelivery.DeliveryBlockReason    =  ''
  and   _CustomerReturnDelivery.OverallGoodsMovementStatus = 'A'
