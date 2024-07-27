@EndUserText.label: 'Custom Entity For Flight Details'

@ObjectModel.query.implementedBy: 'ABAP:ZCL_GD_CE_FLIGHT'
define custom entity ZCE_GD_FLIGHT 

{

      @UI.lineItem   : [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
  key carrier_id     : /dmo/carrier_id;
      @UI.lineItem   : [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
  key connection_id  : /dmo/connection_id;
//      @UI.lineItem   : [{ position: 30 }]
//      @UI.identification: [{ position: 30 }]
//      @UI.selectionField: [{ position: 30 }]
//  key flight_date    : /dmo/flight_date;
      @Semantics.amount.currencyCode : 'currency_code'
      @UI.lineItem   : [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      price          : /dmo/flight_price;
      currency_code  : /dmo/currency_code;
      @UI.lineItem   : [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      plane_type_id  : /dmo/plane_type_id;
      @UI.lineItem   : [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      seats_max      : /dmo/plane_seats_max;
      @UI.lineItem   : [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      seats_occupied : /dmo/plane_seats_occupied;
}
