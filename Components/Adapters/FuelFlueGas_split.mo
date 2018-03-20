within ClaRa.Components.Adapters;
model FuelFlueGas_split
//___________________________________________________________________________//
// Component of the ClaRa library, version: 1.3.0                            //
//                                                                           //
// Licensed by the DYNCAP/DYNSTART research team under Modelica License 2.   //
// Copyright  2013-2018, DYNCAP/DYNSTART research team.                      //
//___________________________________________________________________________//
// DYNCAP and DYNSTART are research projects supported by the German Federal //
// Ministry of Economic Affairs and Energy (FKZ 03ET2009/FKZ 03ET7060).      //
// The research team consists of the following project partners:             //
// Institute of Energy Systems (Hamburg University of Technology),           //
// Institute of Thermo-Fluid Dynamics (Hamburg University of Technology),    //
// TLK-Thermo GmbH (Braunschweig, Germany),                                  //
// XRG Simulation GmbH (Hamburg, Germany).                                   //
//___________________________________________________________________________//
  extends ClaRa.Basics.Icons.Adapter2_fw;

//__________________________/ Media definintions \______________________________________________
  outer ClaRa.SimCenter simCenter;
  parameter ClaRa.Basics.Media.FuelTypes.BaseFuel fuelModel = simCenter.fuelModel1   "Fuel type" annotation (choicesAllMatching, Dialog(group="Fundamental Definitions"));

  inner parameter ClaRa.Basics.Media.Slag.PartialSlag slag=simCenter.slagModel "Slag properties" annotation (choicesAllMatching, Dialog(group="Fundamental Medium Definitions"));
  inner parameter TILMedia.GasTypes.BaseGas flueGas = simCenter.flueGasModel "Medium to be used in tubes" annotation(choicesAllMatching, Dialog(group="Fundamental Medium Definitions"));

  ClaRa.Basics.Interfaces.Fuel_outlet  fuel_outlet(fuelModel=fuelModel) annotation (Placement(transformation(extent={{90,50},{110,70}})));
  ClaRa.Basics.Interfaces.GasPortOut flueGas_outlet(Medium=flueGas) annotation (Placement(transformation(extent={{90,-70},{110,-50}})));

  ClaRa.Basics.Interfaces.FuelFlueGas_inlet fuelFlueGas_inlet(flueGas(Medium=flueGas), fuelModel=fuelModel) annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));

equation
  fuelFlueGas_inlet.flueGas.m_flow = -flueGas_outlet.m_flow;
  fuelFlueGas_inlet.flueGas.T_outflow = inStream(flueGas_outlet.T_outflow);
  flueGas_outlet.T_outflow = inStream(fuelFlueGas_inlet.flueGas.T_outflow);
  fuelFlueGas_inlet.flueGas.xi_outflow = inStream(flueGas_outlet.xi_outflow);
  flueGas_outlet.xi_outflow = inStream(fuelFlueGas_inlet.flueGas.xi_outflow);
  fuelFlueGas_inlet.flueGas.p = flueGas_outlet.p;

  fuelFlueGas_inlet.fuel.m_flow = -fuel_outlet.m_flow;
  fuelFlueGas_inlet.fuel.T_outflow = inStream(fuel_outlet.T_outflow);
  fuel_outlet.T_outflow = inStream(fuelFlueGas_inlet.fuel.T_outflow);
  fuelFlueGas_inlet.fuel.xi_outflow = inStream(fuel_outlet.xi_outflow);
  fuel_outlet.xi_outflow = inStream(fuelFlueGas_inlet.fuel.xi_outflow);
  fuelFlueGas_inlet.fuel.p = fuel_outlet.p;

  annotation (Icon(graphics),
                           Diagram(graphics));
end FuelFlueGas_split;
