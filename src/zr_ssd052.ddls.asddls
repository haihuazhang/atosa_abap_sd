@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Situation Handling - Remind Shipping '
define root view entity ZR_SSD052
  as select distinct from I_SalesDocument     as _SalesDocument
    left outer join       I_SalesDocumentItem as _SalesDocumentItem on _SalesDocumentItem.SalesDocument = _SalesDocument.SalesDocument
{
  key _SalesDocument.SalesDocument,
      _SalesDocument.CreatedByUser,
      _SalesDocument.RequestedDeliveryDate,

      dats_days_between( $session.system_date, _SalesDocument.RequestedDeliveryDate ) as IntervalDays
}
where
  (
       _SalesDocument.SalesDocumentType           =  'TA'
    or _SalesDocument.SalesDocumentType           =  'SD2'
  )
  and(
       _SalesDocument.OverallDeliveryStatus       <> 'C'
    or _SalesDocument.OverallDeliveryStatus       =  ''
  )
  and  _SalesDocumentItem.SalesDocumentRjcnReason =  ''
