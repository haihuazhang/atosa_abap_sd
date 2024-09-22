@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '111.01 AR Invoice List-All'
define root view entity ZR_SSD055
  as select from    I_BillingDocument            as _BillingDocument
    inner join      I_BillingDocumentItem        as _BillingDocumentItem on _BillingDocumentItem.BillingDocument = _BillingDocument.BillingDocument
    left outer join I_SalesDocItmSubsqntProcFlow as _SalesDocItmFlow     on  _SalesDocItmFlow.SubsequentDocument     = _BillingDocumentItem.BillingDocument
                                                                         and _SalesDocItmFlow.SubsequentDocumentItem = _BillingDocumentItem.BillingDocumentItem

  association [0..1] to I_SalesDocument     as _SalesDocument     on _SalesDocument.SalesDocument = $projection.SalesDocument
  association [0..1] to I_BusinessUserBasic as _BusinessUserBasic on _BusinessUserBasic.UserID = $projection.createdbyuser

{
  key _BillingDocument.BillingDocument,
  key _BillingDocumentItem.BillingDocumentItem,

      _SalesDocItmFlow.SalesDocument,
      _SalesDocItmFlow.SalesDocumentItem,

      _SalesDocument.CreatedByUser,
      _SalesDocument.PurchaseOrderByCustomer,
      _SalesDocument.YY1_BusinessName_SDH,

      /* association */
      _BusinessUserBasic
}
where
  (
    (
         _SalesDocItmFlow.SubsequentDocumentCategory = 'M'
      or _SalesDocItmFlow.SubsequentDocumentCategory = 'N'
    )
    and(
         _SalesDocItmFlow.SDDocumentCategory         = 'C'
      or _SalesDocItmFlow.SDDocumentCategory         = 'I'
      or _SalesDocItmFlow.SDDocumentCategory         = 'L'
    )
  )
  or(
    (
         _SalesDocItmFlow.SubsequentDocumentCategory = 'O'
      or _SalesDocItmFlow.SubsequentDocumentCategory = 'S'
    )
    and(
         _SalesDocItmFlow.SDDocumentCategory         = 'K'
      or _SalesDocItmFlow.SDDocumentCategory         = 'C'
    )
  )
  or(
         _SalesDocItmFlow.SubsequentDocumentCategory = 'P'
    and  _SalesDocItmFlow.SDDocumentCategory         = 'L'
  )
