@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface View'

define view entity ZI_GD_BOOKING as select from zgd_booking

association to parent ZI_GD_TRAVEL as _Travel on $projection.TravelUuid = _Travel.Traveluuid
association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
association [0..1] to /DMO/I_Carrier as _Carrier on $projection.CarrierId = _Carrier.AirlineID
association [0..1] to /DMO/I_Connection as _Connection on $projection.CarrierId = _Connection.AirlineID
                                                      and $projection.ConnectionId = _Connection.ConnectionID
association [0..1] to /DMO/I_Flight as _Flight on $projection.CarrierId = _Flight.AirlineID
                                                      and $projection.ConnectionId = _Flight.ConnectionID
                                                      and $projection.FlightDate = _Flight.FlightDate
{
    key booking_uuid as BookingUuid,
    travel_uuid as TravelUuid,
    travel_id as TravelId,
    booking_id as BookingId,
    booking_date as BookingDate,
    customer_id as CustomerId,
    carrier_id as CarrierId,
    connection_id as ConnectionId,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    _Travel, 
    _Customer,
    _Carrier,
    _Connection,
    _Flight
}
