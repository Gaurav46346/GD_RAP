CLASS zcl_gd_eml_demo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_gd_eml_demo IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*
*    " Read Operation
*    READ ENTITIES OF zi_gd_travel_m
*     ENTITY Travel
*     ALL FIELDS  WITH VALUE #( ( TravelUuid =   '44420B705D96D1F8180098FA66DE7003' ) )
*     RESULT DATA(travel)
*     FAILED DATA(failed)
*     REPORTED DATA(reported).
*
*
*     READ ENTITIES OF zi_gd_travel_m
*     ENTITY Travel BY \_Booking
*     ALL FIELDS  WITH VALUE #( ( TravelUuid =  '44420B705D96D1F8180098FA66DE7003' ) )
*     RESULT DATA(booking).
*
*    out->write( travel ).
*    out->write( failed ).
*    out->write( booking ).

*    Modify
*    MODIFY ENTITIES OF zi_gd_travel_m
*     ENTITY Travel
*     UPDATE SET FIELDS WITH VALUE #( ( Traveluuid = '44420B705D96D1F8180098FA66DE7003'
*                                       Description = 'My Vacation'
*                                   ) ).
*
*    COMMIT ENTITIES
*       RESPONSE OF zi_gd_travel_m
*       FAILED DATA(failed_comit)
*       REPORTED DATA(reported_comit).
*
*    READ ENTITIES OF zi_gd_travel_m
*     ENTITY Travel
*     ALL FIELDS  WITH VALUE #( ( TravelUuid =   '44420B705D96D1F8180098FA66DE7003' ) )
*     RESULT travel.
*
*    out->write( travel ).

*    MODIFY ENTITIES OF  zi_gd_travel_m
*     ENTITY Travel
*     CREATE SET FIELDS WITH VALUE #( ( AgencyId = '70020' CustomerId = '60'
*                                       BeginDate = cl_abap_context_info=>get_system_date(  )
*                                       EndDate = cl_abap_context_info=>get_system_date(  ) + 5
*                                       Description = 'My new travel 10.06'
*                                       )
*                                       ( AgencyId = '70020' CustomerId = '60'
*                                       BeginDate = cl_abap_context_info=>get_system_date(  )
*                                       EndDate = cl_abap_context_info=>get_system_date(  ) + 5
*                                       Description = 'My new travel 11.06'
*                                       )
*                                       )
*     MAPPED DATA(mapped).

    MODIFY ENTITIES OF zi_gd_travel_m
    ENTITY Travel
    DELETE FROM VALUE #( ( Traveluuid = '3A4DC3EF5E991EEF89E2839A169A792F' )
                          (  Traveluuid = '3A4DC3EF5E991EEF89E2641700DCF8AD' )
                            ).

    COMMIT ENTITIES
   RESPONSE OF zi_gd_travel_m
   FAILED DATA(failed_comit)
   REPORTED DATA(reported_comit).

  ENDMETHOD.
ENDCLASS.
