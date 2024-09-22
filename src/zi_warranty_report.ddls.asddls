@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for Warranty Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define view entity ZI_WARRANTY_REPORT 
  as 
//  select from ZR_WARRANTY1                            
//{
//  key    SerialNumber1,
//  key    SubsequentDocument1,
//  key    SubsequentDocumentItem1,
//  key    ZWarrantyType,
//  key    ZWarrantyMaterial,
//  key    SubsequentDocument2,
//  key    SubsequentDocumentItem2,
//         Material1,
//         ZWarrantyValidFrom,
//         ZWarrantyValidTo,
//         ZActive,
//         active,
//         SalesDocumentItemText,
//         SalesDocument,
//         SalesDocumentItem,
////         @Semantics.unitOfMeasure: true
//         OrderQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
//         OrderQuantity,
//         YY1_WarrantyMaterial_SDI,
//         YY1_WarrantySerial_SDI,
//         SalesDocumentType,
//         CreationDate,
//         PurchaseOrderByCustomer,
//         SoldToParty,
//         ShipToParty,
//         ReferenceSDDocument,
//         ReferenceSDDocumentItem,
//         ReferenceSDDocumentCategory,
//         ZOldSerialNumber,
//         FullName1,
//         FullName2,
//         Material2,
//         @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
//         ActualDeliveryQuantity,
////         @Semantics.unitOfMeasure: true
////         cast('PC' as abap.unit) as DeliveryQuantityUnit,
//         DeliveryQuantityUnit,
//         DeliveryDocumentType,
//         ActualGoodsMovementDate,         
//         Material3,
////         @Semantics.unitOfMeasure: true
//         BillingQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
//         BillingQuantity,
//         @Semantics.amount.currencyCode: 'TransactionCurrency'
//         ConditionAmount,
//         TransactionCurrency,
//         PostingDate,
//         AccountingPostingStatus,
//         BillingDocumentType,
//         Material4,
//         SerialNumber2,
//         ZWarrantyMonths,
////         CreationDateTime,
//         Plant,
//         SalesOrganization,
//         SalesDocumentItemCategory,
//         SalesDocumentRjcnReason,
//         Legacy,
//         Equipment
//}
//union
  select from ZR_WARRANTY2    
  left outer join ZR_WARRANTY3 as _warrantywithmat on ZR_WARRANTY2.SerialNumber1 =  _warrantywithmat.SerialNumber1
                                                   and ZR_WARRANTY2.SubsequentDocument1 = _warrantywithmat.SubsequentDocument1
                                                   and ZR_WARRANTY2.SubsequentDocumentItem1 = _warrantywithmat.SubsequentDocumentItem1
                                                   and ZR_WARRANTY2.ZWarrantyType = _warrantywithmat.ZWarrantyType
                                                   and ZR_WARRANTY2.ZWarrantyMaterial = _warrantywithmat.ZWarrantyMaterial
                                                   and ZR_WARRANTY2.SubsequentDocument2 = _warrantywithmat.SubsequentDocument2
                                                   and ZR_WARRANTY2.SubsequentDocumentItem2 = _warrantywithmat.SubsequentDocumentItem2
                       
{
  key    ZR_WARRANTY2.SerialNumber1,
  key    ZR_WARRANTY2.SubsequentDocument1,
  key    ZR_WARRANTY2.SubsequentDocumentItem1,
  key    ZR_WARRANTY2.ZWarrantyType,
  key    ZR_WARRANTY2.ZWarrantyMaterial,
  key    ZR_WARRANTY2.SubsequentDocument2,
  key    ZR_WARRANTY2.SubsequentDocumentItem2,
         ZR_WARRANTY2.Material1,
         ZR_WARRANTY2.ZWarrantyValidFrom,
         ZR_WARRANTY2.ZWarrantyValidTo,
         ZR_WARRANTY2.ZActive,
         ZR_WARRANTY2.active,
         ZR_WARRANTY2.SalesDocumentItemText,
         ZR_WARRANTY2.SalesDocument,
         ZR_WARRANTY2.SalesDocumentItem,
//         @Semantics.unitOfMeasure: true
         ZR_WARRANTY2.OrderQuantityUnit,
         @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
         ZR_WARRANTY2.OrderQuantity,
         ZR_WARRANTY2.YY1_WarrantyMaterial_SDI,
         ZR_WARRANTY2.YY1_WarrantySerial_SDI,
         ZR_WARRANTY2.SalesDocumentType,
         ZR_WARRANTY2.CreationDate,
         ZR_WARRANTY2.PurchaseOrderByCustomer,
         ZR_WARRANTY2.SoldToParty,
         ZR_WARRANTY2.ShipToParty,
         ZR_WARRANTY2.ReferenceSDDocument,
         ZR_WARRANTY2.ReferenceSDDocumentItem,
         ZR_WARRANTY2.ReferenceSDDocumentCategory,
         ZR_WARRANTY2.StorageLocation1,
         ZR_WARRANTY2.Plant1,
         ZR_WARRANTY2.ZOldSerialNumber,
         ZR_WARRANTY2.FullName1,
         ZR_WARRANTY2.FullName2,
         ZR_WARRANTY2.Material2,
         @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
         ZR_WARRANTY2.ActualDeliveryQuantity,
//         @Semantics.unitOfMeasure: true
         ZR_WARRANTY2.DeliveryQuantityUnit,
         ZR_WARRANTY2.DeliveryDocumentType,
         ZR_WARRANTY2.ActualGoodsMovementDate,
         ZR_WARRANTY2.StorageLocation2,
         ZR_WARRANTY2.Material3,
//         @Semantics.unitOfMeasure: true
         ZR_WARRANTY2.BillingQuantityUnit,
         @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
         ZR_WARRANTY2.BillingQuantity,
         @Semantics.amount.currencyCode: 'TransactionCurrency'
         ZR_WARRANTY2.ConditionAmount,
         ZR_WARRANTY2.TransactionCurrency,
         ZR_WARRANTY2.PostingDate,
         ZR_WARRANTY2.AccountingPostingStatus,
         ZR_WARRANTY2.BillingDocumentType,
         ZR_WARRANTY2.Material4,
         ZR_WARRANTY2.SerialNumber2,
         ZR_WARRANTY2.ZWarrantyMonths,
//         CreationDateTime,
         ZR_WARRANTY2.Plant2,
         ZR_WARRANTY2.SalesOrganization,
         ZR_WARRANTY2.SalesDocumentItemCategory,
         ZR_WARRANTY2.SalesDocumentRjcnReason,
         ZR_WARRANTY2.Legacy,
         ZR_WARRANTY2.CreationDateTime,
         ZR_WARRANTY2.Equipment,
         ZR_WARRANTY2.ManualChanged
}
where _warrantywithmat.SerialNumber1 is null
union
  select from ZR_WARRANTY3                            
{
  key    SerialNumber1,
  key    SubsequentDocument1,
  key    SubsequentDocumentItem1,
  key    ZWarrantyType,
  key    ZWarrantyMaterial,
  key    SubsequentDocument2,
  key    SubsequentDocumentItem2,
         Material1,
         ZWarrantyValidFrom,
         ZWarrantyValidTo,
         ZActive,
         active,
         SalesDocumentItemText,
         SalesDocument,
         SalesDocumentItem,
//         @Semantics.unitOfMeasure: true
         OrderQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
         OrderQuantity,
         YY1_WarrantyMaterial_SDI,
         YY1_WarrantySerial_SDI,
         SalesDocumentType,
         CreationDate,
         PurchaseOrderByCustomer,
         SoldToParty,
         ShipToParty,
         ReferenceSDDocument,
         ReferenceSDDocumentItem,
         ReferenceSDDocumentCategory,
         StorageLocation1,
         Plant1,
         ZOldSerialNumber,
         FullName1,
         FullName2,
         Material2,
//         @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
         ActualDeliveryQuantity,
//         @Semantics.unitOfMeasure: true
         DeliveryQuantityUnit,
         DeliveryDocumentType,
         ActualGoodsMovementDate,
         StorageLocation2,
         Material3,
//         @Semantics.unitOfMeasure: true
         BillingQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
         BillingQuantity,
//         @Semantics.amount.currencyCode: 'TransactionCurrency'
         ConditionAmount,
         TransactionCurrency,
         PostingDate,
         AccountingPostingStatus,
         BillingDocumentType,
         Material4,
         SerialNumber2,
         ZWarrantyMonths,
//         CreationDateTime,
         Plant2,
         SalesOrganization,
         SalesDocumentItemCategory,
         SalesDocumentRjcnReason,
         Legacy,
         CreationDateTime,
         Equipment,
         ManualChanged
}
union
  select from ZR_WARRANTY4   
  left outer join ZR_WARRANTY3 as _warrantywithmat on ZR_WARRANTY4.SerialNumber1 =  _warrantywithmat.SerialNumber1
                                                   and ZR_WARRANTY4.SubsequentDocument1 = _warrantywithmat.SubsequentDocument1
                                                   and ZR_WARRANTY4.SubsequentDocumentItem1 = _warrantywithmat.SubsequentDocumentItem1
                                                   and ZR_WARRANTY4.ZWarrantyType = _warrantywithmat.ZWarrantyType
                                                   and ZR_WARRANTY4.ZWarrantyMaterial = _warrantywithmat.ZWarrantyMaterial
                                                   and ZR_WARRANTY4.SubsequentDocument2 = _warrantywithmat.SubsequentDocument2
                                                   and ZR_WARRANTY4.SubsequentDocumentItem2 = _warrantywithmat.SubsequentDocumentItem2  
  left outer join ZR_WARRANTY2 as _warrantywithmat1 on ZR_WARRANTY4.SerialNumber1 =  _warrantywithmat1.SerialNumber1
                                                   and ZR_WARRANTY4.SubsequentDocument1 = _warrantywithmat1.SubsequentDocument1
                                                   and ZR_WARRANTY4.SubsequentDocumentItem1 = _warrantywithmat1.SubsequentDocumentItem1
                                                   and ZR_WARRANTY4.ZWarrantyType = _warrantywithmat1.ZWarrantyType
                                                   and ZR_WARRANTY4.ZWarrantyMaterial = _warrantywithmat1.ZWarrantyMaterial
                                                   and ZR_WARRANTY4.SubsequentDocument2 = _warrantywithmat1.SubsequentDocument2
                                                   and ZR_WARRANTY4.SubsequentDocumentItem2 = _warrantywithmat1.SubsequentDocumentItem2 
                                                                          
{
  key    ZR_WARRANTY4.SerialNumber1,
  key    ZR_WARRANTY4.SubsequentDocument1,
  key    ZR_WARRANTY4.SubsequentDocumentItem1,
  key    ZR_WARRANTY4.ZWarrantyType,
  key    ZR_WARRANTY4.ZWarrantyMaterial,
  key    ZR_WARRANTY4.SubsequentDocument2,
  key    ZR_WARRANTY4.SubsequentDocumentItem2,
         ZR_WARRANTY4.Material1,
         ZR_WARRANTY4.ZWarrantyValidFrom,
         ZR_WARRANTY4.ZWarrantyValidTo,
         ZR_WARRANTY4.ZActive,
         ZR_WARRANTY4.active,
         ZR_WARRANTY4.SalesDocumentItemText,
         ZR_WARRANTY4.SalesDocument,
         ZR_WARRANTY4.SalesDocumentItem,
//         @Semantics.unitOfMeasure: true
         ZR_WARRANTY4.OrderQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
         ZR_WARRANTY4.OrderQuantity,
         ZR_WARRANTY4.YY1_WarrantyMaterial_SDI,
         ZR_WARRANTY4.YY1_WarrantySerial_SDI,
         ZR_WARRANTY4.SalesDocumentType,
         ZR_WARRANTY4.CreationDate,
         ZR_WARRANTY4.PurchaseOrderByCustomer,
         ZR_WARRANTY4.SoldToParty,
         ZR_WARRANTY4.ShipToParty,
         ZR_WARRANTY4.ReferenceSDDocument,
         ZR_WARRANTY4.ReferenceSDDocumentItem,
         ZR_WARRANTY4.ReferenceSDDocumentCategory,
         ZR_WARRANTY4.StorageLocation1,
         ZR_WARRANTY4.Plant1,
         ZR_WARRANTY4.ZOldSerialNumber,
         ZR_WARRANTY4.FullName1,
         ZR_WARRANTY4.FullName2,
         ZR_WARRANTY4.Material2,
 //        @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
         ZR_WARRANTY4.ActualDeliveryQuantity,
//         @Semantics.unitOfMeasure: true
         ZR_WARRANTY4.DeliveryQuantityUnit,
         ZR_WARRANTY4.DeliveryDocumentType,
         ZR_WARRANTY4.ActualGoodsMovementDate,
         ZR_WARRANTY4.StorageLocation2,
         ZR_WARRANTY4.Material3,
//         @Semantics.unitOfMeasure: true
         ZR_WARRANTY4.BillingQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
         ZR_WARRANTY4.BillingQuantity,
//         @Semantics.amount.currencyCode: 'TransactionCurrency'
         ZR_WARRANTY4.ConditionAmount,
         ZR_WARRANTY4.TransactionCurrency,
         ZR_WARRANTY4.PostingDate,
         ZR_WARRANTY4.AccountingPostingStatus,
         ZR_WARRANTY4.BillingDocumentType,
         ZR_WARRANTY4.Material4,
         ZR_WARRANTY4.SerialNumber2,
         ZR_WARRANTY4.ZWarrantyMonths,
//         CreationDateTime,
         ZR_WARRANTY4.Plant2,
         ZR_WARRANTY4.SalesOrganization,
         ZR_WARRANTY4.SalesDocumentItemCategory,
         ZR_WARRANTY4.SalesDocumentRjcnReason,
         ZR_WARRANTY4.Legacy,
         ZR_WARRANTY4.CreationDateTime,
         ZR_WARRANTY4.Equipment,
         ZR_WARRANTY4.ManualChanged
}
where _warrantywithmat.SerialNumber1 is null
and _warrantywithmat1.SerialNumber1 is null
union
  select from ZR_WARRANTY14                            
{
  key    Serialnumber1 as SerialNumber1,
  key    Subsequentdocument1 as SubsequentDocument1,
  key    Subsequentdocumentitem1 as SubsequentDocumentitem1,
  key    Zwarrantytype as ZWarrantyType,
  key    Zwarrantymaterial as ZWarrantyMaterial,
  key    Subsequentdocument2 as SubsequentDocument2,
  key    Subsequentdocumentitem2 as SubsequentDocumentitem2,
         Material1,
         Zwarrantyvalidfrom as ZwarrantyValidFrom,
         Zwarrantyvalidto as ZwarrantyValidTo,
         Zactive as ZActive,
         active,
         Salesdocumentitemtext as SalesDocumentItemText,
         Salesdocument as SalesDocument,
         Salesdocumentitem as SalesDocumentItem,
//         @Semantics.unitOfMeasure: true
         Orderquantityunit as OrderQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
         Orderquantity as OrderQuantity,
         Yy1_Warrantymaterial_Sdi as YY1_WarrantyMaterial_SDI,
         Yy1_Warrantyserial_Sdi as YY1_WarrantySerial_SDI,
         Salesdocumenttype as SalesDocumentType,
         Creationdate as CreationDate,
         Purchaseorderbycustomer as PurchaseOrderByCustomer,
         Soldtoparty as SoldToParty,
         Shiptoparty as ShipToParty,
         Referencesddocument as ReferenceSDDocument,
         Referencesddocumentitem as ReferenceSDDocumentItem,
         Referencesddocumentcategory as ReferenceSDDocumentCategory,
         StorageLocation1,
         Plant1,
         Zoldserialnumber as ZOldSerialNumber,
         Fullname1 as FullName1,
         Fullname2 as FullName2,
         Material2,
 //        @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
         Actualdeliveryquantity as ActualDeliveryQuantity,
//         @Semantics.unitOfMeasure: true
         Deliveryquantityunit as DeliveryQuantityUnit,
         Deliverydocumenttype as DeliveryDocumentType,
         Actualgoodsmovementdate as ActualGoodsMovementDate,
         StorageLocation2,
         Material3,
//         @Semantics.unitOfMeasure: true
         Billingquantityunit as BillingQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
         BillingQuantity,
//         @Semantics.amount.currencyCode: 'TransactionCurrency'
         Conditionamount as ConditionAmount,
         Transactioncurrency as TransactionCurrency,
         Postingdate as PostingDate,
         Accountingpostingstatus as AccountingPostingStatus,
         Billingdocumenttype as BillingDocumentType,
         Material4,
         Serialnumber2 as SerialNumber2,
         Zwarrantymonths as ZWarrantyMonths,
//         CreationDateTime,
         Plant2,
         Salesorganization as SalesOrganization,
         Salesdocumentitemcategory as SalesDocumentItemCategory,
         Salesdocumentrjcnreason as SalesDocumentRjcnReason,
         Legacy,
         CreationDateTime,
         Equipment,
         ManualChanged
}
union
select from ZR_WARRANTY15                            
{
  key    SerialNumber1,
  key    SubsequentDocument1,
  key    SubsequentDocumentItem1,
  key    ZWarrantyType,
  key    ZWarrantyMaterial,
  key    SubsequentDocument2,
  key    SubsequentDocumentItem2,
         Material1,
         ZWarrantyValidFrom,
         ZWarrantyValidTo,
         ZActive,
         active,
         SalesDocumentItemText,
         SalesDocument,
         SalesDocumentItem,
//         @Semantics.unitOfMeasure: true
         OrderQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
         OrderQuantity,
         YY1_WarrantyMaterial_SDI,
         YY1_WarrantySerial_SDI,
         SalesDocumentType,
         CreationDate,
         PurchaseOrderByCustomer,
         SoldToParty,
         ShipToParty,
         ReferenceSDDocument,
         ReferenceSDDocumentItem,
         ReferenceSDDocumentCategory,
         StorageLocation1,
         Plant1,
         ZOldSerialNumber,
         FullName1,
         FullName2,
         Material2,
//         @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
         ActualDeliveryQuantity,
//         @Semantics.unitOfMeasure: true
         DeliveryQuantityUnit,
         DeliveryDocumentType,
         ActualGoodsMovementDate,
         StorageLocation2,
         Material3,
//         @Semantics.unitOfMeasure: true
         BillingQuantityUnit,
//         @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
         BillingQuantity,
//         @Semantics.amount.currencyCode: 'TransactionCurrency'
         ConditionAmount,
         TransactionCurrency,
         PostingDate,
         AccountingPostingStatus,
         BillingDocumentType,
         Material4,
         SerialNumber2,
         ZWarrantyMonths,
//         CreationDateTime,
         Plant2,
         SalesOrganization,
         SalesDocumentItemCategory,
         SalesDocumentRjcnReason,
         Legacy,
         CreationDateTime,
         Equipment,
         ManualChanged
}
     
     
  
