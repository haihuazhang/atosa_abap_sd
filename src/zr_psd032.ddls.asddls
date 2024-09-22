@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Confirmation Output Items Sum of Unit Price'
define root view entity ZR_PSD032 
    as select from I_SalesDocItemPricingElement
{
    key SalesDocument,
    key SalesDocumentItem,
    TransactionCurrency,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum(ConditionRateAmount) as ConditionRateAmount
}
where ConditionType = 'PPR0'
   and ConditionInactiveReason = ''
   
group by SalesDocument,SalesDocumentItem,TransactionCurrency
