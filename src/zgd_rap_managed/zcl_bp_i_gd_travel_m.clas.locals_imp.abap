CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result1.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
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
  ENDMETHOD.

  METHOD setInitialStatus.
  ENDMETHOD.

  METHOD setTravelId.
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
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Invalid Agency ID !' )
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
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
