class TabModel {

  dynamic id;
  dynamic name;
  dynamic data;
  dynamic txtSize;
  /*
  1=> text;
  2=> json

  */
  dynamic state; 

  TabModel({
     this.id,
     this.name,
     this.data,
     this.txtSize = 16.0,
     this.state = 0,
  });


}
