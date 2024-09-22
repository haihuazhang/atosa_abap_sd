@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'print CDS of  Pick List(SalesDocument)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PSD007 
as select from I_OutboundDelivery as _OutboundDelivery
left outer join I_SalesDocItmSubsqntProcFlow as _SalesDoc          on _OutboundDelivery.OutboundDelivery = _SalesDoc.SubsequentDocument
//                                                                       and(
//                                                                         _SalesDoc.SalesDocumentItem         = '000010'
//                                                                         or _SalesDoc.SalesDocumentItem      = '000001'
//                                                                       )
                                                                       and ( _SalesDoc.SDDocumentCategory       = 'C' or _SalesDoc.SDDocumentCategory       = 'I' ) 
{
    key _OutboundDelivery.OutboundDelivery as DeliveryDocument,
        max(_SalesDoc.SalesDocument) as SalesDocument
} group by _OutboundDelivery.OutboundDelivery
union
select from I_CustomerReturnDelivery as _OutboundDelivery
left outer join I_SalesDocItmSubsqntProcFlow as _SalesDoc          on _OutboundDelivery.CustomerReturnDelivery = _SalesDoc.SubsequentDocument
//                                                                       and(
//                                                                         _SalesDoc.SalesDocumentItem         = '000010'
//                                                                         or _SalesDoc.SalesDocumentItem      = '000001'
//                                                                       )
                                                                       and _SalesDoc.SDDocumentCategory       = 'H'
{
    key _OutboundDelivery.CustomerReturnDelivery as DeliveryDocument,
        max(_SalesDoc.SalesDocument) as SalesDocument
}
group by _OutboundDelivery.CustomerReturnDelivery
