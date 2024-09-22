@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD007'
@ObjectModel.semanticKey: ['UUID']
define root view entity ZC_TSD007
  provider contract transactional_query
  as projection on ZR_TSD007
{
  key UUID,
  SalesOrder,
  DeliveryDocument,
  BillingDocument,
  BaseFreight,
  LiftGate,
  LimitedAccess,
  OtherFees,
  OtherFeesDescription,
  BaseFreight1,
  LiftGate1,
  ResidentialFee1,
  LimitedAccess1,
  OtherFees1,
  OtherFeesDescription1,
  BaseFreight2,
  LiftGate2,
  ResidentialFee2,
  LimitedAccess2,
  OtherFees2,
  OtherFeesDescription2,
  ApInvoice1,
  ApInvoice2,
  FollowUpDate,
  FilingDate,
  DiscountCreditAmount,
  ContactPhoneNo,
  Note,
  ContactEmailAddress,
  ClaimStatus,
  ClaimOutcome,
  ClaimNumber,
  ClaimAttachments,
  ClaimAmount,
  CheckNumber,
  CheckDate,
  CheckAmount,
  CarrierName,
  CarrierContactName,
//  BusinessAddress,
//  FirstName,
//  LastName,
//  PhoneNumber,
//  BusinessName,
//  StoreNumber,
//  OriginalAtosaInvoiceNo,
  Waers,
  LocalLastChangedAt
  
}
