@EndUserText.label: 'Billing Amount Report'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@UI: {
    headerInfo: {
        typeNamePlural: 'Results'
    }
}
define root view entity ZC_SSD034 
    provider contract transactional_query
    as projection on ZR_SSD034
{   
    @UI:{
        lineItem: [ { position: 34,
                      importance: #HIGH,
                      label: 'Invoice Number' } ],
        selectionField: [{ position: 2 }]
    }
    @EndUserText.label: 'Invoice Number'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BillingDocument', element: 'BillingDocument' }}]
    key InvoiceNumber,
    @UI:{
        lineItem: [ { position: 69,
                      importance: #LOW,
                      label: 'Line Number' } ]
    }
    key LineNumber,
    @UI.hidden: true
    SalesOrganization,
    @UI:{
        lineItem: [ { position: 1,
                      importance: #HIGH,
                      label: 'Billing Type' } ],
        selectionField: [{ position: 1 }]
    }
    @EndUserText.label: 'Billing Type'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BillingDocument', element: 'BillingDocumentType' }}]
    BillingType,
    @UI:{
        lineItem: [ { position: 2,
                      importance: #HIGH,
                      label: 'Billing Type Description' } ]
    }
    @EndUserText.label: 'Billing Type Description'
    BillingTypeDescription,
    @UI:{
        lineItem: [ { position: 3,
                      importance: #HIGH,
                      label: 'Receiver ID for Buying Group/Customer' } ]
    }
    @EndUserText.label: 'Receiver ID for Buying Group/Customer'
    ReceiverID,
    @UI:{
        lineItem: [ { position: 4,
                      importance: #HIGH,
                      label: 'Supplier Name' } ]
    }
    @EndUserText.label: 'Supplier Name'
    SupplierName,
    @UI:{
        lineItem: [ { position: 5,
                      importance: #HIGH,
                      label: 'Supplier Number' } ]
    }
    @EndUserText.label: 'Supplier Number'
    SupplierNumber,
    @UI:{
        lineItem: [ { position: 6,
                      importance: #HIGH,
                      label: 'Supplier Street Address' } ]
    }
    @EndUserText.label: 'Supplier Street Address'
    SupplierStreetAddress,
    @UI:{
        lineItem: [ { position: 7,
                      importance: #HIGH,
                      label: 'Supplier Street Address2' } ]
    }
    @EndUserText.label: 'Supplier Street Address2'
    SupplierStreetAddress2,
    @UI:{
        lineItem: [ { position: 8,
                      importance: #HIGH,
                      label: 'Supplier Address City' } ]
    }
    @EndUserText.label: 'Supplier Address City'
    SupplierAddressCity,
    @UI:{
        lineItem: [ { position: 9,
                      importance: #LOW,
                      label: 'Supplier Address Province/State' } ]
    }
    SupplierAddressProvinceState,
    @UI:{
        lineItem: [ { position: 10,
                      importance: #LOW,
                      label: 'Supplier Address Postal/Zip Code' } ]
    }
    SupplierAddressPostalZipCode,
    @UI:{
        lineItem: [ { position: 11,
                      importance: #LOW,
                      label: 'Remit To Name' } ]
    }
    RemitToName,
    @UI:{
        lineItem: [ { position: 12,
                      importance: #LOW,
                      label: 'Remit To Street/Box Address' } ]
    }
    RemitToStreetBoxAddress,
    @UI:{
        lineItem: [ { position: 13,
                      importance: #LOW,
                      label: 'Remit To Street/Box Address2' } ]
    }
    RemitToStreetBoxAddress2,
    @UI:{
        lineItem: [ { position: 14,
                      importance: #LOW,
                      label: 'Remit To City' } ]
    }
    RemitToCity,
    @UI:{
        lineItem: [ { position: 15,
                      importance: #LOW,
                      label: 'Remit To Province/State' } ]
    }
    RemitToProvinceState,
    @UI:{
        lineItem: [ { position: 16,
                      importance: #LOW,
                      label: 'Remit To Postal/Zip Code' } ]
    }
    RemitToPostalZipCode,
    @UI:{
        lineItem: [ { position: 17,
                      importance: #LOW,
                      label: 'BIill To Name' } ]
    }
    BIillToName,
    @UI:{
        lineItem: [ { position: 18,
                      importance: #LOW,
                      label: 'Bill To Street/Box Address' } ]
    }
    BillToStreetBoxAddress,
    @UI:{
        lineItem: [ { position: 19,
                      importance: #LOW,
                      label: 'Bill To Street/Box Address2' } ]
    }
    BillToStreetBoxAddress2,
    @UI:{
        lineItem: [ { position: 20,
                      importance: #LOW,
                      label: 'Bill To City' } ]
    }
    BillToCity,
    @UI:{
        lineItem: [ { position: 21,
                      importance: #LOW,
                      label: 'Bill To Province/State' } ]
    }
    BillToProvinceState,
    @UI:{
        lineItem: [ { position: 22,
                      importance: #LOW,
                      label: 'Bill To Postal/Zip Code' } ]
    }
    BillToPostalZipCode,
    
    @UI:{
        lineItem: [ { position: 23,
                      importance: #HIGH,
                      label: 'Ship To Name' } ],
        selectionField: [{ position: 5 }]
    }   
    @EndUserText.label: 'Ship-to Name'
    ShipToName,
    @UI:{
        lineItem: [ { position: 24,
                      importance: #HIGH,
                      label: 'Ship To Number' } ],
        selectionField: [{ position: 4 }]
    }
    @EndUserText.label: 'Ship-to'
    ShipToNumber,
    @UI:{
        lineItem: [ { position: 25,
                      importance: #LOW,
                      label: 'Ship To Street Address' } ]
    }
    ShipToStreetAddress,
    @UI:{
        lineItem: [ { position: 26,
                      importance: #LOW,
                      label: 'Ship To Street Address2' } ]
    }
    ShipToStreetAddress2,
    @UI:{
        lineItem: [ { position: 27,
                      importance: #LOW,
                      label: 'Ship To City' } ]
    }
    ShipToCity,
    @UI:{
        lineItem: [ { position: 28,
                      importance: #LOW,
                      label: 'Ship To Province/State' } ]
    }
    ShipToProvinceState,
    @UI:{
        lineItem: [ { position: 29,
                      importance: #LOW,
                      label: 'Ship To Postal/Zip Code' } ]
    }
    ShipToPostalZipCode,
    @UI:{
        lineItem: [ { position: 30,
                      importance: #LOW,
                      label: 'GST Registration Number' } ]
    }
    GSTRegistrationNumber,
    @UI:{
        lineItem: [ { position: 31,
                      importance: #LOW,
                      label: 'QST Registration Number' } ]
    }
    QSTRegistrationNumber,
    @UI:{
        lineItem: [ { position: 32,
                      importance: #LOW,
                      label: 'Tax Exemption Number' } ]
    }
    TaxExemptionNumber,
    @UI:{
        lineItem: [ { position: 33,
                      importance: #LOW,
                      label: 'Invoice Date' } ],
        selectionField: [{ position: 3 }]
    }
    @EndUserText.label: 'Invoice Date'
    InvoiceDate,
    @UI:{
        lineItem: [ { position: 35,
                      importance: #LOW,
                      label: 'Purchase Order Date' } ]
    }
    @EndUserText.label: 'Purchase Order Date'
    @UI.selectionField: [{exclude: true}]
    PurchaseOrderDate,
    @UI:{
        lineItem: [ { position: 36,
                      importance: #LOW,
                      label: 'PO#' } ]
    }
    PONumber,
    @UI:{
        lineItem: [ { position: 37,
                      importance: #LOW,
                      label: 'Ship Date' } ]
    }
    @EndUserText.label: 'Ship Date'
    @UI.selectionField: [{exclude: true}]
    ShipDate,
    @UI:{
        lineItem: [ { position: 38,
                      importance: #LOW,
                      label: 'Terms Description' } ]
    }
    TermsDescription,
    @UI:{
        lineItem: [ { position: 39,
                      importance: #LOW,
                      label: 'Invoice Net Due Date' } ]
    }
    @EndUserText.label: 'Invoice Net Due Date'
    InvoiceNetDueDate,
    @UI:{
        lineItem: [ { position: 40,
                      importance: #LOW,
                      label: 'Terms Discount Percent' } ]
    }
    TermsDiscountPercent,
    @UI:{
        lineItem: [ { position: 41,
                      importance: #LOW,
                      label: 'Terms Discount Amount' } ]
    }
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    virtual TermsDiscountAmount : abap.dec( 15, 2 ),
    @UI:{
        lineItem: [ { position: 42,
                      importance: #LOW,
                      label: 'Terms Discount Due Date' } ]
    }
    @EndUserText.label: 'Terms Discount Due Date'
    TermsDiscountDueDate,
    @UI:{
        lineItem: [ { position: 43,
                      importance: #LOW,
                      label: 'Delivery Instructions' } ]
    }
    DeliveryInstructions,
    @UI:{
        lineItem: [ { position: 44,
                      importance: #LOW,
                      label: 'Shipping Method of Payment' } ]
    }
    ShippingMethodofPayment,
    @UI:{
        lineItem: [ { position: 45,
                      importance: #LOW,
                      label: 'Currency' } ]
    }
    Currency,
    @UI:{
        lineItem: [ { position: 46,
                      importance: #LOW,
                      label: 'Internal Order Number' } ]
    }
    InternalOrderNumber,
    @UI.hidden: true
    SalesDocumentItem,
    @UI:{
        lineItem: [ { position: 47,
                      importance: #LOW,
                      label: 'Packing Slip Number' } ]
    }
    PackingSlipNumber,
    @UI:{
        lineItem: [ { position: 48,
                      importance: #LOW,
                      label: 'Bill of Lading Number' } ]
    }
    BillofLadingNumber,
    @UI:{
        lineItem: [ { position: 49,
                      importance: #LOW,
                      label: 'Credit Authorization Number' } ]
    }
    CreditAuthorizationNumber,
    @UI:{
        lineItem: [ { position: 50,
                      importance: #LOW,
                      label: 'Account Number' } ]
    }
    AccountNumber,
    @UI:{
        lineItem: [ { position: 51,
                      importance: #LOW,
                      label: 'Promotion Number' } ]
    }
    PromotionNumber,
    @UI:{
        lineItem: [ { position: 52,
                      importance: #LOW,
                      label: 'Carrier Tracking Number' } ]
    }
    CarrierTrackingNumber,
    @UI:{
        lineItem: [ { position: 53,
                      importance: #LOW,
                      label: 'Standard Carrier Alpha Code (SCAC)' } ]
    }
    StandardCarrierAlphaCodeSCAC,
    @UI:{
        lineItem: [ { position: 54,
                      importance: #LOW,
                      label: 'Project (Job) Number' } ]
    }
    ProjectJobNumber,
    @UI:{
        lineItem: [ { position: 55,
                      importance: #LOW,
                      label: 'Original Invoice Number' } ]
    }
    OriginalInvoiceNumber,
    @UI:{
        lineItem: [ { position: 56,
                      importance: #LOW,
                      label: 'Message or Notes' } ]
    }
    MessageorNotes,
    @UI:{
        lineItem: [ { position: 57,
                      importance: #LOW,
                      label: 'Freight Amount' } ]
    }
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
    virtual FreightAmount : abap.dec( 15, 2 ),
    @UI:{
        lineItem: [ { position: 58,
                      importance: #LOW,
                      label: 'Charge/Allowance 1 Description' } ]
    }
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
    virtual ChargeAllowance1Description : abap.sstring( 255 ),
    @UI:{
        lineItem: [ { position: 59,
                      importance: #LOW,
                      label: 'Charge/Allowance 1 Amount' } ]
    }
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
    virtual ChargeAllowance1Amount : abap.dec( 15, 2 ),
    @UI:{
        lineItem: [ { position: 60,
                      importance: #LOW,
                      label: 'Charge/Allowance 2 Description' } ]
    }
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
    virtual ChargeAllowance2Description : abap.sstring( 255 ),
    @UI:{
        lineItem: [ { position: 61,
                      importance: #LOW,
                      label: 'Charge/Allowance 2 Amount' } ]
    }
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
    virtual ChargeAllowance2Amount : abap.dec( 15, 2 ),
    @UI:{
        lineItem: [ { position: 62,
                      importance: #LOW,
                      label: 'GST Total Tax Amount' } ]
    }
    GSTTotalTaxAmount,
    @UI:{
        lineItem: [ { position: 63,
                      importance: #LOW,
                      label: 'HST Total Tax Amount' } ]
    }
    HSTTotalTaxAmount,
    @UI:{
        lineItem: [ { position: 64,
                      importance: #LOW,
                      label: 'PST Total Tax Amount' } ]
    }
    PSTTotalTaxAmount,
    @UI:{
        lineItem: [ { position: 65,
                      importance: #LOW,
                      label: 'Total Tax Amount' } ]
    }
    TotalTaxAmount,
//    @UI.hidden: true
//    TransactionCurrency,
    @UI:{
        lineItem: [ { position: 66,
                      importance: #LOW,
                      label: 'Invoice DocTotal' } ]
    }
    InvoiceDocTotal,
    @UI:{
        lineItem: [ { position: 67,
                      importance: #LOW,
                      label: 'Amount Subject To Terms Discount' } ]
    }
    AmountSubjectToTermsDiscount,
    @UI:{
        lineItem: [ { position: 68,
                      importance: #LOW,
                      label: 'Amount Payable After Terms Discount' } ]
    }
    AmountPayableAfterTermsDiscoun,
    @UI:{
        lineItem: [ { position: 70,
                      importance: #LOW,
                      label: 'Supplier Product Number' } ]
    }
    SupplierProductNumber,
    @UI:{
        lineItem: [ { position: 71,
                      importance: #LOW,
                      label: 'Buyer''s Item Number' } ]
    }
    BuyersItemNumber,
    @UI:{
        lineItem: [ { position: 72,
                      importance: #LOW,
                      label: 'Universal Product Code (UPC)' } ]
    }
    UniversalProductCodeUPC,
    @UI:{
        lineItem: [ { position: 73,
                      importance: #LOW,
                      label: 'Product Description' } ]
    }
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
    virtual ProductDescription : abap.sstring( 255 ),
    @UI:{
        lineItem: [ { position: 74,
                      importance: #LOW,
                      label: 'Pieces Shipped' } ]
    }
    PiecesShipped,
    @UI:{
        lineItem: [ { position: 75,
                      importance: #LOW,
                      label: 'Units Shipped' } ]
    }
    UnitsShipped,
    @UI:{
        lineItem: [ { position: 76,
                      importance: #LOW,
                      label: 'Unit of Measure Description' } ]
    }
    UnitofMeasureDescription,
    @UI:{
        lineItem: [ { position: 77,
                      importance: #LOW,
                      label: 'Original Order Quantity' } ]
    }
    OriginalOrderQuantity,
    @UI:{
        lineItem: [ { position: 78,
                      importance: #LOW,
                      label: 'Back Ordered Quantity' } ]
    }
    BackOrderedQuantity,
    @UI:{
        lineItem: [ { position: 79,
                      importance: #LOW,
                      label: 'Unit Price (Net or Gross)' } ]
    }
    UnitPriceNetorGross,
    @UI:{
        lineItem: [ { position: 80,
                      importance: #LOW,
                      label: 'Discount Percent' } ]
    }
    DiscountPercent,
    @UI:{
        lineItem: [ { position: 81,
                      importance: #LOW,
                      label: 'Extended Line Discount Amount' } ]
    }
    ExtendedLineDiscountAmount,
    @UI:{
        lineItem: [ { position: 82,
                      importance: #LOW,
                      label: 'Product Serial Number' } ]
    }
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_016'
    virtual ProductSerialNumber : abap.sstring( 255 ),
    @UI:{
        lineItem: [ { position: 83,
                      importance: #LOW,
                      label: 'Product Rebate Category' } ]
    }
    ProductRebateCategory,

    ChainAccount,

    NationalAccount,

    NoRebateOffered,

    Properties1,

    Properties2
}
