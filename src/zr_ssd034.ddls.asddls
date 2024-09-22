@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Amount Report'
define root view entity ZR_SSD034 
    as select from I_BillingDocument as _BillingDocument
    
    inner join I_BillingDocumentItem as _BillingDocumentItem 
    on _BillingDocument.BillingDocument = _BillingDocumentItem.BillingDocument
    
    left outer join I_BillingDocumentPartner as _BillingDocumentPartner
    on _BillingDocumentPartner.BillingDocument = _BillingDocument.BillingDocument
    and _BillingDocumentPartner.PartnerFunction = 'WE'
    
    left outer join I_Product as _Product
    on _Product.Product = _BillingDocumentItem.Product
    
    association [0..1] to I_BillingDocumentTypeText_2 as _BillingDocumentTypeText_2
    on _BillingDocument.BillingDocumentType = _BillingDocumentTypeText_2.BillingDocumentType
    and _BillingDocumentTypeText_2.Language = 'E'
    
    association [0..1] to I_PaymentTermsText as _PaymentTermsText
    on _BillingDocument.CustomerPaymentTerms = _PaymentTermsText.PaymentTerms
    and _PaymentTermsText.Language = 'E'
    
    association [0..1] to I_OperationalAcctgDocItem as _OperationalAcctgDocItem
    on _OperationalAcctgDocItem.BillingDocument = _BillingDocument.BillingDocument
    and _OperationalAcctgDocItem.IsSalesRelated = 'X'
    
    association [0..1] to I_SalesDocItmSubsqntProcFlow as _SalesDocItmSubsqntProcFlow
    on _SalesDocItmSubsqntProcFlow.SubsequentDocument = _BillingDocument.BillingDocument
    and _SalesDocItmSubsqntProcFlow.SubsequentDocumentItem = _BillingDocumentItem.BillingDocumentItem
    and _SalesDocItmSubsqntProcFlow.SDDocumentCategory = 'C'
    
    association [0..1] to I_BusinessPartner as _BusinessPartner
    on _BusinessPartner.BusinessPartner = _BillingDocument.SoldToParty
    
    association [0..1] to I_Address_2 as _Address_2
    on _Address_2.AddressID = _BillingDocumentPartner.AddressID
    
    association [0..1] to I_PaymentTermsConditions as _PaymentTermsConditions
    on _PaymentTermsConditions.PaymentTerms = _BillingDocument.CustomerPaymentTerms
    
{
    key _BillingDocument.BillingDocument as InvoiceNumber,
    key _BillingDocumentItem.BillingDocumentItem as LineNumber,
    _BillingDocument.SalesOrganization,
    _BillingDocument.BillingDocumentType as BillingType,
    _BillingDocumentTypeText_2.BillingDocumentTypeName as BillingTypeDescription,
    'NAFED' as ReceiverID,
    'Atosa USA Inc.' as SupplierName,
    'ATOS20' as SupplierNumber,
    '201 N Berry St' as SupplierStreetAddress,
    '' as SupplierStreetAddress2,
    'Brea' as SupplierAddressCity,
    'CA' as SupplierAddressProvinceState,
    '92821' as SupplierAddressPostalZipCode,
    'Atosa USA Inc.' as RemitToName,
    '201 N Berry St' as RemitToStreetBoxAddress,
    '' as RemitToStreetBoxAddress2,
    'Brea' as RemitToCity,
    'CA' as RemitToProvinceState,
    '92821' as RemitToPostalZipCode,
    'NAFED' as BIillToName,
    '2502 Tilly Drive' as BillToStreetBoxAddress,
    '2502 Tilly Drive' as BillToStreetBoxAddress2,
    'Florence' as BillToCity,
    'SC' as BillToProvinceState,
    '29501' as BillToPostalZipCode,
    concat(_Address_2.OrganizationName1,_Address_2.OrganizationName2) as ShipToName,
    _BusinessPartner.YY1_BuyingGroupMemberI_bus as ShipToNumber,
    _Address_2.StreetName as ShipToStreetAddress,
    _Address_2.StreetName as ShipToStreetAddress2,
    _Address_2.CityName as ShipToCity,
    _Address_2.Region as ShipToProvinceState,
    _Address_2.PostalCode as ShipToPostalZipCode,
    '' as GSTRegistrationNumber,
    '' as QSTRegistrationNumber,
    '' as TaxExemptionNumber,
    cast(_BillingDocument.BillingDocumentDate as abap.char( 8 )) as InvoiceDate,
    '' as PurchaseOrderDate,
    _BillingDocument.PurchaseOrderByCustomer as PONumber,
    cast(_BillingDocument.BillingDocumentDate as abap.char( 8 )) as ShipDate,
    _PaymentTermsText.PaymentTermsName as TermsDescription,
    cast(_OperationalAcctgDocItem.NetDueDate as abap.char( 8 )) as InvoiceNetDueDate,
    _PaymentTermsConditions.CashDiscount1Percent as TermsDiscountPercent,
    cast(dats_add_days(_OperationalAcctgDocItem.NetDueDate,cast(_PaymentTermsConditions.CashDiscount1Days as int4),'NULL') as abap.char( 8 )) as TermsDiscountDueDate,
    '' as DeliveryInstructions,
    'PP' as ShippingMethodofPayment,
    'USD' as Currency,
    _SalesDocItmSubsqntProcFlow.SalesDocument as InternalOrderNumber,
    _SalesDocItmSubsqntProcFlow.SalesDocumentItem,
    '' as PackingSlipNumber,
    '' as BillofLadingNumber,
    '' as CreditAuthorizationNumber,
    '' as AccountNumber,
    '' as PromotionNumber,
    _BillingDocument.YY1_TrackingNumber_BDH as CarrierTrackingNumber,
    '' as StandardCarrierAlphaCodeSCAC,
    '' as ProjectJobNumber,
    '' as OriginalInvoiceNumber,
    '' as MessageorNotes,
    '' as GSTTotalTaxAmount,
    '' as HSTTotalTaxAmount,
    '' as PSTTotalTaxAmount,
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    cast(_BillingDocument.TotalTaxAmount as abap.dec( 15, 2 ) ) as TotalTaxAmount,
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    cast(_BillingDocument.TotalNetAmount as abap.dec( 15, 2 )) + cast(_BillingDocument.TotalTaxAmount as abap.dec( 15, 2 )) as InvoiceDocTotal,
//    _BillingDocument.TransactionCurrency,
    '' as AmountSubjectToTermsDiscount,
    '' as AmountPayableAfterTermsDiscoun,
    cast(_BillingDocumentItem.Product as zzesd021) as SupplierProductNumber,
    '' as BuyersItemNumber,
    '' as UniversalProductCodeUPC,
    _BillingDocumentItem.BillingQuantity as PiecesShipped,
    _BillingDocumentItem.BillingQuantity as UnitsShipped,
    _BillingDocumentItem.BillingQuantityUnit as UnitofMeasureDescription,
    '' as OriginalOrderQuantity,
    '' as BackOrderedQuantity,
    cast(cast(_BillingDocumentItem.NetAmount as abap.dec( 15, 2 )) / _BillingDocumentItem.BillingQuantity as abap.dec( 15, 2 )) as UnitPriceNetorGross,
    '' as DiscountPercent,
    '' as ExtendedLineDiscountAmount,
    '' as ProductRebateCategory,
    case 
    when
        _BusinessPartner.YY1_ChainAccount_bus = '101' then '-'
    when
        _BusinessPartner.YY1_ChainAccount_bus = '102' then 'Denny''s and Its Franchise'
    when
        _BusinessPartner.YY1_ChainAccount_bus = '103' then 'Wendy''s and Its Franchise'
    when
        _BusinessPartner.YY1_ChainAccount_bus = '104' then 'Keke''s and Its Franchise'
    else ''
    end as ChainAccountDescription,
    
    concat_with_space(_BusinessPartner.YY1_ChainAccount_bus,$projection.ChainAccountDescription,1) as ChainAccount,
    
    case
    when
        _BusinessPartner.YY1_NationalAccount_bus = '101' then 'Yes'
    when
        _BusinessPartner.YY1_NationalAccount_bus = '102' then 'No'
    when
        _BusinessPartner.YY1_NationalAccount_bus = '103' then '-'
    else ''
    end as NationalAccountDescription,
        
    
    concat_with_space(_BusinessPartner.YY1_NationalAccount_bus,$projection.NationalAccountDescription,1) as NationalAccount,
    
    case
    when
        _BusinessPartner.YY1_NoRebateOffered_bus = '101' then 'Yes'
    when
        _BusinessPartner.YY1_NoRebateOffered_bus = '102' then 'No'
    when
        _BusinessPartner.YY1_NoRebateOffered_bus = '103' then '-'
    else ''
    end as NoRebateOfferedDescription,
    
    concat_with_space(_BusinessPartner.YY1_NoRebateOffered_bus,$projection.NoRebateOfferedDescription,1) as NoRebateOffered,
    _BusinessPartner.YY1_Properties1_bus as Properties1,
    _BusinessPartner.YY1_Properties2_bus as Properties2
}
where _BillingDocument.BillingDocumentIsTemporary = ''
  and _BillingDocument.SDDocumentCategory <> '5'
  and _BillingDocument.SDDocumentCategory <> '6'
  and _BillingDocument.CustomerGroup = '03'
  and _Product.ProductGroup <> 'Z001'
  and _Product.ProductGroup <> 'Z003'
  and _Product.ProductGroup <> 'Z004'
  and _Product.ProductGroup <> 'Z005'
