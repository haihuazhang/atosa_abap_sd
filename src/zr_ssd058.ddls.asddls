@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Report of SD Order Details 113.01.1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_SSD058
  as select from    I_SalesDocumentItem           as _SalesDocumentItem
    left outer join I_SalesDocument               as _SalesDocument               on _SalesDocumentItem.SalesDocument = _SalesDocument.SalesDocument
    left outer join I_SalesDocumentPartner        as _SalesDocumentPartner        on  _SalesDocumentItem.SalesDocument      = _SalesDocumentPartner.SalesDocument
                                                                                  and _SalesDocumentItem.SoldToParty        = _SalesDocumentPartner.Customer
                                                                                  and _SalesDocumentPartner.PartnerFunction = 'AG'
    left outer join I_BusinessPartner             as _BusinessPartner             on _SalesDocument.SoldToParty = _BusinessPartner.BusinessPartner
    left outer join I_SalesDocumentRjcnReasonText as _SalesDocumentRjcnReasonText on  _SalesDocumentItem.SalesDocumentRjcnReason = _SalesDocumentRjcnReasonText.SalesDocumentRjcnReason
                                                                                  and _SalesDocumentRjcnReasonText.Language      = 'E'
    left outer join I_PlantStdVH                  as _PlantStdVH                  on _SalesDocumentItem.Plant = _PlantStdVH.Plant
    left outer join I_SalesDocumentPartner        as _SalesDocumentPartnerWE      on  _SalesDocumentItem.SalesDocument        = _SalesDocumentPartnerWE.SalesDocument
                                                                                  and _SalesDocumentPartnerWE.PartnerFunction = 'WE'
    left outer join I_Address_2                   as _Address_2                   on _SalesDocumentPartnerWE.AddressID = _Address_2.AddressID
    left outer join I_ShippingTypeText            as _ShippingTypeText            on  _SalesDocument.ShippingType = _ShippingTypeText.ShippingType
                                                                                  and _ShippingTypeText.Language  = 'E'
    left outer join ZR_SSD061                     as _SSD061                      on  _SalesDocumentItem.SalesDocument     = _SSD061.SalesDocument
                                                                                  and _SalesDocumentItem.SalesDocumentItem = _SSD061.SalesDocumentItem
    left outer join ZR_SSD062                     as _SSD062                      on  _SalesDocumentItem.SalesDocument     = _SSD062.SalesDocument
                                                                                  and _SalesDocumentItem.SalesDocumentItem = _SSD062.SalesDocumentItem
{
  key _SalesDocumentItem.SalesDocument,
  key cast(_SalesDocumentItem.SalesDocumentItem as abap.char(6)) as SalesDocumentItem,
      _SalesDocument.YY1_NatAccountsTeamCS_SDH,
      _SalesDocument.SoldToParty,
      _SalesDocument.YY1_Project_SDH,
      _SalesDocument.PurchaseOrderByCustomer,
      _SalesDocument.CreationDate,
      _SalesDocument.RequestedDeliveryDate,
      _SalesDocument.YY1_BusinessName_SDH,
      _SalesDocument.YY1_ContactName_SDH,
      _SalesDocument.YY1_ContactPhone_SDH,
      _SalesDocument.YY1_WhiteGlovesShipto_SDH,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(_SalesDocument.TotalNetAmount as abap.dec(15,2)) as TotalNetAmount,
      _SalesDocument.TransactionCurrency,
      _SalesDocument.YY1_TrackingNumber_SDH,
      _SalesDocumentItem.SalesDocumentRjcnReason,
      _SalesDocumentItem.Material,
//      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      case
      when ( _SalesDocument.SalesDocumentType = 'G2' or _SalesDocument.SalesDocumentType = 'L2' or _SalesDocument.SalesDocumentType = 'GA2' )
      then
      cast(_SalesDocumentItem.RequestedQuantity as abap.dec(15,3))
      else
      cast(_SalesDocumentItem.OrderQuantity as abap.dec(15,3))
      end                    as OrderQuantity,
      //    @Semantics.unitOfMeasure: true
      _SalesDocumentItem.OrderQuantityUnit,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(_SalesDocumentItem.NetAmount as abap.dec(15,2)) as NetAmount,
      _SalesDocumentPartner.FullName,
      _BusinessPartner.YY1_ChainAccount_bus,
      _BusinessPartner.YY1_NationalAccount_bus,
      _SalesDocumentRjcnReasonText.SalesDocumentRjcnReasonName,
      _PlantStdVH.PlantName,
      _Address_2.Street,
      _Address_2.CityName,
      _Address_2.Region,
      _Address_2.PostalCode,
      _ShippingTypeText.ShippingTypeName,
      case
      when (_SalesDocumentItem.SalesDocumentRjcnReason is not initial)
      then
      cast('Reject' as abap.char(6))
      else
      case
      when (_SSD061.OpenReqdDelivQtyInOrdQtyUnit is not initial)
      then
      cast('Open' as abap.char(6))
      else
      cast('Close' as abap.char(6))
      end
      end                    as status,
      case
      when (_SalesDocumentItem.SalesDocumentRjcnReason is not initial)
      then
      cast(0 as abap.dec(10,0))
      else
      _SSD062.OpenReqdDelivQtyInOrdQtyUnit
      end                    as OpenQuantity,
      cast(
      case
      when ($projection.OrderQuantity is null or $projection.NetAmount is null)
      then
      0
      else
      $projection.OrderQuantity * $projection.NetAmount
      end as abap.dec(13,3)) as ItemTotal
}
