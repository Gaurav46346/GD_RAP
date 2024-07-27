CLASS lsc_zi_gd_travel_m DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS cleanup_finalize REDEFINITION.
    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_gd_travel_m IMPLEMENTATION.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD save_modified.

    DATA: lt_log_travel TYPE STANDARD TABLE OF /dmo/log_travel.
    DATA: lt_log_final TYPE STANDARD TABLE OF /dmo/log_travel.
    IF update-travel IS NOT INITIAL.
      READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
      ENTITY Travel
      FIELDS ( TravelId )
      WITH CORRESPONDING #( update-travel )
      RESULT DATA(travels).


      lt_log_travel = CORRESPONDING #( travels MAPPING travel_id = TravelId ).

      LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<travel>).

        ASSIGN lt_log_travel[ travel_id = travels[ Traveluuid = <travel>-Traveluuid ]-TravelId ]
        TO FIELD-SYMBOL(<ls_log_travel>).
        IF <travel>-%control-AgencyId = '01'.
          <ls_log_travel>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
          <ls_log_travel>-changed_field_name = 'agency_id'.
          <ls_log_travel>-changed_value = <travel>-AgencyId.
          GET TIME STAMP FIELD <ls_log_travel>-created_at.
          <ls_log_travel>-changing_operation = 'UPDATE'.

          APPEND <ls_log_travel> TO lt_log_final.
        ENDIF.
      ENDLOOP.

    INSERT /DMO/LOG_TRAVEL FROM TABLE @lt_log_final.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result1.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setInitialStatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setInitialStatus.

    METHODS setTravelId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelId.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.
    METHODS recalculatePrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalculatePrice.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR Travel RESULT result.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Travel.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS check_update IMPORTING iv_customer TYPE /dmo/customer_id RETURNING VALUE(rv_updateok) TYPE abap_bool.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus  )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = 'A' ) )
    FAILED DATA(lt_failed).

    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    result1 = VALUE #( FOR trav IN travel ( %tky = trav-%tky %param = trav ) ).

  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF zi_gd_travel_m IN LOCAL MODE
  ENTITY Travel
  UPDATE FIELDS ( OverallStatus  )
  WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                  OverallStatus = 'X' ) )
  FAILED DATA(lt_failed).

    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    result = VALUE #( FOR trav IN travel ( %tky = trav-%tky %param = trav ) ).
  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    EXECUTE recalculatePrice
    FROM CORRESPONDING #( keys ).


  ENDMETHOD.

  METHOD setInitialStatus.

    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    FIELDS ( OverallStatus ) WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    DELETE travel WHERE OverallStatus IS NOT INITIAL.

    MODIFY ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus  ) WITH
    VALUE #( FOR trav IN travel ( %tky = trav-%tky OverallStatus = 'O' ) )
    REPORTED DATA(Report).

  ENDMETHOD.

  METHOD setTravelId.

    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
     ENTITY Travel
     FIELDS ( TravelId ) WITH CORRESPONDING #( keys )
     RESULT DATA(travel).

    SELECT SINGLE FROM zgd_travel FIELDS MAX( travel_id ) INTO @DATA(lv_travid).

    MODIFY ENTITIES OF zi_gd_travel_m IN LOCAL MODE
     ENTITY Travel
     UPDATE FIELDS ( TravelId  ) WITH
     VALUE #( FOR trav IN travel ( %tky = trav-%tky TravelId = lv_travid + 1  ) )
*     VALUE #( FOR trav IN travel ( %tky = trav-  ) )
     REPORTED DATA(Report).

  ENDMETHOD.

  METHOD validateAgency.

    DATA lt_agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.
    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    FIELDS ( AgencyId ) WITH CORRESPONDING #( keys )
    RESULT DATA(travel).

    lt_agency = CORRESPONDING #( travel DISCARDING DUPLICATES MAPPING agency_id = AgencyId ).
    IF lt_agency IS NOT INITIAL.
      SELECT FROM /dmo/agency FIELDS agency_id
      FOR ALL ENTRIES IN @lt_agency
      WHERE agency_id = @lt_agency-agency_id
      INTO TABLE @DATA(lt_valid_agency).
    ENDIF.

    LOOP AT travel INTO DATA(ls_trav).
      IF ls_trav-AgencyId IS INITIAL OR NOT line_exists( lt_valid_agency[ agency_id = ls_trav-AgencyId ] ).

        APPEND VALUE #( %tky = ls_trav-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_trav-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Invalid Agency ID !'

                         )
                         %element-AgencyId = if_abap_behv=>mk-on
                         ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
      ENTITY Travel
      FIELDS ( BeginDate EndDate ) WITH CORRESPONDING #( keys )
      RESULT DATA(travel).

    LOOP AT travel INTO DATA(ls_trav).

      IF  ls_trav-BeginDate IS INITIAL OR ls_trav-EndDate IS INITIAL OR ls_trav-EndDate < ls_trav-BeginDate.
        APPEND VALUE #( %tky = ls_trav-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = ls_trav-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Invalid Dates !' )
                         ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD recalculatePrice.

    TYPES: BEGIN OF ty_amount_tot,
             amount TYPE /dmo/total_price,
             curr   TYPE /dmo/currency_code,
           END OF ty_amount_tot.

    DATA: lt_tot_amt TYPE STANDARD TABLE OF ty_amount_tot.

    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys ) RESULT DATA(travel).

    LOOP AT travel ASSIGNING FIELD-SYMBOL(<trav>).
      CLEAR <trav>-totalprice.
      lt_tot_amt = VALUE #( (   amount = <trav>-BookingFee curr = <trav>-CurrencyCode ) ).

      READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
      ENTITY Travel BY \_Booking
      FIELDS ( FlightPrice CurrencyCode )
      WITH VALUE #( ( %tky = <trav>-%tky ) )
      RESULT DATA(bookings).

      LOOP AT bookings INTO DATA(book) WHERE CurrencyCode IS NOT INITIAL.
        COLLECT VALUE ty_amount_tot( amount = book-FlightPrice
                                     curr = book-CurrencyCode
                        ) INTO lt_tot_amt.
      ENDLOOP.

      LOOP   AT lt_tot_amt INTO DATA(ls_totamt).
        IF ls_totamt-curr = <trav>-CurrencyCode.
          <trav>-TotalPrice += ls_totamt-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = ls_totamt-amount
              iv_currency_code_source = ls_totamt-curr
              iv_currency_code_target = <trav>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
            IMPORTING
              ev_amount               = DATA(lv_converted_amt)
          ).
          <trav>-TotalPrice += lv_converted_amt.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( TotalPrice ) WITH CORRESPONDING #( travel ).

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    FIELDS ( OverallStatus  ) WITH CORRESPONDING #( keys )
    RESULT DATA(travel).



    result = VALUE #( FOR trav IN travel ( %tky = trav-%tky
                                %action-acceptTravel = COND #( WHEN trav-OverallStatus = 'A' OR trav-OverallStatus = ' '
                                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                %update =              COND #( WHEN trav-OverallStatus = 'A'
                                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                                %action-rejectTravel = COND #( WHEN trav-OverallStatus = 'X' OR trav-OverallStatus = ' '
                                                               THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                              )   ).

  ENDMETHOD.

  METHOD get_global_features.
    DATA(time_fr) = CONV t( '080000' ).
    DATA(time_to) = CONV t( '240000' ).
    DATA(now) = cl_abap_context_info=>get_system_time( ).
*    result-%create = COND #( WHEN cl_abap_context_info=>get_system_time( )
*                             BETWEEN time_fr AND time_to THEN if_abap_behv=>fc-o-disabled ELSE  if_abap_behv=>fc-o-enabled ).
*
*    result-%delete = COND #( WHEN cl_abap_context_info=>get_system_time( )
*                             BETWEEN time_fr AND time_to THEN if_abap_behv=>fc-o-disabled ELSE  if_abap_behv=>fc-o-enabled ).

  ENDMETHOD.

  METHOD precheck_update.

    LOOP AT entities INTO DATA(travel).

      IF travel-AgencyId IS NOT INITIAL.

        SELECT SINGLE * FROM /dmo/agency
            WHERE agency_id = @travel-AgencyId
            INTO @DATA(ls_agency).
        IF sy-subrc NE 0.
          APPEND VALUE #( %key = travel-%key
                          %update = if_abap_behv=>mk-on ) TO failed-travel.
          APPEND VALUE #( %key = travel-%key
                          %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text = 'Agency Id is not valid2' )
                          %element-agencyid = if_abap_behv=>mk-on
                         ) TO reported-travel.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.

    READ ENTITIES OF zi_gd_travel_m IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DATA(lv_update) = COND #( WHEN requested_authorizations-%update = '01' OR
                             requested_authorizations-%action-acceptTravel = '01' OR
                             requested_authorizations-%action-Edit = '01' OR
                             requested_authorizations-%action-RejectTravel = '01' OR
                             requested_authorizations-%assoc-_Booking = '01'
                             THEN abap_true ELSE abap_false

                            ).
    LOOP AT travels INTO DATA(trav).
      IF lv_update = abap_true.
        DATA(lv_bool) = check_update( trav-CustomerId ).
        IF lv_bool = abap_false.
          APPEND VALUE #( %tky = trav-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = trav-%tky
                          %msg = new_message_with_text( severity = CONV #( 'I' ) text = 'No Authorization to Edit !' ) )
                          TO reported-travel.
        ENDIF.
      ENDIF.

      APPEND VALUE #( %tky = trav-%tky
               %update = COND #( WHEN lv_bool = abap_true THEN '00' ELSE '01' )
               %action-acceptTravel = COND #( WHEN lv_bool = abap_true THEN '00' ELSE '01' )
               %action-rejectTravel = COND #( WHEN lv_bool = abap_true THEN '00' ELSE '01' )
               %action-Edit = COND #( WHEN lv_bool = abap_true THEN '00' ELSE '01' )
               %assoc-_Booking = COND #( WHEN lv_bool = abap_true THEN '00' ELSE '01' )



               ) TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD check_update.
    rv_updateok = abap_true.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
