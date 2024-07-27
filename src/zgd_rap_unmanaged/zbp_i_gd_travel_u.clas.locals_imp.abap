CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ Travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Travel.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ Travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE Travel\_Booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD create.

    DATA: is_travel  TYPE /dmo/travel,
          es_travel  TYPE /dmo/travel,
          lt_message TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      is_travel = CORRESPONDING #( <entity> MAPPING FROM ENTITY USING CONTROL ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( is_travel )
        IMPORTING
          es_travel   = es_travel
          et_messages = lt_message.

      IF lt_message IS INITIAL.

        APPEND VALUE #( %cid = <entity>-%cid travelid = es_travel-travel_id ) TO mapped-travel.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.

    DATA:
      ls_travelx TYPE /dmo/s_travel_inx,
      lt_message TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      DATA(ls_travel) = CORRESPONDING /dmo/travel( <entity> MAPPING FROM ENTITY ).
      ls_travelx-travel_id = <entity>-TravelId.
      ls_travelx-_intx = CORRESPONDING zsrap_travel_x_gau( <entity> MAPPING FROM ENTITY USING CONTROL ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_travel )
          is_travelx  = ls_travelx
        IMPORTING
          et_messages = lt_message.

      IF lt_message IS INITIAL.
        APPEND VALUE #( travelid = ls_travel-travel_id ) TO mapped-travel.
      ELSE.
        APPEND VALUE #( travelid = ls_travel-travel_id ) TO failed-travel.
        APPEND VALUE #( %tky = <entity>-%tky
                        %msg = new_message( id = lt_message[ 1 ]-msgid
                                            number = lt_message[ 1 ]-msgno
                                            v1 = lt_message[ 1 ]-msgv1
                                            v2 = lt_message[ 1 ]-msgv2
                                            v3 = lt_message[ 1 ]-msgv3
                                            v4 = lt_message[ 1 ]-msgv4
                                            severity = CONV #( lt_message[ 1 ]-msgty )
                         )

         ) TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA lt_message TYPE /dmo/t_message.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <key>-TravelId
        IMPORTING
          et_messages  = lt_message.

      IF lt_message IS INITIAL.
      ELSE.
        APPEND VALUE #( %tky = <key>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <key>-%tky
                        %msg = new_message( id = lt_message[ 1 ]-msgid
                                            number = lt_message[ 1 ]-msgno
                                            v1 = lt_message[ 1 ]-msgv1
                                            v2 = lt_message[ 1 ]-msgv2
                                            v3 = lt_message[ 1 ]-msgv3
                                            v4 = lt_message[ 1 ]-msgv4
                                            severity = CONV #( lt_message[ 1 ]-msgty )
                         )

         ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
    DATA: ls_travel  TYPE /DMO/travel,
          lt_message TYPE /DMO/T_message.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <key>-TravelId
        IMPORTING
          es_travel    = ls_travel
          et_messages  = lt_message.

      IF   lt_message IS INITIAL.
        APPEND CORRESPONDING #( ls_travel MAPPING TO ENTITY  ) TO result.
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.

    TRY.
        DATA(lo_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = '/DMO/ETRAVEL' ).
      CATCH cx_abap_lock_failure INTO DATA(lx_lock_failure).
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      TRY.
          lo_lock->enqueue( it_parameter =  VALUE #( ( name = 'TRAVEL_ID' value = REF #( <key>-TravelId ) ) ) ).
        CATCH cx_abap_foreign_lock INTO DATA(lx_foreign_lock).
        CATCH cx_abap_lock_failure INTO lx_lock_failure.
          APPEND VALUE #( travelid = <key>-TravelId ) TO failed-travel.
          APPEND VALUE #( travelid = <key>-TravelId
                           %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Object is already locked !'

                                 ) ) TO reported-travel.
*  ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Booking.
    IF  sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD cba_Booking.
    DATA: ls_booking TYPE /dmo/booking,
          lt_booking TYPE /dmo/t_booking,
          lt_message TYPE /dmo/t_message.
    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<entity>).

      LOOP AT <entity>-%target ASSIGNING FIELD-SYMBOL(<target>).

        ls_booking =  CORRESPONDING #( <target> MAPPING FROM ENTITY ).
        ls_booking-booking_id = 10.

        CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
          EXPORTING
            is_travel   = VALUE /dmo/s_travel_in( travel_id = <entity>-TravelId )
            is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <entity>-TravelId )
            it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( ls_booking ) ) )
            it_bookingx = VALUE /dmo/t_booking_inx( ( booking_id = 10 action_code = 'C' ) )
          IMPORTING
            et_booking  = lt_booking
            et_messages = lt_message.

        IF lt_message IS INITIAL.
          APPEND VALUE #( %cid = <target>-%cid travelid = <entity>-travelid bookingid = lt_booking[ 1 ]-booking_id ) TO mapped-booking.
        ELSE.
          APPEND VALUE #( %cid = <target>-%cid travelid = <entity>-travelid ) TO failed-booking.
          APPEND VALUE #( %cid = <target>-%cid travelid = <entity>-travelid
                          %msg = new_message( id = lt_message[ 1 ]-msgid
                                              number = lt_message[ 1 ]-msgno
                                              v1 = lt_message[ 1 ]-msgv1
                                              v2 = lt_message[ 1 ]-msgv2
                                              v3 = lt_message[ 1 ]-msgv3
                                              v4 = lt_message[ 1 ]-msgv4
                                              severity = CONV #( lt_message[ 1 ]-msgty )
                           )

           ) TO reported-booking.

        ENDIF.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Booking.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Booking.

    METHODS read FOR READ
      IMPORTING keys FOR READ Booking RESULT result.

    METHODS rba_Travel FOR READ
      IMPORTING keys_rba FOR READ Booking\_Travel FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD update.

   DATA messages TYPE /dmo/t_message.
    DATA legacy_entity_in  TYPE /dmo/booking.
    DATA legacy_entity_x TYPE /dmo/s_booking_inx.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      legacy_entity_in = CORRESPONDING #( <entity> MAPPING FROM ENTITY ).

      legacy_entity_x-booking_id = <entity>-BookingID.
      legacy_entity_x-_intx      = CORRESPONDING zsrap_booking_x_gau( <entity> MAPPING FROM ENTITY ).
      legacy_entity_x-action_code = /dmo/if_flight_legacy=>action_code-update.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in(  travel_id = <entity>-travelid )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <entity>-travelid )
          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( legacy_entity_in ) ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( legacy_entity_x ) )
        IMPORTING
          et_messages = messages.

      IF messages IS INITIAL.

        APPEND VALUE #( travelid  = <entity>-travelid
                        bookingid = legacy_entity_in-booking_id ) TO mapped-booking.

      ELSE.

        "fill failed return structure for the framework
        APPEND VALUE #( travelid  = <entity>-travelid
                        bookingid = legacy_entity_in-booking_id ) TO failed-booking.
        "fill reported structure to be displayed on the UI

        LOOP AT messages INTO DATA(message).
          "fill reported structure to be displayed on the UI
          APPEND VALUE #( travelid  = <entity>-travelid
                          bookingid = legacy_entity_in-booking_id
                          %msg      = new_message( id       = message-msgid
                                                   number   = message-msgno
                                                   v1       = message-msgv1
                                                   v2       = message-msgv2
                                                   v3       = message-msgv3
                                                   v4       = message-msgv4
                                                   severity = CONV #( message-msgty ) )
          ) TO reported-booking.
        ENDLOOP.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_GD_TRAVEL_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_GD_TRAVEL_U IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
