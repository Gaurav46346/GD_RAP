CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingId.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalPrice.

    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Booking BY \_Travel
    FIELDS ( Traveluuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    MODIFY ENTITIES OF zi_gd_travel_m IN LOCAL MODE
     ENTITY Travel
     EXECUTE recalculatePrice
     FROM CORRESPONDING #( Travel ).


  ENDMETHOD.

  METHOD setBookingId.
  ENDMETHOD.

ENDCLASS.
