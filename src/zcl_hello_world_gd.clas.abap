CLASS zcl_hello_world_gd DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.dad



CLASS zcl_hello_world_gd IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  out->write( 'Hello World !' ).
  ENDMETHOD.
ENDCLASS.
