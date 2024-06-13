CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

    METHODS setBookingId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingId.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalPrice.
  ENDMETHOD.

  METHOD setBookingId.
  ENDMETHOD.

ENDCLASS.
