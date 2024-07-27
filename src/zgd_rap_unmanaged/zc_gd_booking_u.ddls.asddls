@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking BO Projection View'
@Metadata.allowExtensions: true

define view entity ZC_GD_BOOKING_U
  as projection on ZI_GD_BOOKING_U
{
@Search.defaultSearchElement: true
  key TravelId,
@Search.defaultSearchElement: true
  key BookingId,
      BookingDate,
       @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer' , element: 'CustomerID' } }]
      CustomerId,
      _Customer.FirstName as CustomerName,
            @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Carrier' , element: 'AirlineID' } }]
      @ObjectModel.text.element: [ 'AirlineName' ]
      CarrierId,
      _Carrier.Name as AirlineName,
            @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Flight' , element: 'ConnectionID' } ,
                                        additionalBinding: [{ localElement: 'CarrierId' , element: 'AirlineID' },
                                                            { localElement: 'FlightDate' , element: 'FlightDate' },
                                                            { localElement: 'FlightPrice' , element: 'Price' },
                                                            { localElement: 'CurrencyCode' , element: 'CurrencyCode' }
                                        ]
                                        }]
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      /* Associations */
      _Carrier,
      _Connection,
      _Currency,
      _Customer,
      _Flight,
      _Travel : redirected to parent ZC_GD_TRAVEL_U
}
