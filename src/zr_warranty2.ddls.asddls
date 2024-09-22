@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SO only have Material Group'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY2
  as select from           I_SalesDocumentItem      as _SalesDocument
    left outer join        I_DeliveryDocumentItem   as _DeliveryDI         on  _DeliveryDI.ReferenceSDDocument     = _SalesDocument.SalesDocument
                                                                           and _DeliveryDI.ReferenceSDDocumentItem = _SalesDocument.SalesDocumentItem
    left outer join        I_DeliveryDocument       as _DeliveryD          on _DeliveryD.DeliveryDocument = _DeliveryDI.DeliveryDocument
    left outer join        I_BillingDocumentItem    as _BillingDI          on  _BillingDI.SalesDocument     = _SalesDocument.SalesDocument
                                                                           and _BillingDI.SalesDocumentItem = _SalesDocument.SalesDocumentItem
    left outer join        I_BillingDocument        as _BillingD           on  _BillingD.BillingDocument            =  _BillingDI.BillingDocument
                                                                           and _BillingD.BillingDocumentIsCancelled <> 'X'
                                                                           and _BillingD.CancelledBillingDocument   =  ''
  //    left outer join        I_JournalEntry          as _JournalEntryD      on _BillingD.AccountingDocument = _JournalEntryD.AccountingDocument
    left outer join        I_SalesDocument          as _SalesOrder         on _SalesOrder.SalesDocument = _SalesDocument.SalesDocument
    left outer join        ZR_WARRANTY9             as _SNDeliveryDocument on  _SNDeliveryDocument.DeliveryDocument     = _DeliveryDI.DeliveryDocument
                                                                           and _SNDeliveryDocument.DeliveryDocumentItem = _DeliveryDI.DeliveryDocumentItem
    left outer join        ztmm001                  as _ZTMM001            on _ZTMM001.zserialnumber = _SNDeliveryDocument.SerialNumber
    left outer join        I_SalesDocumentPartner   as _SDP_AG             on  _SDP_AG.SalesDocument   = _SalesDocument.SalesDocument
                                                                           and _SDP_AG.Customer        = _SalesDocument.SoldToParty
                                                                           and _SDP_AG.PartnerFunction = 'AG'
    left outer join        I_SalesDocumentPartner   as _SDP_WE             on  _SDP_WE.SalesDocument   = _SalesDocument.SalesDocument
                                                                           and _SDP_WE.Customer        = _SalesDocument.SoldToParty
                                                                           and _SDP_WE.PartnerFunction = 'WE'
    left outer join        I_JournalEntry           as _JournalEntry       on  _JournalEntry.AccountingDocument     = _BillingD.AccountingDocument
                                                                           and _JournalEntry.FiscalYear             = _BillingD.FiscalYear
                                                                           and _JournalEntry.CompanyCode            = _BillingD.CompanyCode
                                                                           and _JournalEntry.AccountingDocumentType = 'RV'
    inner join             ztsd001                  as _ZTSD001            on  _ZTSD001.product_group = _SalesDocument.MaterialGroup
                                                                           and _ZTSD001.product       = ''
    left outer join        I_Product                as _Product            on _Product.Product = _SalesDocument.Material
    left outer join        ZR_WARRANTY8             as _warranty8          on  _DeliveryDI.DeliveryDocument     = _warranty8.DeliveryDocument
                                                                           and _DeliveryDI.DeliveryDocumentItem = _warranty8.DeliveryDocumentItem
                                                                           and _SNDeliveryDocument.SerialNumber = _warranty8.SerialNumber
                                                                           and _BillingDI.BillingDocument       = _warranty8.BillingDocument
    left outer join        ZR_WARRANTY13            as _warranty13         on  _SalesDocument.SalesDocument     =  _warranty13.SalesDocument
                                                                           and _SalesDocument.SalesDocumentItem =  _warranty13.SalesDocumentItem
                                                                           and _warranty13.ConditionAmount      <> 0.00
    left outer to one join ZR_BILLINGSERIALNUMBER   as _ZRBillingSerialN   on  _ZRBillingSerialN.BillingDocument     = _SalesDocument.ReferenceSDDocument
                                                                           and _ZRBillingSerialN.BillingDocumentItem = _SalesDocument.ReferenceSDDocumentItem
                                                                           and _ZRBillingSerialN.SerialNumber        = _SNDeliveryDocument.SerialNumber
  //    association[1..*]      to ZR_BILLINGSERIALNUMBER     as _ZRBillingSerialN    on _ZRBillingSerialN.BillingDocument = _SalesDocument.ReferenceSDDocument
  //                                                                           and _ZRBillingSerialN.BillingDocumentItem = _SalesDocument.ReferenceSDDocumentItem
    left outer to one join ZR_DELIVERYSERIALNUMBER  as _ZRDeliverySerialN  on  _ZRDeliverySerialN.ReferenceSDDocument     = _SalesDocument.ReferenceSDDocument
                                                                           and _ZRDeliverySerialN.ReferenceSDDocumentItem = _SalesDocument.ReferenceSDDocumentItem
    left outer join        I_Equipment              as _EquipmentM         on  _EquipmentM.Material     = _SalesDocument.Material
                                                                           and _EquipmentM.SerialNumber = _SNDeliveryDocument.SerialNumber
    left outer join        I_Equipment              as _EquipmentY         on  _EquipmentY.Material     = _SalesDocument.YY1_WarrantyMaterial_SDI
                                                                           and _EquipmentY.SerialNumber = _SNDeliveryDocument.SerialNumber
    left outer join        I_SerialNumberSalesOrder as _SerialOrder        on  _SerialOrder.SalesOrder     = _SalesDocument.SalesDocument
                                                                           and _SerialOrder.SalesOrderItem = _SalesDocument.SalesDocumentItem
                                                                           and _SerialOrder.Material       = _SalesDocument.Material
    left outer join        I_BillingDocumentItem    as _BillingRef         on  _BillingRef.BillingDocument     = _SalesDocument.ReferenceSDDocument
                                                                           and _BillingRef.BillingDocumentItem = _SalesDocument.ReferenceSDDocumentItem
{
  key
               //  case
               //            when (_ZTSD001.z_warranty_type = 'EXTEND')
               //             then _SalesDocument.YY1_WarrantySerial_SDI
               //            else
               //            case
               //            when (_DeliveryDI.DeliveryDocument = '')
               //            then
               //            _SalesDocument.YY1_WarrantySerial_SDI
               //            else
            case
             when( _SalesDocument.SalesDocumentType = 'CBAR' and _SNDeliveryDocument.SerialNumber is initial)
             then
             _SerialOrder.SerialNumber
             when( _SalesDocument.SalesDocumentType = 'TA' and _SNDeliveryDocument.SerialNumber is initial and _SalesDocument.SalesDocumentItemCategory = 'CB2')
             then
             _SerialOrder.SerialNumber
             when( _SalesDocument.SalesDocumentType = 'GA2' )//and _SNDeliveryDocument.SerialNumber is initial)
             then
             _SerialOrder.SerialNumber
             else
            _SNDeliveryDocument.SerialNumber
               //            end
            end                                                          as SerialNumber1,
               //            end                               as SerialNumber1,
  key          _DeliveryDI.DeliveryDocument                              as SubsequentDocument1,
  key          _DeliveryDI.DeliveryDocumentItem                          as SubsequentDocumentItem1,
  key          _BillingDI.BillingDocument                                as SubsequentDocument2,
  key          _BillingDI.BillingDocumentItem                            as SubsequentDocumentItem2,
  key          case
                when ( _ZTSD001.z_warranty_defalut = 'X' and _Product.ProductType = 'FERT' )
                then _ZTSD001.z_warranty_type
                 when ( _ZTSD001.z_warranty_defalut <> 'X')
                  then
                  case
                   when ( _SalesDocument.Material = _ZTSD001.z_warranty_material )
                    then _ZTSD001.z_warranty_type
                  end
               end                                                       as ZWarrantyType,
  key          case
                when ( _ZTSD001.z_warranty_defalut = 'X' and _Product.ProductType = 'FERT' )
                 then _ZTSD001.z_warranty_material
                when ( _ZTSD001.z_warranty_defalut <> 'X')
                 then
                 case
                  when ( _SalesDocument.Material = _ZTSD001.z_warranty_material )
                   then _ZTSD001.z_warranty_material
                 end
                end                                                      as ZWarrantyMaterial,

               _SalesDocument.Material                                   as Material1,

               case
                 when ( _ZTSD001.z_warranty_type = 'STANDARD' )
                  then
                   case
                    when ( _SalesOrder.SalesDocumentType = 'TA' or _SalesOrder.SalesDocumentType = 'SD2' or _SalesOrder.SalesDocumentType = 'L2' )
                     then
                       _JournalEntry.PostingDate
                    when ( _SalesOrder.SalesDocumentType = 'G2' or _SalesOrder.SalesDocumentType = 'CBAR' or _SalesOrder.SalesDocumentType = 'GA2' )
                     then
                       _SalesOrder.CreationDate
                   end
                 when ( _ZTSD001.z_warranty_type = 'EXTEND' )
                 then
                   case
                   when ( _SalesOrder.SalesDocumentType = 'G2' or _SalesOrder.SalesDocumentType = 'CBAR' or _SalesOrder.SalesDocumentType = 'GA2' )
                   then
                      _SalesOrder.CreationDate
                   end
                end                                                      as ZWarrantyValidFrom,
               case
               when (_EquipmentM.YY1_ZMaulWrtValToDate_IEQ is not initial)
               then
               case
               when ($projection.ZWarrantyType = 'STANDARD')
               then
               _EquipmentM.YY1_ZMaulWrtValToDate_IEQ
               end
               when (_EquipmentY.YY1_ZMaulWrtValToDate_IEQ is not initial)
               then
               case
               when ($projection.ZWarrantyType = 'EXTEND')
               then
               _EquipmentY.YY1_ZMaulWrtValToDate_IEQ
               end
               else
               case
                when ( _SalesOrder.SalesDocumentType = 'TA' )
                then
                 case
                  when ( _ZTSD001.z_warranty_type = 'STANDARD' )
                   then
                     dats_add_days( _JournalEntry.PostingDate, _ZTSD001.z_warranty_months , 'FAIL' )
               //                   when ( _ZTSD001.z_warranty_type = 'EXTEND' )
               //                    then
               //                      dats_add_months( _SalesOrder.CreationDate ,_ZTSD001.z_warranty_months,'FAIL' )
                 end
               //                  when ( _ZTSD001.z_warranty_type = 'STANDARD' )
                 when ( _SalesOrder.SalesDocumentType = 'CBAR' or _SalesOrder.SalesDocumentType = 'G2' or _SalesOrder.SalesDocumentType = 'GA2' )
                  then
                    _SalesOrder.CreationDate
               //                  when (_SalesOrder.SalesDocumentType = 'L2')
               //                   then
               //                     dats_add_months( _JournalEntry.PostingDate, _ZTSD001.z_warranty_months , 'FAIL' )
               end
               end                                                       as ZWarrantyValidTo,
               case
               when ( $projection.ZWarrantyType = 'STANDARD')
               then
               case
               when (_EquipmentM.YY1_ZMaulWrtActStatus_IEQ is not initial)
               then
               'S'
               else
               cast(_warranty8.ZActive as abap.char(10))
               end
               when ( $projection.ZWarrantyType = 'EXTEND')
               then
               case
               when (_EquipmentY.YY1_ZMaulWrtActStatus_IEQ is not initial)
               then
               'S'
               else
               cast(_warranty8.ZActive as abap.char(10))
               end
               end                                                       as ZActive,
               case
                when _warranty8.ZActive = 'X' then 3
                when $projection.ZActive = 'S' then 1
                else 2
               end                                                       as active,
               _SalesDocument.SalesDocumentItemText                      as SalesDocumentItemText,
               _SalesDocument.SalesDocument                              as SalesDocument,
               _SalesDocument.SalesDocumentItem                          as SalesDocumentItem,
               //           _BillingDI.BillingDocument                                      as SubsequentDocument2,
               //           _BillingDI.BillingDocumentItem                                  as SubsequentDocumentItem2,
               //         @Semantics.unitOfMeasure: true
               _SalesDocument.OrderQuantityUnit                          as OrderQuantityUnit,
               @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
               case
               when (_SalesOrder.SalesDocumentType = 'TA' or _SalesOrder.SalesDocumentType = 'SD2' or _SalesOrder.SalesDocumentType = 'CBAR')
               then _SalesDocument.OrderQuantity
               when (_SalesOrder.SalesDocumentType = 'G2' or _SalesOrder.SalesDocumentType = 'L2' or _SalesOrder.SalesDocumentType = 'GA2' )
               then _SalesDocument.RequestedQuantity
               end                                                       as OrderQuantity,
               _SalesDocument.YY1_WarrantyMaterial_SDI                   as YY1_WarrantyMaterial_SDI,
               _SalesDocument.YY1_WarrantySerial_SDI                     as YY1_WarrantySerial_SDI,
               _SalesDocument.SalesDocumentType                          as SalesDocumentType,
               _SalesDocument.CreationDate                               as CreationDate,
               _SalesDocument.PurchaseOrderByCustomer                    as PurchaseOrderByCustomer,
               _SalesDocument.SoldToParty                                as SoldToParty,
               _SalesDocument.ShipToParty                                as ShipToParty,
               _SalesDocument.ReferenceSDDocument                        as ReferenceSDDocument,
               _SalesDocument.ReferenceSDDocumentItem                    as ReferenceSDDocumentItem,
               _SalesDocument.ReferenceSDDocumentCategory                as ReferenceSDDocumentCategory,
               _SalesDocument.StorageLocation                            as StorageLocation1,
               _SalesDocument.Plant                                      as Plant1,
               _ZTMM001.zoldserialnumber                                 as ZOldSerialNumber,
               _SDP_AG.FullName                                          as FullName1,
               _SDP_WE.FullName                                          as FullName2,

               _DeliveryDI.Material                                      as Material2,
               //         @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
               //         unit_conversion(quantity => _DeliveryDI.ActualDeliveryQuantity,
               //                        source_unit => _DeliveryDI.DeliveryQuantityUnit,
               //                        target_unit => _DeliveryDI.DeliveryQuantityUnit
               //                        ) as ActualDeliveryQuantity,
               //         @Semantics.unitOfMeasure: true
               //         cast('ST' as abap.unit) as DeliveryQuantityUnit,
               _DeliveryDI.DeliveryQuantityUnit                          as DeliveryQuantityUnit,
               @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
               _DeliveryDI.ActualDeliveryQuantity                        as ActualDeliveryQuantity,
               _DeliveryD.DeliveryDocumentType                           as DeliveryDocumentType,
               _DeliveryD.ActualGoodsMovementDate                        as ActualGoodsMovementDate,
               _DeliveryDI.StorageLocation                               as StorageLocation2,
               _BillingDI.Product                                        as Material3,
               //         @Semantics.unitOfMeasure: true
               _BillingDI.BillingQuantityUnit                            as BillingQuantityUnit,
               @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
               _BillingDI.BillingQuantity                                as BillingQuantity,
               @Semantics.amount.currencyCode: 'TransactionCurrency'
               _warranty13.ConditionAmount                               as ConditionAmount,
               _warranty13.TransactionCurrency                           as TransactionCurrency,
               _JournalEntry.PostingDate                                 as PostingDate,
               _BillingD.AccountingPostingStatus                         as AccountingPostingStatus,
               _BillingD.BillingDocumentType                             as BillingDocumentType,
               case
               when ( _SalesDocument.ReferenceSDDocumentCategory = 'M')
               then
               case
               when ( _ZRBillingSerialN.Material is not initial )
                then _ZRBillingSerialN.Material
               else
                _BillingRef.YY1_WarrantyMaterial_BDI
               end
               when ( _SalesDocument.ReferenceSDDocumentCategory = 'H')
               then
               case
               when ( _ZRDeliverySerialN.Material is not initial )
                then _ZRDeliverySerialN.Material
               else
                _ZRDeliverySerialN.YY1_WarrantyMaterial_DLI
               end
               end                                                       as Material4,
               case
               when ( _SalesDocument.ReferenceSDDocumentCategory = 'M')
               then
               case
               when ( _ZRBillingSerialN.SerialNumber is not initial )
                then _ZRBillingSerialN.SerialNumber
               else
                _BillingRef.YY1_WarrantySerial_BDI
               end
               when ( _SalesDocument.ReferenceSDDocumentCategory = 'H')
               then
               case
               when ( _ZRDeliverySerialN.SerialNumber is not initial )
                then _ZRDeliverySerialN.SerialNumber
               else
                _ZRDeliverySerialN.YY1_WarrantySerial_DLI
               end
               end                                                       as SerialNumber2,

               _ZTSD001.z_warranty_months                                as ZWarrantyMonths,
               concat(_SalesOrder.CreationDate,_SalesOrder.CreationTime) as CreationDateTime,
               _DeliveryDI.Plant                                         as Plant2,
               _SalesDocument.SalesOrganization                          as SalesOrganization,
               _SalesDocument.SalesDocumentItemCategory                  as SalesDocumentItemCategory,
               _SalesDocument.SalesDocumentRjcnReason                    as SalesDocumentRjcnReason,
               ''                                                        as Legacy,
               case
               when ( $projection.ZWarrantyType = 'STANDARD' )
               then
               _EquipmentM.Equipment
               when ( $projection.ZWarrantyType = 'EXTEND' )
               then
               _EquipmentY.Equipment
               end                                                       as Equipment,
               case
               when (_EquipmentM.YY1_ZMaulWrtActStatus_IEQ is not initial or _EquipmentM.YY1_ZMaulWrtValToDate_IEQ is not initial and $projection.ZWarrantyType = 'STANDARD')
               then
               'X'
               when(_EquipmentY.YY1_ZMaulWrtActStatus_IEQ is not initial or _EquipmentY.YY1_ZMaulWrtValToDate_IEQ is not initial and $projection.ZWarrantyType = 'EXTEND')
               then
               'X'
               end                                                       as ManualChanged

               //         _ZRBillingSerialN,
               //         _ZRDeliverySerialN

}
where
      _SalesDocument.MaterialGroup           <> ''
  and _SalesDocument.SalesDocumentRjcnReason =  ''
