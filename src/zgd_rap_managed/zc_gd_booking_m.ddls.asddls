@EndUserText.label: 'Booking Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_GD_BOOKING_M
  as projection on ZI_GD_BOOKING_M


{
  key BookingUuid,
      TravelUuid,
      TravelId,
      BookingId,
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
      _Carrier.Name       as AirlineName,
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
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Flight' , element: 'Price' } }]
      FlightPrice,
      CurrencyCode,
      CreatedBy,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Carrier,
      _Connection,
      _Customer,
      _Flight,
      _Travel : redirected to parent ZC_GD_TRAVEL_M
}
