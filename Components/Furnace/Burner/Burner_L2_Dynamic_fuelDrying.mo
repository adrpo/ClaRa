within ClaRa.Components.Furnace.Burner;
model Burner_L2_Dynamic_fuelDrying "Model for a burner section inside a combustion chamber which is able to regard drying of unburnt fuel which contained water at burner inlet"
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

extends ClaRa.Components.Furnace.BaseClasses.CombustionChamberBase(redeclare replaceable model Geometry = ClaRa.Basics.ControlVolumes.Fundamentals.Geometry.HollowBlock);
                                                                                //(flueGasCombustion(p = outlet.flueGas.p, xi = xi_flueGas));
extends ClaRa.Basics.Icons.Burner;
//import ClaRa.Basics.Functions.Stepsmoother;

    //## S U M M A R Y   D E F I N I T I O N ###################################################################
  model Outline
    //  parameter Boolean showExpertSummary annotation(Dialog(hide));
    extends ClaRa.Basics.Icons.RecordIcon;
    input ClaRa.Basics.Units.Volume volume "Volume";
    input ClaRa.Basics.Units.Area A_cross "Free cross sectional area";
    input ClaRa.Basics.Units.Area A_wall "Wall area";
    input ClaRa.Basics.Units.Length height "Height of volume";
    input ClaRa.Basics.Units.Mass m "Mass inside volume";
    input ClaRa.Basics.Units.MassFlowRate m_flow_fuel_burned "Burned fuel mass flow rate";
    input ClaRa.Basics.Units.MassFlowRate m_flow_oxygen_burned "Burned oxygen mass flow rate";
    input ClaRa.Basics.Units.MassFlowRate m_flow_oxygen_req "Required O2 flow rate for stochiometric combustion";
    input ClaRa.Basics.Units.MassFlowRate m_flow_air_req "Required air flow rate for stochiometric combustion";
    input Real lambdaComb "Excess air";
    input Real NOx_fraction "NOx fraction at outlet";
    input Real CO_fraction "CO fraction at outlet";
    input ClaRa.Basics.Units.EnthalpyMassSpecific LHV "Lower heating value";
    input ClaRa.Basics.Units.HeatFlowRate Q_combustion "Combustion Heat";
    input ClaRa.Basics.Units.Velocity w_migration "Particle migration speed";
    input ClaRa.Basics.Units.Time t_dwell_flueGas "Flue gas dwelltime";
    input ClaRa.Basics.Units.Time burning_time "Burning time";
    input Real unburntFraction "Fuel diffusity";
    input ClaRa.Basics.Units.Temperature T_out "Outlet temperature";
    input ClaRa.Basics.Units.EnthalpyMassSpecific h_out "Flue gas enthalpy at outlet";
  end Outline;

  model Fuel
    extends ClaRa.Basics.Icons.RecordIcon;
    input ClaRa.Basics.Units.MassFlowRate m_flow "Mass flow rate"
      annotation (Dialog);
    input ClaRa.Basics.Units.Temperature T "Temperature" annotation (Dialog);
    input ClaRa.Basics.Units.Pressure p "Pressure" annotation (Dialog);
    input ClaRa.Basics.Units.HeatCapacityMassSpecific cp "Specific heat capacity"
                               annotation (Dialog);
  end Fuel;

  model Slag
    extends ClaRa.Basics.Icons.RecordIcon;
    input ClaRa.Basics.Units.MassFlowRate m_flow "Mass flow rate"
      annotation (Dialog);
    input ClaRa.Basics.Units.Temperature T "Temperature" annotation (Dialog);
    input ClaRa.Basics.Units.Pressure p "Pressure" annotation (Dialog);
  end Slag;

  model Flow
    extends ClaRa.Basics.Icons.RecordIcon;
    ClaRa.Basics.Records.FlangeGas flueGas;
    Fuel fuel;
    Slag slag;
  end Flow;

  model Burner
    extends ClaRa.Basics.Icons.RecordIcon;
    ClaRa.Basics.Records.FlangeGas flueGas;
    Fuel fuel;
  end Burner;

  model Summary
    extends ClaRa.Basics.Icons.RecordIcon;
    Outline outline;
    Flow inlet;
    Burner fuelFlueGas_inlet;
    Flow outlet;
  end Summary;

//## P A R A M E T E R S #######################################################################################
inner parameter Boolean useHomotopy=simCenter.useHomotopy "True, if homotopy method is used during initialisation"
                                                              annotation(Dialog(tab="Initialisation"));

//## V A R I A B L E   P A R T##################################################################################
public
 Real lambdaComb_primary "Primary lambda";
 ClaRa.Basics.Units.MassFlowRate m_flow_oxygen_req_primary "Required oxygen mass flwo for primary lambda calculation";
 ClaRa.Basics.Units.MassFlowRate m_flow_air_req_primary "Required air mass flwo for primary lambda calculation";

protected
  Modelica.SIunits.MolarFlowRate  n_flow_C_primary "Primary molar flow of C";
  Modelica.SIunits.MolarFlowRate  n_flow_H_primary "Primary molar flow of H";
  Modelica.SIunits.MolarFlowRate  n_flow_O_primary "Primary molar flow of O";
  Modelica.SIunits.MolarFlowRate  n_flow_S_primary "Primary molar flow of S";

  Real drhodt "Density derivative";

  ClaRa.Basics.Units.MassFraction xi_flueGasMix[flueGas.nc - 1] "Flue gas mixture composition";
  ClaRa.Basics.Units.MassFraction xi_flueGasMix_del[flueGas.nc - 1] "Pseudo state for flue gas mixture composition";

  ClaRa.Basics.Units.EnthalpyMassSpecific h_flueGasMix "Specific enthalpy of flue gas mixture";
  ClaRa.Basics.Units.EnthalpyMassSpecific h_flueGasMix_del "Pseudo state for specific enthalpy of flue gas mixture";

  ClaRa.Basics.Units.MassFlowRate m_flow_in_del "Pseudo state for inlet mass flow";
  ClaRa.Basics.Units.MassFlowRate m_flow_out_del "Pseudo state for outlet mass flow";
  ClaRa.Basics.Units.MassFraction elementaryComposition_fuel_out[fuelModel.N_e - 1] "Fuel inlet composition";
  ClaRa.Basics.Units.MassFraction xi_fuel_in_mix[fuelModel.N_c - 1] "Fuel inlet composition";

  constant SI.MassFraction xi_evap_coal[fuelModel.N_c-1] = cat(1,zeros(fuelModel.waterIndex-1), if fuelModel.waterIndex < fuelModel.N_c then {1} else zeros(0), zeros(max(0,fuelModel.N_c - fuelModel.waterIndex - 1)))  "Composition of evaporating water (in terms of coal)";

//_____________________/ Connectors \______________________________
public
  ClaRa.Basics.Interfaces.FuelFlueGas_inlet fuelFlueGas_inlet(flueGas(Medium=flueGas), fuelModel=fuelModel) annotation (Placement(transformation(extent={{-310,-10},{-290,10}}), iconTransformation(extent={{-310,-10},{-290,10}})));

//_____________________/ Media Objects \_________________________________
protected
     TILMedia.Gas_pT    primaryAir_inlet(p=fuelFlueGas_inlet.flueGas.p, T=actualStream(fuelFlueGas_inlet.flueGas.T_outflow), xi=actualStream(
        fuelFlueGas_inlet.flueGas.xi_outflow),
     gasType=flueGas)
     annotation (Placement(transformation(extent={{-290,-10},{-270,10}})));
     TILMedia.Gas_pT     flueGasOutlet(p=outlet.flueGas.p, T= actualStream(outlet.flueGas.T_outflow),xi=actualStream(outlet.flueGas.xi_outflow),
        gasType=flueGas)
        annotation (Placement(transformation(extent={{-130,74},{-110,94}})));

  TILMedia.Gas_ph inlet_GasMix(p=inlet.flueGas.p,xi=xi_flueGasMix_del,gasType=flueGas,h(start = 1.0E4)=h_flueGasMix_del)
     annotation (Placement(transformation(extent={{-160,-40},{-140,-20}})));

  Basics.Media.FuelObject fuelBurnerInlet(
  fuelModel=fuelModel,
    xi_c=noEvent(actualStream(fuelFlueGas_inlet.fuel.xi_outflow)),
    p=fuelFlueGas_inlet.fuel.p,
    T=noEvent(actualStream(fuelFlueGas_inlet.fuel.T_outflow))) annotation (Placement(transformation(extent={{-264,-28},{-244,-8}})));

public
    TILMedia.Gas_ph bulk(
    p(start=p_start_flueGas_out) = outlet.flueGas.p,
    xi=xi_flueGas_del,
    gasType=flueGas,
    h=h_flueGas_out_del)
      annotation (Placement(transformation(extent={{-130,26},{-110,46}})));

//___________________// Chemistry \\__________
replaceable model ReactionZone_out =
      ClaRa.Components.Furnace.ChemicalReactions.CoalReactionZone
    constrainedby ClaRa.Components.Furnace.ChemicalReactions.PartialReactionZone "Model to regard chemical reactions"
                                         annotation (Dialog(group=
          "Combustion"), choicesAllMatching=true);
  ReactionZone_out reactionZone_out(flueGas = flueGas,fuelModel=fuelModel, elementaryComposition_fuel_in=elementaryComposition_fuel_out)
    annotation (Placement(transformation(extent={{-54,74},{-34,94}})));

    //___________________/ iCom record \\__________________
protected
  inner ClaRa.Basics.Records.IComGas_L2 iCom(
    m_flow_nom=m_flow_nom,
    T_bulk=bulk.T,
    p_bulk=bulk.p,
    fluidPointer_in=inlet_GasMix.gasPointer,
    fluidPointer_bulk=bulk.gasPointer,
    fluidPointer_out=flueGasOutlet.gasPointer,
    mediumModel=flueGas,
    p_in=inlet.flueGas.p,
    T_in=inlet_GasMix.T,
    m_flow_in=m_flow_in_del,
    V_flow_in=V_flow_flueGas_in,
    xi_in=xi_flueGasMix_del,
    p_out=outlet.flueGas.p,
    T_out=bulk.T,
    m_flow_out=m_flow_out_del,
    V_flow_out=V_flow_flueGas_out,
    xi_out=xi_flueGas_del) annotation (Placement(transformation(extent={{244,-102},{268,-76}})));

//___________________/ Summary \\__________________
public
  Summary summary(
    outline(
      volume=geo.volume,
      A_cross=geo.A_front,
      A_wall=if geo.flowOrientation == ClaRa.Basics.Choices.GeometryOrientation.vertical then 2*(geo.width + geo.length)*geo.height else 2*(geo.width + geo.height)*geo.length,
      height=geo.height,
      m=mass,
      m_flow_fuel_burned=m_flow_fuel_burned,
      m_flow_oxygen_burned=m_flow_oxygen_burned,
      m_flow_oxygen_req=m_flow_oxygen_req,
      m_flow_air_req=m_flow_air_req,
      lambdaComb=lambdaComb,
      NOx_fraction=reactionZone.xi_NOx,
      CO_fraction=reactionZone.xi_CO,
      LHV=LHV,
      Q_combustion=m_flow_fuel_burned*LHV,
      w_migration=particleMigration.w,
      t_dwell_flueGas=t_dwell_flueGas,
      burning_time=burning_time.t,
      unburntFraction=unburntFraction,
      T_out=flueGasOutlet.T,
      h_out=flueGasOutlet.h),
    inlet(
      flueGas(mediumModel=flueGas,
        m_flow=inlet.flueGas.m_flow,
        T=actualStream(inlet.flueGas.T_outflow),
        p=inlet.flueGas.p,
        h=flueGasInlet.h,
        xi=actualStream(inlet.flueGas.xi_outflow),
        H_flow=flueGasInlet.h*inlet.flueGas.m_flow),
      fuel(
        m_flow=inlet.fuel.m_flow,
        T=actualStream(inlet.fuel.T_outflow),
        p=inlet.fuel.p,
        cp=fuelInlet.cp),
      slag(
        m_flow=inlet.slag.m_flow,
        T=actualStream(inlet.slag.T_outflow),
        p=inlet.slag.p)),
    fuelFlueGas_inlet(
      flueGas(mediumModel=flueGas,
        m_flow=fuelFlueGas_inlet.flueGas.m_flow,
        T=actualStream(fuelFlueGas_inlet.flueGas.T_outflow),
        p=fuelFlueGas_inlet.flueGas.p,
        h=primaryAir_inlet.h,
        xi=actualStream(fuelFlueGas_inlet.flueGas.xi_outflow),
        H_flow=primaryAir_inlet.h*fuelFlueGas_inlet.flueGas.m_flow),
      fuel(
        m_flow=fuelFlueGas_inlet.fuel.m_flow,
        T=actualStream(fuelFlueGas_inlet.fuel.T_outflow),
        p=fuelFlueGas_inlet.fuel.p,
        cp=fuelBurnerInlet.cp)),
    outlet(
      flueGas(mediumModel=flueGas,
        m_flow=-outlet.flueGas.m_flow,
        T=actualStream(outlet.flueGas.T_outflow),
        p=outlet.flueGas.p,
        h=h_flueGas_out,
        xi=actualStream(outlet.flueGas.xi_outflow),
        H_flow=-h_flueGas_out*outlet.flueGas.m_flow),
      fuel(
        m_flow=-outlet.fuel.m_flow,
        T=actualStream(outlet.fuel.T_outflow),
        p=outlet.fuel.p,
        cp=fuelOutlet.cp),
      slag(
        m_flow=outlet.slag.m_flow,
        T=actualStream(outlet.slag.T_outflow),
        p=outlet.slag.p))) annotation (Placement(transformation(extent={{274,-102},{300,-76}})));

public
  ClaRa.Basics.Units.MassFlowRate m_flow_evap;

  ClaRa.Basics.Units.EnthalpyMassSpecific h_fuel_water_in;
  ClaRa.Basics.Units.EnthalpyMassSpecific h_fuel_water_out;
  ClaRa.Basics.Units.EnthalpyMassSpecific Delta_h_fuel_water_evap;
  ClaRa.Basics.Units.EnthalpyMassSpecific LHV_out;
  ClaRa.Basics.Units.EnthalpyMassSpecific Delta_h_f_out;
  ClaRa.Basics.Units.MassFlowRate m_flow_flueGas_id_out;

  ClaRa.Basics.Units.MassFraction xi_flueGas_id_out[flueGas.nc - 1];

protected
  TILMedia.VLEFluidObjectFunctions.VLEFluidPointer H2O_props_in=
      TILMedia.VLEFluidObjectFunctions.VLEFluidPointer(
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.concatVLEFluidName,
      0,
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.mixingRatio_propertyCalculation[1:end - 1]/sum(TILMedia.VLEFluidTypes.TILMedia_SplineWater.mixingRatio_propertyCalculation),
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.nc_propertyCalculation,
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.nc,
      TILMedia.Internals.redirectModelicaFormatMessage()) "Pointer to external medium memory for fuel water properties";

    TILMedia.VLEFluidObjectFunctions.VLEFluidPointer H2O_props_out=
      TILMedia.VLEFluidObjectFunctions.VLEFluidPointer(
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.concatVLEFluidName,
      0,
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.mixingRatio_propertyCalculation[1:end - 1]/sum(TILMedia.VLEFluidTypes.TILMedia_SplineWater.mixingRatio_propertyCalculation),
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.nc_propertyCalculation,
      TILMedia.VLEFluidTypes.TILMedia_SplineWater.nc,
      TILMedia.Internals.redirectModelicaFormatMessage()) "Pointer to external medium memory for fuel water properties";

initial equation

  h_flueGas_out = h_start;
  xi_flueGas = xi_start_flueGas_out;

equation

  if (t_dwell_flueGas < burning_time.t) then
    unburntFraction = (1.0 - t_dwell_flueGas/burning_time.t);
  else
    unburntFraction = 0;
  end if;

  mass = geo.volume * (bulk.d + inlet_GasMix.d)/2;

   //____________/ Resulting Xi for entire fuel mass in the volume \______________
   if (inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow <= 0.0) then
      xi_fuel_in_mix = inStream(inlet.fuel.xi_outflow);
    else
   (inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow) * xi_fuel_in_mix = inStream(fuelFlueGas_inlet.fuel.xi_outflow)* fuelFlueGas_inlet.fuel.m_flow + inStream(inlet.fuel.xi_outflow)                                                                                                    * inlet.fuel.m_flow;
   end if;
  //____________/ Resulting Xi for entire fuel mass in the volume \______________
    if (inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow <= 0.0) then
       elementaryComposition_fuel_in =fuelInlet.xi_e; //inStream(inlet.fuel.xi_outflow);
     else
    (inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow) * elementaryComposition_fuel_in =fuelBurnerInlet.xi_e * fuelFlueGas_inlet.fuel.m_flow +fuelInlet.xi_e * inlet.fuel.m_flow;
    end if;

  //__________________________/ Resulting Xi for flue gas mix \____________________________
  inlet.flueGas.m_flow * flueGasInlet.xi +  fuelFlueGas_inlet.flueGas.m_flow * primaryAir_inlet.xi - (inlet.flueGas.m_flow+fuelFlueGas_inlet.flueGas.m_flow)*xi_flueGasMix = zeros(flueGas.nc-1);
  xi_flueGasMix_del = xi_flueGasMix;

  //________________/ Mass balance - flue gas \______________________________________
  drhodt*geo.volume =m_flow_fuel_burned*(1 - elementaryComposition_fuel_in[6]*reactionZone.xi_slag) + inlet.flueGas.m_flow + fuelFlueGas_inlet.flueGas.m_flow + outlet.flueGas.m_flow + m_flow_evap;
  drhodt = bulk.drhodh_pxi * der(bulk.h) + sum({bulk.drhodxi_ph[i] * der(bulk.xi[i]) for i in 1:flueGas.nc-1});

  //______________ / Mass balance - Slag \____________________________________________________________________________
  0 =inlet.slag.m_flow + m_flow_fuel_burned*elementaryComposition_fuel_in[6]*reactionZone.xi_slag + outlet.slag.m_flow;

  //______________/ Mass balance - Fuel \____________________________
  0 =outlet.fuel.m_flow + inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow - m_flow_fuel_burned - m_flow_evap;

  //__________/ molar flow rates of combustable components (educts) into the whole burner system (maybe not all of it is burned) \________
  n_flow_C = elementaryComposition_fuel_in[1]*(fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow) /Basics.Constants.M_C;
  n_flow_H = elementaryComposition_fuel_in[2]*(fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow) /Basics.Constants.M_H;
  n_flow_O = elementaryComposition_fuel_in[3]*(fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow) /Basics.Constants.M_O;
  n_flow_N = elementaryComposition_fuel_in[4]*(fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow) /Basics.Constants.M_N;
  n_flow_S = elementaryComposition_fuel_in[5]*(fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow) /Basics.Constants.M_S;
  n_flow_Ash = elementaryComposition_fuel_in[6]*(fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow) /Basics.Constants.M_Ash;
  n_flow_H2O = (1-sum(elementaryComposition_fuel_in))*(fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow) /Basics.Constants.M_H2O;

  //_______________/ determination of lambda at burner\_________________________
  n_flow_C_primary =fuelBurnerInlet.xi_e[1]*fuelFlueGas_inlet.fuel.m_flow
    /Basics.Constants.M_C;
  n_flow_H_primary =fuelBurnerInlet.xi_e[2]*fuelFlueGas_inlet.fuel.m_flow
    /Basics.Constants.M_H;
  n_flow_O_primary =fuelBurnerInlet.xi_e[3]*fuelFlueGas_inlet.fuel.m_flow
    /Basics.Constants.M_O;
  n_flow_S_primary =fuelBurnerInlet.xi_e[5]*fuelFlueGas_inlet.fuel.m_flow
    /Basics.Constants.M_S;

  m_flow_oxygen_req_primary = (n_flow_C_primary + n_flow_H_primary/4.0 + n_flow_S_primary - n_flow_O_primary/2)*Basics.Constants.M_O
                                                                                            *2.0;
  m_flow_air_req_primary*max(1e-32,primaryAir_inlet.xi[6]) = m_flow_oxygen_req_primary;

    if noEvent(m_flow_oxygen_req_primary <= 0) then
        lambdaComb_primary  = 1.0e3;
    else
      lambdaComb_primary = (fuelFlueGas_inlet.flueGas.m_flow*primaryAir_inlet.xi[6]) /(max(1e-12,m_flow_oxygen_req_primary));
    end if;

  //_______________/ determination of lambda (overall volume, regarding unburnt fuel and oxygen)\_________________________
  // theoretically required oxygen mass flow rate to burn all the fuel
   m_flow_oxygen_req = (1-unburntFraction)*(n_flow_C + n_flow_H/4.0 + n_flow_S - n_flow_O/2)*Basics.Constants.M_O
                                                                                            *2.0;
   m_flow_air_req*max(1e-32,primaryAir_inlet.xi[6]) = m_flow_oxygen_req;

      if noEvent(m_flow_oxygen_req <= 0) then
    lambdaComb = 1.0e3;
        else
    lambdaComb = (fuelFlueGas_inlet.flueGas.m_flow*primaryAir_inlet.xi[6] + inlet.flueGas.m_flow*inStream(inlet.flueGas.xi_outflow[6]))/(max(1e-12, m_flow_oxygen_req));
      end if;

  //calculation of actual fuel and oxygen mass flow rates that are burned
  if noEvent(lambdaComb > 1) then
    m_flow_fuel_burned = min(1, (1 - unburntFraction))*(inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow);
    m_flow_oxygen_burned = m_flow_oxygen_req;
   else
    m_flow_fuel_burned = lambdaComb*min(1, (1 - unburntFraction))*(inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow);
    m_flow_oxygen_burned = lambdaComb*m_flow_oxygen_req;
   end if;

  //_____________/ Calculation of the mixed LHV \______________________________________
  LHV = (inlet.fuel.m_flow*fuelInlet.LHV + fuelFlueGas_inlet.fuel.m_flow*fuelBurnerInlet.LHV)/ max(Modelica.Constants.eps,fuelFlueGas_inlet.fuel.m_flow + inlet.fuel.m_flow);

  //______________________________/ mass balance of flue gas components \__________________________
  der(xi_flueGas) =1/mass*(inlet.flueGas.m_flow*(flueGasInlet.xi - xi_flueGas) + fuelFlueGas_inlet.flueGas.m_flow*(primaryAir_inlet.xi - xi_flueGas) + outlet.flueGas.m_flow*(flueGasOutlet.xi - xi_flueGas) + m_flow_fuel_burned*(reactionZone.prod_comp - xi_flueGas) + m_flow_evap *({0,0,0,0,0,0,0,1,0} - xi_flueGas));
  //_____________/ Calculation of fuel formation enthalpy with LHV for an ideal combustion\__________________
  m_flow_fuel_id = 1.0;
  m_flow_flueGas_id =(m_flow_fuel_id*(1 - elementaryComposition_fuel_in[6]*reactionZone.xi_slag));           //ideal flue gas mass flow
   xi_flueGas_id =1/m_flow_flueGas_id*reactionZone.prod_comp;   //products of an ideal combustion

  sum_comp = sum(xi_flueGas_id);

  Delta_h_f - LHV =m_flow_flueGas_id*((ideal_combustion.h_i)*cat(1,xi_flueGas_id,{1 - sum(xi_flueGas_id)})) + elementaryComposition_fuel_in[6]*reactionZone.xi_slag*outlet.slagType.cp*T_0;//formation enthalpy of used fuel


  //_______________/ Energy Balance flueGasCombustion \__________________________
  der(h_flueGas_out) =(Q_flow_wall + Q_flow_top + Q_flow_bottom +
  inlet.flueGas.m_flow*(flueGasInlet.h - h_flueGas_out)
  + fuelFlueGas_inlet.flueGas.m_flow*(primaryAir_inlet.h - h_flueGas_out)
  + inlet.fuel.m_flow*((fuelInlet.cp*(inStream(inlet.fuel.T_outflow) - T_0)) - h_flueGas_out)
  + fuelFlueGas_inlet.fuel.m_flow*((fuelBurnerInlet.cp*(inStream(fuelFlueGas_inlet.fuel.T_outflow) - T_0)) - h_flueGas_out)
  + outlet.fuel.m_flow*((fuelOutlet.cp*(outlet.fuel.T_outflow - T_0)) - h_flueGas_out)
  + inlet.fuel.m_flow*(Delta_h_f)
  + fuelFlueGas_inlet.fuel.m_flow*(Delta_h_f)
  + outlet.fuel.m_flow*(Delta_h_f_out)
  + outlet.slag.m_flow*(outlet.slagType.cp*(actualStream(outlet.slag.T_outflow) - T_0) - h_flueGas_out)
  + inlet.slag.m_flow*(inlet.slagType.cp*(actualStream(inlet.slag.T_outflow) - T_0) - h_flueGas_out)
  + outlet.flueGas.m_flow*(flueGasOutlet.h - h_flueGas_out)
  + m_flow_evap*(h_fuel_water_in - h_flueGas_out) - m_flow_evap*(h_fuel_water_out- h_flueGas_out))/mass;


  sum_xi = sum(flueGasOutlet.xi);

  //______________/Calculation of Properties for heat transfer corellation (small energy balance for inlet flue gas streams) \_________

  V_flow_flueGas_out = outlet.flueGas.m_flow/flueGasOutlet.d;
  V_flow_flueGas_in = (inlet.flueGas.m_flow + fuelFlueGas_inlet.flueGas.m_flow)/inlet_GasMix.d;

  h_flueGasMix = (fuelFlueGas_inlet.flueGas.m_flow * primaryAir_inlet.h + inlet.flueGas.m_flow * flueGasInlet.h)/(inlet.flueGas.m_flow+fuelFlueGas_inlet.flueGas.m_flow);
  h_flueGasMix_del =h_flueGasMix;

  m_flow_in_del = inlet.flueGas.m_flow + fuelFlueGas_inlet.fuel.m_flow;
  m_flow_out_del = outlet.flueGas.m_flow;


  //______________/Drying of fuel if water is present and residual fuel leaves the burner volume\_________________
  if (1-sum(elementaryComposition_fuel_in)) <= 1e-9 or (-outlet.fuel.m_flow <= 1e-9) then
    xi_fuel_out = xi_fuel_in_mix;
    elementaryComposition_fuel_out = elementaryComposition_fuel_in;
    m_flow_evap = 0;
    h_fuel_water_in = 0;
    h_fuel_water_out = 0;
    Delta_h_fuel_water_evap = 0;
    LHV_out=LHV;
    m_flow_flueGas_id_out = m_flow_flueGas_id;
    Delta_h_f_out = Delta_h_f;
    xi_flueGas_id_out = xi_flueGas_id;
  else
    - xi_fuel_out * outlet.fuel.m_flow + xi_evap_coal*m_flow_evap = xi_fuel_in_mix*(inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow -m_flow_fuel_burned);
    - elementaryComposition_fuel_out * outlet.fuel.m_flow = elementaryComposition_fuel_in*(inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow -m_flow_fuel_burned);
    m_flow_evap = (inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow -m_flow_fuel_burned) *(1-sum(elementaryComposition_fuel_in));
    h_fuel_water_in = TILMedia.VLEFluidObjectFunctions.specificEnthalpy_pTxi(fuelFlueGas_inlet.fuel.p,inStream(fuelFlueGas_inlet.fuel.T_outflow), {1}, H2O_props_in);
    h_fuel_water_out = TILMedia.VLEFluidObjectFunctions.specificEnthalpy_pTxi(fuelFlueGas_inlet.fuel.p,bulk.T, {1}, H2O_props_out);
    Delta_h_fuel_water_evap =  TILMedia.VLEFluidObjectFunctions.dewSpecificEnthalpy_Txi(inStream(fuelFlueGas_inlet.fuel.T_outflow), {1}, H2O_props_in) - TILMedia.VLEFluidObjectFunctions.bubbleSpecificEnthalpy_Txi(inStream(fuelFlueGas_inlet.fuel.T_outflow), {1}, H2O_props_in);
    LHV_out = fuelOutlet.LHV;
    m_flow_flueGas_id_out = (m_flow_fuel_id*(1 - elementaryComposition_fuel_out[6]*reactionZone_out.xi_slag));
    xi_flueGas_id_out = 1/m_flow_flueGas_id_out*reactionZone_out.prod_comp;
    Delta_h_f_out - LHV_out =m_flow_flueGas_id_out*((ideal_combustion.h_i)*cat(1,xi_flueGas_id_out,{1 - sum(xi_flueGas_id_out)})) + elementaryComposition_fuel_out[6]*reactionZone_out.xi_slag*outlet.slagType.cp*T_0;//formation enthalpy of used fuel
  end if;


  xi_fuel = (inlet.fuel.m_flow + fuelFlueGas_inlet.fuel.m_flow)/(inlet.flueGas.m_flow + fuelFlueGas_inlet.flueGas.m_flow);// amount of fuel per flue gas mass

  //___________/ T_outflows \__________________________________________
  outlet.fuel.T_outflow = bulk.T;
  outlet.flueGas.T_outflow = bulk.T;
  fuelFlueGas_inlet.fuel.T_outflow = bulk.T;
  fuelFlueGas_inlet.flueGas.T_outflow = bulk.T;
  inlet.fuel.T_outflow = bulk.T;
  inlet.flueGas.T_outflow  = bulk.T;
  heat_bottom.T = bulk.T;

  if slagTemperature_calculationType==1 then
    inlet.slag.T_outflow = T_slag;
    outlet.slag.T_outflow = T_slag;
  elseif slagTemperature_calculationType==2 then
    inlet.slag.T_outflow = flueGasOutlet.T;
    outlet.slag.T_outflow = flueGasOutlet.T;
  elseif slagTemperature_calculationType==3 then
    inlet.slag.T_outflow = (flueGasOutlet.T + inlet_GasMix.T)/2;
    outlet.slag.T_outflow = (flueGasOutlet.T + inlet_GasMix.T)/2;
  elseif slagTemperature_calculationType==4 then
    inlet.slag.T_outflow = flueGasInlet.T;
    outlet.slag.T_outflow = flueGasInlet.T;
  else
    inlet.slag.T_outflow = T_slag;
    outlet.slag.T_outflow = T_slag;
    assert(slagTemperature_calculationType==1 or slagTemperature_calculationType==2 or slagTemperature_calculationType==3 or slagTemperature_calculationType==4, "Invalid slag temperature calculation type");
  end if;


  //_____________/ Pressures \______________________________________________
  fuelFlueGas_inlet.fuel.p = outlet.flueGas.p + Delta_p_aux;
  fuelFlueGas_inlet.flueGas.p = outlet.flueGas.p + Delta_p_aux;

 //____________/ values for inlet_outflows \_____________
  fuelFlueGas_inlet.fuel.xi_outflow = xi_fuel_out;
  fuelFlueGas_inlet.flueGas.xi_outflow =  xi_flueGas_del;
  inlet.flueGas.xi_outflow = xi_flueGas_del;
  outlet.flueGas.xi_outflow = xi_flueGas_del;

 //______________Eye port variable definition________________________
  eye_int[1].m_flow = -outlet.flueGas.m_flow;
  eye_int[1].T = flueGasOutlet.T-273.15;
  eye_int[1].s = flueGasOutlet.s/1e3;
  eye_int[1].p = flueGasOutlet.p/1e5;
  eye_int[1].h = flueGasOutlet.h/1e3;
  eye_int[1].xi = flueGasOutlet.xi;
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false,extent={{-300,
            -100},{300,100}}),
                      graphics={
        Line(
          points={{-260,0},{-140,0}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.None),
        Polygon(
          points={{-136,0},{-144,4},{-144,-4},{-136,0}},
          lineColor={0,0,0},
          lineThickness=0.5,
          smooth=Smooth.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{4,0},{-4,4},{-4,-4},{4,0}},
          lineColor={0,0,0},
          lineThickness=0.5,
          smooth=Smooth.None,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          origin={-120,-20},
          rotation=90),
        Line(
          points={{-120,-60},{-120,-20}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.None)}), Icon(coordinateSystem(preserveAspectRatio=false,
          extent={{-300,-100},{300,100}}), graphics={
        Text(
          extent={{32,74},{240,44}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=showData,
          textString=DynamicSelect("", "T_out="+String(bulk.T,format="1.0f") +" K")),
        Text(
          extent={{32,-6},{240,-36}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=showData,
          textString=DynamicSelect("", "Q_wall="+String(Q_flow_wall/1e6,format="1.0f")+" MW")),
        Text(
          extent={{32,34},{240,4}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=showData,
          textString=DynamicSelect("", "lambda="+String(min(99,lambdaComb_primary),format="1.1f"))),
        Text(
          extent={{32,-46},{240,-76}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          visible=showData,
          textString=DynamicSelect("", "Q_comb="+String(m_flow_fuel_burned*LHV/1e6,format="1.0f")+" MW"))}),
    Documentation(info="<html>
<p><b>Model description: </b>A stationary burner model for fuel fired furnaces</p>
<p><b>Contact:</b> Lasse Nielsen, TLK-Thermo GmbH</p>
<p><b>FEATURES</b> </p>
<p><ul>
<li>This model uses TILMedia</li>
<li>Stationary mass and energy balances are used</li>
<li>The formation enthalpy of the used fuel is calculated with the given Lower heating value and and ideal combustion with the given elemental composition of the fuel</li>
<li>Lower heating can be regarded with a fixed value or calculated according to the &QUOT;Verbandsformel&QUOT;</li>
<li>Different heat transfer correlations can be chosen </li>
<li>Amount of burnable fuel mass is calculated with particle diffusity which depends on models used to determine the mean migration speed according to the volume flow rates of the flue gas</li>
<li>Excess air is calculated for burner (lambda primary) and overall volume (lambda) separately</li>
</ul></p>
</html>"));
end Burner_L2_Dynamic_fuelDrying;
