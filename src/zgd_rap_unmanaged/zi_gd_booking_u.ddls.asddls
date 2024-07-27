@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking BO Interface View'

define view entity ZI_GD_BOOKING_U
  as select from /dmo/booking
  association to parent ZI_GD_TRAVEL_U as _Travel on $projection.TravelId = _Travel.TravelId
  association [1]    to /DMO/I_Customer   as _Customer   on  $projection.CustomerId = _Customer.CustomerID
  association [0..1] to /DMO/I_Carrier    as _Carrier    on  $projection.CarrierId = _Carrier.AirlineID
  association [0..1] to /DMO/I_Connection as _Connection on  $projection.CarrierId    = _Connection.AirlineID
                                                         and $projection.ConnectionId = _Connection.ConnectionID
  association [0..1] to /DMO/I_Flight     as _Flight     on  $projection.CarrierId    = _Flight.AirlineID
                                                         and $projection.ConnectionId = _Flight.ConnectionID
                                                         and $projection.FlightDate   = _Flight.FlightDate
  association [0..1] to I_Currency        as _Currency   on  $projection.CurrencyCode = _Currency.Currency
{
  key travel_id     as TravelId,
  key booking_id    as BookingId,
      booking_date  as BookingDate,
      customer_id   as CustomerId,
      carrier_id    as CarrierId,
      connection_id as ConnectionId,
      flight_date   as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price  as FlightPrice,
      currency_code as CurrencyCode,
      //Associations
      _Customer,
      _Carrier,
      _Connection,
      _Flight,
      _Currency,
      _Travel
}
