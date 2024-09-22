@EndUserText.label: 'Outbound Delivery CDS for PGI'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_SSD017
  as projection on ZR_SSD017
  //  association [0..*] to I_OutboundDeliveryTextTP as _OutboundDeliveryTextTP on  _OutboundDeliveryTextTP.OutboundDelivery = $projection.OutboundDelivery
  //                                                                            and _OutboundDeliveryTextTP.Language         = 'E'
  //                                                                            and _OutboundDeliveryTextTP.LongTextID       = 'TX07'
{
          //    key OutboundDelivery,

          //    ShippingType,
  key     ZR_SSD017.OutboundDelivery,
//          @ObjectModel.text.association: '_ShippingType'
//          ZR_SSD017.ShippingType,
          ZR_SSD017._ShippingTypeText.ShippingTypeName as ShippingType,
          ZR_SSD017.Plant,
          //      ZR_SSD017.LongText,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_002'
  virtual LongText : abap.sstring( 255 ),
          ZR_SSD017.SalesOrder,
          ZR_SSD017.DNPickedBy,
          ZR_SSD017.CreatedByUser,
          ZR_SSD017.CreationDate,
          ZR_SSD017.CreationTime,
          ZR_SSD017.LastChangedByUser,
          ZR_SSD017.LastChangeDate,
          ZR_SSD017.YY1_BLNumber_DLH,
          ZR_SSD017.YY1_TrackingNumber_DLH,
          ZR_SSD017.DeliveryDocumentType,
          ZR_SSD017.SoldToParty,
          ZR_SSD017.SoldToPartyName,
          ZR_SSD017.DeliveryBlockReason,
          ZR_SSD017.TotalCreditCheckStatus,
          ZR_SSD017.OverallPickingStatus,
          ZR_SSD017.OverallGoodsMovementStatus,
          /* Associations */
          ZR_SSD017._DeliveryDocument
          
          /* Associations */
          //    _ShippingType
          //    _OutboundDeliveryTextTP
}
