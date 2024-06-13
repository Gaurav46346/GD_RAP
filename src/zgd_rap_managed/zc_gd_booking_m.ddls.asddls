@EndUserText.label: 'Booking Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_GD_BOOKING_M  as projection on ZI_GD_BOOKING_M


{
    key BookingUuid,
    TravelUuid,
    TravelId,
    BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
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
    _Travel: redirected to parent ZC_GD_TRAVEL_M
}
