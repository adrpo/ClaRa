within ClaRa.Components.TurboMachines.Pumps.Fundamentals;
partial model PumpVLE_affinityBase "Base class for affinity law based pumps"
  //
//___________________________________________________________________________//
// Component of the ClaRa library, version: 1.5.1                            //
//                                                                           //
// Licensed by the DYNCAP/DYNSTART research team under Modelica License 2.   //
// Copyright  2013-2020, DYNCAP/DYNSTART research team.                      //
//___________________________________________________________________________//
// DYNCAP and DYNSTART are research projects supported by the German Federal //
// Ministry of Economic Affairs and Energy (FKZ 03ET2009/FKZ 03ET7060).      //
// The research team consists of the following project partners:             //
// Institute of Energy Systems (Hamburg University of Technology),           //
// Institute of Thermo-Fluid Dynamics (Hamburg University of Technology),    //
// TLK-Thermo GmbH (Braunschweig, Germany),                                  //
// XRG Simulation GmbH (Hamburg, Germany).                                   //
//___________________________________________________________________________//

  import pow = Modelica.Fluid.Dissipation.Utilities.Functions.General.SmoothPower;
  import SM = ClaRa.Basics.Functions.Stepsmoother;
  import Modelica.Constants.pi;

  extends ClaRa.Components.TurboMachines.Pumps.Fundamentals.Pump_Base; //(inlet( m_flow(      start=V_flow_max*losses.V_flow_opt_*1000)))

  ClaRa.Basics.Interfaces.Connected2SimCenter connected2SimCenter(
    powerIn=0,
    powerOut_elMech=0,
    powerOut_th=0,
    powerAux=P_shaft) if  contributeToCycleSummary;

  parameter Boolean useMechanicalPort=false "True, if a mechenical flange should be used" annotation(Dialog(group="Fundamental Definitions"));
  parameter Boolean steadyStateTorque=false "True, if steady state mechanical momentum shall be used" annotation(Dialog(group="Fundamental Definitions"));
  parameter Basics.Units.RPM rpm_nom "Nomial rotational speed" annotation (Dialog(group="Fundamental Definitions"));

  parameter Basics.Units.RPM rpm_fixed=60 "Constant rotational speed of pump" annotation (Dialog(group="Fundamental Definitions", enable=not useMechanicalPort));
  parameter Modelica.SIunits.Inertia J "Moment of Inertia" annotation(Dialog(group="Fundamental Definitions", enable= not steadyStateTorque));


protected
 model Outline
   extends ClaRa.Components.TurboMachines.Pumps.Fundamentals.Outline;
    input Basics.Units.Power P_iso "Power for isentropic flow";
    input Basics.Units.Power P_shaft "Mechanicl power at shaft";
    input ClaRa.Basics.Units.RPM rpm "Pump revolutions per minute";
 end Outline;


public
  Modelica.SIunits.AngularAcceleration a "Angular acceleration of the shaft";
  Modelica.SIunits.Torque tau_fluid "Fluid torque";
  Basics.Units.RPM rpm "Rotational speed";
  Basics.Units.Power P_iso "Power for isentropic pressure increase";
  Basics.Units.Power P_shaft "Shaft power";
//  Real eta_hyd(start=eta_hyd_nom) "Hydraulic efficiency";


public
  Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft if  useMechanicalPort
    annotation (Placement(transformation(extent={{-10,62},{10,82}}),
        iconTransformation(extent={{-10,89},{10,109}})));


protected
  ClaRa.Components.TurboMachines.Fundamentals.GetInputsRotary getInputsRotary
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={0,20})));


equation


//____________________ Mechanics ___________________________
   if useMechanicalPort then
     der(getInputsRotary.rotatoryFlange.phi) = (2*pi*rpm/60);
     J*a = - tau_fluid + getInputsRotary.rotatoryFlange.tau "Mechanical momentum balance";
   else
     rpm = rpm_fixed;
     getInputsRotary.rotatoryFlange.phi = 0.0;
   end if;

   if (steadyStateTorque) then
     a = 0;
   else
     a = (2*pi/60)*der(rpm);
   end if;



  connect(shaft, getInputsRotary.rotatoryFlange)
    annotation (Line(points={{0,72},{0,72},{0,30}}, color={0,0,0}));
  annotation (Diagram(graphics,
                      coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}})),  Icon(graphics));
end PumpVLE_affinityBase;
