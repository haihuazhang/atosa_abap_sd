@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD007'
define root view entity ZR_TSD007
  as select from ztsd007 as UDF
{
  key uuid as UUID,
  sales_order as SalesOrder,
  delivery_document as DeliveryDocument,
  billing_document as BillingDocument,
  @Semantics.amount.currencyCode: 'Waers'
  base_freight as BaseFreight,
  @Semantics.amount.currencyCode: 'Waers'
  lift_gate as LiftGate,
  @Semantics.amount.currencyCode: 'Waers'
  limited_access as LimitedAccess,
  @Semantics.amount.currencyCode: 'Waers'
  other_fees as OtherFees,
  other_fees_description as OtherFeesDescription,
  @Semantics.amount.currencyCode: 'Waers'
  base_freight_1 as BaseFreight1,
  @Semantics.amount.currencyCode: 'Waers'
  lift_gate_1 as LiftGate1,
  @Semantics.amount.currencyCode: 'Waers'
  residential_fee_1 as ResidentialFee1,
  @Semantics.amount.currencyCode: 'Waers'
  limited_access_1 as LimitedAccess1,
  @Semantics.amount.currencyCode: 'Waers'
  other_fees_1 as OtherFees1,
  other_fees_description_1 as OtherFeesDescription1,
  @Semantics.amount.currencyCode: 'Waers'
  base_freight_2 as BaseFreight2,
  @Semantics.amount.currencyCode: 'Waers'
  lift_gate_2 as LiftGate2,
  @Semantics.amount.currencyCode: 'Waers'
  residential_fee_2 as ResidentialFee2,
  @Semantics.amount.currencyCode: 'Waers'
  limited_access_2 as LimitedAccess2,
  @Semantics.amount.currencyCode: 'Waers'
  other_fees_2 as OtherFees2,
  other_fees_description_2 as OtherFeesDescription2,
  ap_invoice_1 as ApInvoice1,
  ap_invoice_2 as ApInvoice2,
  follow_up_date as FollowUpDate,
  filing_date as FilingDate,
  discount_credit_amount as DiscountCreditAmount,
  contact_phone_no as ContactPhoneNo,
  note as Note,
  contact_email_address as ContactEmailAddress,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZR_SSD031', element: 'value_low' }}]
  claim_status as ClaimStatus,
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZR_SSD032', element: 'value_low' }}]
  claim_outcome as ClaimOutcome,
  claim_number as ClaimNumber,
  claim_attachments as ClaimAttachments,
  @Semantics.amount.currencyCode: 'Waers'
  claim_amount as ClaimAmount,
  check_number as CheckNumber,
  check_date as CheckDate,
  @Semantics.amount.currencyCode: 'Waers'
  check_amount as CheckAmount,
  carrier_name as CarrierName,
  carrier_contact_name as CarrierContactName,
  business_address as BusinessAddress,
  first_name as FirstName,
  last_name as LastName,
  phone_number as PhoneNumber,
  business_name as BusinessName,
  store_number as StoreNumber,
  original_atosa_invoice_no as OriginalAtosaInvoiceNo,
  waers as Waers,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
