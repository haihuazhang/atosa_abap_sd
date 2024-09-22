@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Picking due data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_SSD012 
    as select from I_OutboundDelivery as _OutboundDelivery
    inner join ZR_SSD016 as _AuthHeader on _AuthHeader.OutboundDelivery = _OutboundDelivery.OutboundDelivery
    
    association [0..1] to I_BusinessUserBasic as _BusinessUserBasic on _BusinessUserBasic.UserID = _OutboundDelivery.CreatedByUser
    association [0..1] to I_ShippingTypeText as _ShippingTypeText on _ShippingTypeText.ShippingType = _OutboundDelivery.ShippingType
                                                                 and _ShippingTypeText.Language = 'E'
    association [0..1] to I_Customer         as _SoldToParty on _SoldToParty.Customer = _OutboundDelivery.SoldToParty
    
{
    key _OutboundDelivery.OutboundDelivery,
//    @ObjectModel.text.association: '_ShippingType'
    _OutboundDelivery.ShippingType,
    
    cast( _AuthHeader.ReferenceSDDocument as zzesd014 ) as SalesOrder,
    _AuthHeader.Plant,
    _OutboundDelivery.CreatedByUser,
    _OutboundDelivery.CreationDate,
    _OutboundDelivery.CreationTime,
    _OutboundDelivery.LastChangedByUser,
    _OutboundDelivery.LastChangeDate,
    _OutboundDelivery.DeliveryDocumentType,
    _OutboundDelivery.SoldToParty,
    _SoldToParty.CustomerFullName as SoldToPartyName,
    _OutboundDelivery.OverallPickingStatus,
    _OutboundDelivery.TotalCreditCheckStatus,
    _BusinessUserBasic.PersonFullName as DNCreatedBy,
    _ShippingTypeText.ShippingTypeName
    
//    _OutboundDelivery._ShippingType
}
where _OutboundDelivery.OverallPickingStatus <> ''
  and _OutboundDelivery.DeliveryBlockReason = ''
//  and _OutboundDelivery.TotalCreditCheckStatus <> 'B'
  and _OutboundDelivery.TotalCreditCheckStatus <> 'C'

union select from I_CustomerReturnDelivery as _CustomerReturnDelivery
    inner join ZR_SSD016 as _AuthHeader on _AuthHeader.OutboundDelivery = _CustomerReturnDelivery.CustomerReturnDelivery
    
    association [0..1] to I_BusinessUserBasic as _BusinessUserBasic on _BusinessUserBasic.UserID = _CustomerReturnDelivery.CreatedByUser
    association [0..1] to I_ShippingTypeText as _ShippingTypeText on _ShippingTypeText.ShippingType = _CustomerReturnDelivery.ShippingType
                                                                 and _ShippingTypeText.Language = 'E'
    association [0..1] to I_Customer         as _SoldToParty on _SoldToParty.Customer = _CustomerReturnDelivery.SoldToParty
{
    key _CustomerReturnDelivery.CustomerReturnDelivery as OutboundDelivery,
    _CustomerReturnDelivery.ShippingType,
    cast( _AuthHeader.ReferenceSDDocument as zzesd014 ) as SalesOrder,
    _AuthHeader.Plant,
    _CustomerReturnDelivery.CreatedByUser,
    _CustomerReturnDelivery.CreationDate,
    _CustomerReturnDelivery.CreationTime,
    _CustomerReturnDelivery.LastChangedByUser,
    _CustomerReturnDelivery.LastChangeDate,
    _CustomerReturnDelivery.DeliveryDocumentType,
    _CustomerReturnDelivery.SoldToParty,
    _SoldToParty.CustomerFullName as SoldToPartyName,
    _CustomerReturnDelivery.OverallPickingStatus,
    '' as TotalCreditCheckStatus,
    _BusinessUserBasic.PersonFullName as DNCreatedBy,
    _ShippingTypeText.ShippingTypeName
//    _CustomerReturnDelivery._ShippingType
}
where _CustomerReturnDelivery.OverallPickingStatus <> ''
  and _CustomerReturnDelivery.TotalBlockStatus = ''
