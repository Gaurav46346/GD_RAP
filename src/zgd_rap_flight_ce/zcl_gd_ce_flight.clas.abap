CLASS zcl_gd_ce_flight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_gd_ce_flight IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lv_orderby TYPE string.
    IF io_request->is_data_requested(  ).
      "Get Paging
      DATA(lv_page) = io_request->get_paging(  )->get_page_size(  ).

      "Get Sorting
      DATA(lt_sort) = io_request->get_sort_elements(  ).

      LOOP at lt_sort INTO DATA(ls_sort).
        IF ls_sort-descending = abap_true.
            lv_orderby = |{ lv_orderby } { ls_sort-element_name } DESCENDING |.
        ELSE.
            lv_orderby = |{ lv_orderby } { ls_sort-element_name } ASCENDING |.
        ENDIF.
      ENDLOOP.
      IF lt_sort IS INITIAL.
      lv_orderby = 'CONNECTION_ID'.
      ENDIF.

      DATA(lv_where) = io_request->get_filter(  )->get_as_sql_string(  ).
      SELECT FROM /dmo/flight
      FIELDS *  WHERE (lv_where) ORDER BY (lv_orderby)  INTO TABLE @DATA(lt_flight)  UP TO @lv_page ROWS.

      IF  io_request->is_total_numb_of_rec_requested(  ).
        io_response->set_total_number_of_records( lines( lt_flight ) ).
      ENDIF.
      io_response->set_data( lt_flight ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
