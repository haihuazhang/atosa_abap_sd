@EndUserText.label: 'Packing Slip PrintOut - Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZR_PSD013
  as select from           I_DeliveryDocument         as _DN
    left outer join        I_OverallPickingStatusText as _PickingStatusT   on  _PickingStatusT.OverallPickingStatus = _DN.OverallPickingStatus
                                                                           and _PickingStatusT.Language             = $session.system_language
    left outer join        I_ShippingTypeText         as _ShippingTypeText on  _ShippingTypeText.ShippingType = _DN.ShippingType
                                                                           and _ShippingTypeText.Language     = $session.system_language

    left outer join        ZR_PSD014                  as _SO               on _DN.DeliveryDocument = _SO.DeliveryDocument
    left outer join        I_Customer                 as _BillTo           on _DN.SoldToParty = _BillTo.Customer
    left outer join        I_BusinessPartner          as _BillToBP         on _DN.SoldToParty = _BillToBP.BusinessPartner
    left outer join        I_SDDocumentPartner        as _BillToP          on  _DN.DeliveryDocument     = _BillToP.SDDocument
                                                                           and _BillToP.PartnerFunction = 'AG'


    left outer join        I_Address_2                as _BillTOAddr       on  _BillToP.AddressID                    = _BillTOAddr.AddressID
                                                                           and _BillTOAddr.AddressRepresentationCode is initial
                                                                           and _BillTOAddr.AddressPersonID           is initial

    left outer join        I_Customer                 as _ShipTo           on _DN.ShipToParty = _ShipTo.Customer
    left outer join        I_BusinessPartner          as _ShipToBP         on _DN.ShipToParty = _ShipToBP.BusinessPartner
    left outer join        I_SDDocumentPartner        as _ShipToP          on  _DN.DeliveryDocument     = _ShipToP.SDDocument
                                                                           and _ShipToP.PartnerFunction = 'WE'


    left outer join        I_Address_2                as _ShipToAddr       on  _ShipToP.AddressID                    = _ShipToAddr.AddressID
                                                                           and _ShipToAddr.AddressRepresentationCode is initial
                                                                           and _ShipToAddr.AddressPersonID           is initial

    left outer join        I_Plant                    as _Plant            on _SO.Plant = _Plant.Plant

    left outer to one join ZR_TSD003                  as _AtosaWillCall    on _AtosaWillCall.Customer = _DN.ShipToParty

  association [0..*] to ZR_PSD015 as _Item on _Item.DeliveryDocument = $projection.DeliveryDocument


{
  key _DN.DeliveryDocument,
      _SO.CreationDate,
      _DN.OverallPickingStatus,
      _PickingStatusT.OverallPickingStatusDesc,
      _DN.ShippingType,
      _ShippingTypeText.ShippingTypeName,
      ltrim(_SO.SalesDocument, '0')                                                                                                          as SalesDocument,
      _SO.PurchaseOrderByCustomer,
      cast ( _DN.SoldToParty as zzesd004 )                                                                                                   as SoldToParty,
      //      case when _BillTo.AddressSearchTerm1 is null then _DN.SoldToParty else
      case when _BillToBP.BusinessPartnerIDByExtSystem is null or _BillToBP.BusinessPartnerIDByExtSystem = '' then _DN.SoldToParty else
      concat_with_space( _DN.SoldToParty , concat_with_space( '/' , _BillToBP.BusinessPartnerIDByExtSystem , 1 ) , 1 ) end                   as BillToAddrLine1,

      concat( _BillTo.OrganizationBPName1 , _BillTo.OrganizationBPName2 )                                                                    as BillToAddrLine2,
      _BillTOAddr.StreetName                                                                                                                 as BillToAddrLine3,
      concat_with_space( concat_with_space( concat( _BillTOAddr.CityName , ','  ) ,  _BillTOAddr.Region , 1 ) , _BillTOAddr.PostalCode , 1 ) as BillToAddrLine4,
      _BillTOAddr.Country                                                                                                                    as BillToAddrLine5,


      cast( _DN.ShipToParty as zzesd004 )                                                                                                    as ShipToParty,
      //      case when _ShipTo.AddressSearchTerm1 is null then _DN.ShipToParty else
      case when _ShipToBP.BusinessPartnerIDByExtSystem is null or _ShipToBP.BusinessPartnerIDByExtSystem = '' then _DN.ShipToParty else
       concat_with_space( _DN.ShipToParty , concat_with_space( '/' , _ShipToBP.BusinessPartnerIDByExtSystem , 1 ) , 1 ) end                  as ShipToAddrLine1,
      concat( _ShipTo.OrganizationBPName1 , _ShipTo.OrganizationBPName2 )                                                                    as ShipToAddrLine2,
      _ShipToAddr.StreetName                                                                                                                 as ShipToAddrLine3,
      concat_with_space( concat_with_space( concat( _ShipToAddr.CityName , ','  ) ,  _ShipToAddr.Region , 1) , _ShipToAddr.PostalCode , 1)   as ShipToAddrLine4,
      _ShipToAddr.Country                                                                                                                    as ShipToAddrLine5,

      _SO.Plant,
      //      substring( _Plant.PlantName , 1 , 3)                                                                                                   as ShipForm,
      _Plant.PlantName                                                                                                                       as ShipForm,
      _AtosaWillCall.Customer                                                                                                                as AtosaWillCall,
      _SO.SalesOrganization,
      _Item


}
