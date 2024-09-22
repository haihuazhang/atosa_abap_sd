@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_SSD027
  as select from    I_BillingDocumentItem          as _BillingDocumentItem
    left outer join I_BillingDocument              as _BillingDocument              on _BillingDocument.BillingDocument = _BillingDocumentItem.BillingDocument
    left outer join I_BillingDocumentTypeText      as _BillingDocumentTypeText      on  _BillingDocument.BillingDocumentType = _BillingDocumentTypeText.BillingDocumentType
                                                                                    and _BillingDocumentTypeText.Language    = 'E'
    left outer join I_Customer                     as _Customer                     on _Customer.Customer = _BillingDocument.SoldToParty
    left outer join I_BusinessPartner              as _BusinessPartner              on _BillingDocument.SoldToParty = _BusinessPartner.BusinessPartner
    left outer join I_BillingDocumentPartner       as _BillingDocumentPartnerAG     on  _BillingDocument.BillingDocument          = _BillingDocumentPartnerAG.BillingDocument
                                                                                    and _BillingDocumentPartnerAG.PartnerFunction = 'AG'
    left outer join I_BillingDocumentPartner       as _BillingDocumentPartnerWE     on  _BillingDocument.BillingDocument          = _BillingDocumentPartnerWE.BillingDocument
                                                                                    and _BillingDocumentPartnerWE.PartnerFunction = 'WE'
    left outer join I_BillingDocumentPartner       as _BillingDocumentPartnerZW     on  _BillingDocument.BillingDocument          = _BillingDocumentPartnerZW.BillingDocument
                                                                                    and _BillingDocumentPartnerZW.PartnerFunction = 'Z0'
    left outer join I_Address_2                    as _Address2AG                   on _Address2AG.AddressID = _BillingDocumentPartnerAG.AddressID
    left outer join I_Address_2                    as _Address2WE                   on _Address2WE.AddressID = _BillingDocumentPartnerWE.AddressID
    left outer join I_Address_2                    as _Address2ZW                   on _Address2ZW.AddressID = _BillingDocumentPartnerZW.AddressID
    left outer join I_CustomerGroupText            as _CustomerGroupText            on  _CustomerGroupText.CustomerGroup = _BillingDocument.CustomerGroup
                                                                                    and _CustomerGroupText.Language      = 'E'
    left outer join I_Plant                        as _Plant                        on _Plant.Plant = _BillingDocumentItem.Plant
    left outer join I_ProductGroupText_2           as _ProductGroupText2            on  _ProductGroupText2.ProductGroup = _BillingDocumentItem.ProductGroup
                                                                                    and _ProductGroupText2.Language     = 'E'
    left outer join I_CustomerSalesArea            as _CustomerSalesArea            on  _CustomerSalesArea.Customer          = _BillingDocument.SoldToParty
                                                                                    and _CustomerSalesArea.SalesOrganization = _BillingDocument.SalesOrganization
    left outer join I_AdditionalCustomerGroup1Text as _AdditionalCustomerGroup1Text on  _AdditionalCustomerGroup1Text.AdditionalCustomerGroup1 = _CustomerSalesArea.AdditionalCustomerGroup1
                                                                                    and _AdditionalCustomerGroup1Text.Language                 = 'E'
    left outer join I_SalesDocItemPricingElement   as _SalesDocItemPricingElement   on  _SalesDocItemPricingElement.SalesDocument     = _BillingDocumentItem.SalesDocument
                                                                                    and _SalesDocItemPricingElement.SalesDocumentItem = _BillingDocumentItem.SalesDocumentItem
                                                                                    and _SalesDocItemPricingElement.ConditionType = 'PPR0'
    left outer join I_SalesDocument                as _SalesDocument                on _BillingDocumentItem.SalesDocument = _SalesDocument.SalesDocument
                                                                                    and (_SalesDocument.SDDocumentCategory = 'C' or _SalesDocument.SDDocumentCategory = 'H' or _SalesDocument.SDDocumentCategory = 'I')
{
  key _BillingDocumentItem.BillingDocument,
  key _BillingDocumentItem.BillingDocumentItem,
      _BillingDocument.PurchaseOrderByCustomer as CustomerReference,
      _BillingDocument.BillingDocumentDate as PostingDate,
      _BillingDocument.SoldToParty as Customer,
      _BillingDocument.SalesOrganization,
      _SalesDocument.SalesDocument,
      _SalesDocument.CreationDate,
      _BillingDocumentItem.Product,
      _BillingDocumentItem.ProductGroup as MaterialGroup,
      _BillingDocumentItem.Plant,
//      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      cast(_BillingDocumentItem.BillingQuantity as abap.dec(15,3)) as BillingQuantity,
      //      @Semantics.unitOfMeasure: true
//      _BillingDocumentItem.BillingQuantityUnit,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(_BillingDocumentItem.NetAmount as abap.dec(15,2)) as NetAmount,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(_BillingDocumentItem.TaxAmount as abap.dec(15,2)) as TaxAmount,
//      @Semantics.amount.currencyCode: 'TransactionCurrency'
      cast(_BillingDocumentItem.CostAmount as abap.dec(15,2)) as CostAmount,
      _SalesDocument.YY1_Project_SDH,
      _BillingDocumentItem.YY1_WarrantyMaterial_BDI,
      _BillingDocumentItem.YY1_WarrantySerial_BDI,
//      _BillingDocumentItem.TransactionCurrency,
      _BillingDocumentTypeText.BillingDocumentTypeName,
      concat(_Customer.BusinessPartnerName3,_Customer.BusinessPartnerName4) as AddressSearchTerm1,
      _BusinessPartner.BusinessPartnerIDByExtSystem as AddressSearchTerm2,
      _CustomerGroupText.CustomerGroupName,
      _Plant.PlantName,
      _ProductGroupText2.ProductGroupName,
      _ProductGroupText2.ProductGroupText,
      _BillingDocumentPartnerWE.Customer as ShipToParty,
      _AdditionalCustomerGroup1Text.AdditionalCustomerGroup1Name,
//      _BillingDocumentPartnerAG.AddressID as AddressID1,
//      _BillingDocumentPartnerWE.AddressID as AddressID2,
//      _BillingDocumentPartnerVE.AddressID as AddressID3,
      case
      when (_SalesDocItemPricingElement.ConditionIsManuallyChanged = 'X')
      then
      'Yes'
      end as ManualPrice,
      concat(_Customer.BusinessPartnerName1,_Customer.BusinessPartnerName2) as CustomerName,
      _Address2AG.Region as SoldToRegion,
      concat(_Address2WE.OrganizationName1,_Address2WE.OrganizationName2) as ShipToPartyName,
      _Address2WE.StreetName as ShipToStreet,
      _Address2WE.CityName as ShipToCity,
      _Address2WE.Region as ShipToRegion,
      concat(_Address2ZW.OrganizationName1,_Address2ZW.OrganizationName2) as SalesEmployee,
      _BillingDocument.BillingDocumentIsCancelled,
      _BillingDocument.CancelledBillingDocument,
      _BusinessPartner.YY1_ChainAccount_bus,
      _BusinessPartner.YY1_NationalAccount_bus,
      _BusinessPartner.YY1_NoRebateOffered_bus,
      _BusinessPartner.YY1_Properties1_bus,
      _BusinessPartner.YY1_Properties2_bus
}
where _BillingDocument.BillingDocumentIsTemporary = ''
