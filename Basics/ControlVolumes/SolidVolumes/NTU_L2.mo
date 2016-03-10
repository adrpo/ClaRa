within ClaRa.Basics.ControlVolumes.SolidVolumes;
model NTU_L2 "NTU-based heat transfer resistance"
//___________________________________________________________________________//
// Component of the ClaRa library, version: 1.1.0                        //
//                                                                           //
// Licensed by the DYNCAP/DYNSTART research team under Modelica License 2.   //
// Copyright � 2013-2016, DYNCAP/DYNSTART research team.                     //
//___________________________________________________________________________//
// DYNCAP and DYNSTART are research projects supported by the German Federal //
// Ministry of Economic Affairs and Energy (FKZ 03ET2009/FKZ 03ET7060).      //
// The research team consists of the following project partners:             //
// Institute of Energy Systems (Hamburg University of Technology),           //
// Institute of Thermo-Fluid Dynamics (Hamburg University of Technology),    //
// TLK-Thermo GmbH (Braunschweig, Germany),                                  //
// XRG Simulation GmbH (Hamburg, Germany).                                   //
//___________________________________________________________________________//

  import SI = ClaRa.Basics.Units;

  outer ClaRa.SimCenter simCenter;
  extends ClaRa.Basics.Icons.NTU;
  extends ClaRa.Basics.Icons.ComplexityLevel(complexity="L2");

//_____________fundamental definitions_________________________________________//

 replaceable model Material = TILMedia.SolidTypes.TILMedia_Aluminum constrainedby TILMedia.SolidTypes.BaseSolid "Material of the cylinder"
                               annotation(choicesAllMatching, Dialog(group="Fundamental Definitions"));
  replaceable model HeatExchangerType =
      ClaRa.Basics.ControlVolumes.SolidVolumes.Fundamentals.HeatExchangerTypes.CounterFlow
    constrainedby ClaRa.Basics.ControlVolumes.SolidVolumes.Fundamentals.HeatExchangerTypes.GeneralHeatExchanger "Type of HeatExchanger"
                                                                                       annotation(choicesAllMatching, Dialog(group="Fundamental Definitions"));

//______________geometry definitions________________________________________//
  parameter Integer N_t=1 "Number of tubes in one pass" annotation(Dialog(group="Geometry"));
  parameter Integer N_p=1 "Number of passes" annotation(Dialog(group="Geometry"));
  parameter Units.Length length "Tube length (for one pass)" annotation(Dialog(group="Geometry"));
  parameter Units.Length radius_i "Inner radius of tube" annotation(Dialog(group="Geometry"));
  parameter Units.Length radius_o "Outer radius of tube" annotation(Dialog(group="Geometry"));
  parameter Units.Mass mass_struc = 0 "Mass of inner structure elements, additional to the tubes itself"             annotation(Dialog(group="Geometry"));
  final parameter Units.Mass mass = mass_struc + solid.d*N_t*N_p*length*Modelica.Constants.pi*(radius_o^2-radius_i^2) "Total mass of HEX";

  parameter Real CF_geo=1 "Correction coefficient due to fins etc." annotation(Dialog(group="Geometry"));
  parameter Integer stateLocation=1 "Location of the states" annotation(Dialog(group="Geometry"),choices(choice = 1 "States on outer surfaces",
                                                                                            choice = 2 "Inner location of states"));

//Area of Heat Transfer
  final parameter Units.Area A_heat_m = (A_heat_o-A_heat_i)/log(A_heat_o/A_heat_i) "Mean area of heat transfer (single tube)";
  final parameter Units.Area A_heat_i= 2*Modelica.Constants.pi*radius_i*length*N_t*N_p "Area of heat transfer at inner phase";
  final parameter Units.Area A_heat_o= 2*Modelica.Constants.pi*radius_o*length*N_t*N_p "Area of heat transfer at oter phase";

//______________Initialisation______________________________________________//
  parameter Units.Temperature T_w_i_start= 293.15 "Initial temperature at inner phase"    annotation(Dialog(tab="Initialisation"));
  parameter Units.Temperature T_w_a_start = 293.15 "Initial temperature at outer phase"   annotation(Dialog(tab="Initialisation"));
  parameter ClaRa.Basics.Choices.Init initChoice=ClaRa.Basics.Choices.Init.noInit "Initialisation option"                   annotation(Dialog(tab="Initialisation"));
//______________Visualisation______________________________________________//
 parameter Boolean showExpertSummary = false "|Summary and Visualisation||True, if expert summary should be applied";

//______________Inputs_____________________________________________________//
  input Units.Temperature T_i_in "Inlet temperature of inner flow"
    annotation (Dialog(group="Input"));
  input Units.Temperature T_a_in "Inlet temperature of outer flow"
    annotation (Dialog(group="Input"));

  input Units.MassFlowRate m_flow_i "Mass flow rate of inner side"      annotation (Dialog(group="Input"));
  input Units.MassFlowRate m_flow_a "Mass flow rate of outer side" annotation (Dialog(group="Input"));

  input Units.CoefficientOfHeatTransfer alpha_i "Coefficient of heatTransfer for inner side"            annotation (Dialog(group="Input"));
  input Units.CoefficientOfHeatTransfer alpha_o "Coefficient of heatTransfer for outer side"            annotation (Dialog(group="Input"));

  input Units.HeatCapacityMassSpecific cp_mean_i "Mean cp of inner flow"               annotation (Dialog(group="Input"));
  input Units.HeatCapacityMassSpecific cp_mean_a "Mean cp of outer flow"               annotation (Dialog(group="Input"));

//______________Variables__________________________________________________//
  Units.Temperature T_i_out "Outlet temperature of steady state inner flow";
  Units.Temperature T_a_out "Outlet temperature of steady state outer flow";
  Units.HeatFlowRate Q_flow_NTU_1 "Steady state heat flow rate outer to inner phase";
  Real kA(unit="W/K") "The product U*S";
  Real effectiveness "Heat exchanger efficiency";

protected
  Units.Temperature T_w_i(start=T_w_i_start) "Wall temperature at inner phase";
  Units.Temperature T_w_a(start=T_w_a_start) "Wall temperature at outer phase";

  Real R_1 "Aspect ratio of heat capacity rates W1/W2<1";
//  Real R_2 "Aspect ratio of heat capacity flow rates W2/W1";

  Real NTU_1 "Number of Transfer Units related to the flow 1";
  Real NTU_2 "Number of Transfer Units related to flow 2";

  Real C_flow_1(unit="W/K") "Smaller heat capacity rate";
  Real C_flow_2(unit="W/K") "Larger heat capacity rate";
  Real k=(0.5*mass*solid.cp)/100;
public
record Summary
  extends ClaRa.Basics.Icons.RecordIcon;
  parameter Boolean showExpertSummary;
  Real NTU_1 if showExpertSummary "Number of Transfer Units related to the flow 1";
  Real NTU_2 if showExpertSummary "Number of Transfer Units related to flow 2";

  Real C_flow_low(unit="W/K") if showExpertSummary "Smaller heat capacity rate";
  Real C_flow_high(unit="W/K") if showExpertSummary "Larger heat capacity rate";

  Units.Area A_mean "Mean area of heat transfer (single tube)";
  Units.Temperature T_i_out "Outlet temperature of steady state inner flow";
  Units.Temperature T_o_out "Outlet temperature of steady state outer flow";
  Real kA(unit="W/K") "The product of thermal transmission and heat transfer area";
  Real effectiveness "Heat exchanger efficiency";
  Units.HeatFlowRate Q_flow "Steady state heat flow rate outer to inner phase";
  Units.HeatCapacityMassSpecific cp_mean_i "Mean cp of inner flow";
  Units.HeatCapacityMassSpecific cp_mean_a "Mean cp of outer flow";
  Units.DensityMassSpecific d "Material density";
end Summary;

public
  ClaRa.Basics.Interfaces.HeatPort_a
                                   outerPhase "outer side of cylinder"
                                         annotation (Placement(transformation(
          extent={{-10,80},{10,100}}, rotation=0)));
  ClaRa.Basics.Interfaces.HeatPort_a
                                   innerPhase "inner side of cylinder"
                                         annotation (Placement(transformation(
          extent={{-10,-100},{10,-80}},
                                      rotation=0)));
   TILMedia.Solid solid(redeclare replaceable model SolidType = Material, T=(T_w_i+T_w_a)/2)
     annotation (Placement(transformation(extent={{60,20},{80,40}})));

  HeatExchangerType heatExchangerType(NTU_1=NTU_1, R_1=R_1) annotation (Placement(transformation(extent={{20,20},{40,40}},   rotation=0)));
  Summary summary(showExpertSummary=showExpertSummary,C_flow_low=C_flow_1,C_flow_high=C_flow_2,NTU_1=NTU_1,NTU_2=NTU_2,A_mean=A_heat_m,T_i_out=T_i_out,T_o_out=T_a_out,kA=kA,effectiveness=effectiveness,Q_flow=Q_flow_NTU_1, cp_mean_i=cp_mean_i,cp_mean_a=cp_mean_a, d=solid.d)
annotation(Placement(transformation(extent={{-100,-102},{-80,-82}})));

initial equation
  if initChoice == ClaRa.Basics.Choices.Init.steadyState then
    der(T_w_i)=0;
    der(T_w_a)=0;

  end if;
//   if stateLocation ==2 then
//     innerPhase.T = T_w_i;
//     outerPhase.T = T_w_a;
//   end if;
equation
  //variables of the NTU method:
  C_flow_1=noEvent(min(cp_mean_i*abs(m_flow_i), cp_mean_a*abs(m_flow_a)));
  C_flow_2=noEvent(max(cp_mean_i*abs(m_flow_i), cp_mean_a*abs(m_flow_a)));

  R_1=(C_flow_1+1e-3)/(C_flow_2+1e-3);
//  R_2=C_flow_2/C_flow_1;

//Heat transfer coefficient
  kA = 2*Modelica.Constants.pi*length*N_p*N_t/(1/(alpha_i*radius_i) + log(radius_o/radius_i)/solid.lambda + 1/(CF_geo * alpha_o*radius_o));

//Wall temperatures:
if stateLocation == 1 then
  innerPhase.T = T_w_i;
  outerPhase.T = T_w_a;
else
  innerPhase.Q_flow=k*(innerPhase.T-T_w_i);
  outerPhase.Q_flow=k*(outerPhase.T-T_w_a);
end if;

//Number of Transfer Units:
  NTU_1 = kA/(C_flow_1+1e-3)*heatExchangerType.CF_NTU;
  NTU_2 = kA/(C_flow_2+1e-3)*heatExchangerType.CF_NTU;

  effectiveness = (1 - exp(-NTU_1*(1-R_1)))/(1 - R_1*exp(-NTU_1*(1-R_1))); //for CounterFlow

//heat flow from flow 1 to flow 2:
  T_i_out = noEvent(if cp_mean_i*abs(m_flow_i) < cp_mean_a*abs(m_flow_a) then T_i_in-effectiveness*(T_i_in - T_a_in) else T_i_in + Q_flow_NTU_1/(C_flow_2+1e-3));
  T_a_out = noEvent(if cp_mean_i*abs(m_flow_i) > cp_mean_a*abs(m_flow_a) then T_a_in+effectiveness*(T_i_in - T_a_in) else T_a_in - Q_flow_NTU_1/(C_flow_2+1e-3));

//Heat flow rate using the effectiveness of the heat exchanger
   Q_flow_NTU_1=effectiveness*C_flow_1*(T_a_in-T_i_in);
//Energy Balance:
    der(T_w_i)=(innerPhase.Q_flow+Q_flow_NTU_1)/(0.5 * mass*solid.cp);
    der(T_w_a)=(outerPhase.Q_flow-Q_flow_NTU_1)/(0.5 * mass*solid.cp);
  annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},
            {100,100}}), graphics), Icon(coordinateSystem(preserveAspectRatio=false,
          extent={{-100,-100},{100,100}})));
end NTU_L2;