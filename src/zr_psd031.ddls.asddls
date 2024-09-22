@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Confirmation Output Items Sum of DIs'
define root view entity ZR_PSD031 
    as select from I_SalesDocItemPricingElement
{
    key SalesDocument,
    key SalesDocumentItem,
    TransactionCurrency,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum(ConditionAmount) as ConditionAmount
}
where (ConditionType = 'ZDRN'
   or ConditionType = 'ZDC7'
   or ConditionType = 'D100')
   and ConditionInactiveReason = ''
   
group by SalesDocument,SalesDocumentItem,TransactionCurrency
