@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Print CDS of Shipping Label'
define root view entity ZR_PSD019
  as select from    I_OutboundDelivery  as _OutboundDelivery
  //    left outer join I_SalesDocItmSubsqntProcFlow as _SalesDocItmSubsqntProcFlow
  //        on _OutboundDelivery.OutboundDelivery = _SalesDocItmSubsqntProcFlow.SubsequentDocument
  //        and  _SalesDocItmSubsqntProcFlow.SDDocumentCategory = 'C'
    left outer join ZR_PSD014           as _SO        on _SO.DeliveryDocument = _OutboundDelivery.OutboundDelivery
    left outer join I_SDDocumentPartner as _DNPartner on  _OutboundDelivery.OutboundDelivery = _DNPartner.SDDocument
                                                      and _DNPartner.PartnerFunction         = 'WE'
  //    association [1..1] to I_SalesDocument as _SalesDocument
  //        on _SO.SalesDocument = _SalesDocument.SalesDocument
  association [1..1] to I_ShippingTypeText as _ShippingTypeText on  _OutboundDelivery.ShippingType = _ShippingTypeText.ShippingType
                                                                and _ShippingTypeText.Language     = 'E'
  association [1..1] to I_Address_2        as _Address          on  _DNPartner.AddressID = _Address.AddressID
  association [1..1] to I_BusinessPartner  as _BusinessPartner  on  _OutboundDelivery.SoldToParty = _BusinessPartner.BusinessPartner

{
  key _OutboundDelivery.OutboundDelivery,
      _SO.SalesDocument,
      _SO.PurchaseOrderByCustomer,
      _ShippingTypeText.ShippingTypeName,

      case when _SO.YY1_BusinessName_SDH = '' then _BusinessPartner.BusinessPartnerName else _SO.YY1_BusinessName_SDH end as YY1_BusinessName_SDH,

      //      _SO.YY1_BusinessName_SDH,
      _Address.StreetName,
      concat(_Address.CityName,concat_with_space(',',concat_with_space(_Address.Region,_Address.PostalCode,1) , 1))       as CityRegionPostalCode,
      _Address.Country,
      _SO.YY1_WhiteGlovesShipto_SDH,
      concat(_BusinessPartner.OrganizationBPName1,_BusinessPartner.OrganizationBPName2)                                   as SoldToParty,
      _SO.Plant,
      _SO.SalesOrganization
}
where
      _OutboundDelivery.DeliveryDocumentType <> 'LR'
  and _OutboundDelivery.DeliveryDocumentType <> 'LR2'
