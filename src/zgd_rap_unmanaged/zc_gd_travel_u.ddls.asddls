@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel BO Projection'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_GD_TRAVEL_U
  provider contract transactional_query
  as projection on ZI_GD_TRAVEL_U
{
      @Search.defaultSearchElement: true
  key TravelId,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency' , element: 'AgencyID' } }]
      AgencyId,
      _Agency.Name        as AgencyName,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer' , element: 'CustomerID' } }]
      CustomerId,
      _Customer.FirstName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency' , element: 'Currency' } }]
      CurrencyCode,
      @Search.defaultSearchElement: true
      Description,
      Status,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_GD_BOOKING_U,
      _Currency,
      _Customer
}
