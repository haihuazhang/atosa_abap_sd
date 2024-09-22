@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '103.14.1 Pick List Details'
define root view entity ZR_SSD053
  as select from I_DeliveryDocument     as _DeliveryDocument
    inner join   I_DeliveryDocumentItem as _DeliveryDocumentItem on _DeliveryDocumentItem.DeliveryDocument = _DeliveryDocument.DeliveryDocument

  association [0..1] to I_SalesDocItmSubsqntProcFlow as _SalesDocItmFlow          on  _SalesDocItmFlow.SubsequentDocument       = $projection.DeliveryDocument
                                                                                  and _SalesDocItmFlow.SubsequentDocumentItem   = $projection.DeliveryDocumentItem
                                                                                  and (
                                                                                     (
                                                                                       $projection.DeliveryDocumentType         = 'LF'
                                                                                       and(
                                                                                         _SalesDocItmFlow.SDDocumentCategory    = 'C'
                                                                                         or _SalesDocItmFlow.SDDocumentCategory = 'I'
                                                                                       )
                                                                                     )
                                                                                     or(
                                                                                       $projection.DeliveryDocumentType         = 'LR2'
                                                                                       and _SalesDocItmFlow.SDDocumentCategory  = 'H'
                                                                                     )
                                                                                   )
  association [0..1] to I_DeliveryDocumentTypeText   as _DeliveryDocumentTypeText on  _DeliveryDocumentTypeText.DeliveryDocumentType = $projection.DeliveryDocumentType
                                                                                  and _DeliveryDocumentTypeText.Language             = $session.system_language
  association [0..1] to I_OverallPickingStatusText   as _OverallPickingStatusText on  _OverallPickingStatusText.OverallPickingStatus = $projection.OverallPickingStatus
                                                                                  and _OverallPickingStatusText.Language             = $session.system_language
  association [0..1] to I_BusinessPartner            as _BusinessPartner          on  _BusinessPartner.BusinessPartner = $projection.SoldToParty
  association [0..1] to I_BusinessUserBasic          as _BusinessUserBasic        on  _BusinessUserBasic.UserID = $projection.CreatedByUser
  association [0..1] to I_Plant                      as _Plant                    on  _Plant.Plant = $projection.Plant
  association [0..1] to I_ProductText                as _ProductText              on  _ProductText.Product  = $projection.Product
                                                                                  and _ProductText.Language = $session.system_language
{

  key _DeliveryDocument.DeliveryDocument,
  key _DeliveryDocumentItem.DeliveryDocumentItem,

      _DeliveryDocument.DeliveryDocumentType,
      _DeliveryDocument.OverallPickingStatus,
      _DeliveryDocument.SoldToParty,
      _DeliveryDocument.ShippingPoint,
      _DeliveryDocument.CreationDate,
      _DeliveryDocument.CreatedByUser,

      _DeliveryDocumentItem.Product,
      _DeliveryDocumentItem.Plant,
      _DeliveryDocumentItem.ActualDeliveryQuantity,
      _DeliveryDocumentItem.DeliveryQuantityUnit,

      /* association */
      _SalesDocItmFlow,
      _DeliveryDocumentTypeText,
      _OverallPickingStatusText,
      _BusinessPartner,
      _BusinessUserBasic,
      _Plant,
      _ProductText
}
where
  _DeliveryDocumentItem.PickingStatus <> ''
