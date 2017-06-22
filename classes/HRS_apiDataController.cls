/*
*    Project Name        : eConnect
*    Project NameSpace   : HRS
*    Class Name          : HRS_apiDataController
*    Date                : Oct 11th, 2016
*    Description         : A component controller to store the value
*                        : 

*/

public with sharing class HRS_apiDataController {

  Public boolean isEdit {get; set;}         //To determine if the page is Edit
  Public Integer columns {get; set;}        //To determine how many columns is showing on the page
  Public HRSManager hrsManager;             //To store the HRS Manager

  public HRS_apiDataController() {

  }

  Public void sethrsManager ( hrsManager hrs ){
    hrsManager = hrs;
  }

  Public hrsManager gethrsManager(){
    return hrsManager;
  }

}