@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel BO Interface'
define root view entity ZI_GD_TRAVEL_U
  as select from /dmo/travel
  composition [0..*] of ZI_GD_BOOKING_U as _Booking 
  association [1]    to /DMO/I_Agency   as _Agency   on $projection.AgencyId = _Agency.AgencyID
  association [1]    to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
  association [0..1] to I_Currency      as _Currency on $projection.CurrencyCode = _Currency.Currency
{
  key travel_id     as TravelId,
      agency_id     as AgencyId,
      customer_id   as CustomerId,
      begin_date    as BeginDate,
      end_date      as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee   as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price   as TotalPrice,
      currency_code as CurrencyCode,
      description   as Description,
      status        as Status,
      @Semantics.user.createdBy: true
      createdby     as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat     as Createdat,
      @Semantics.user.lastChangedBy: true
      lastchangedby as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat as Lastchangedat,
      //Associations
      _Agency,
      _Customer,
      _Currency,
      _Booking
}
