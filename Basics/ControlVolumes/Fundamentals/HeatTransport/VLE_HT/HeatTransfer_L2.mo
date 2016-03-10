within ClaRa.Basics.ControlVolumes.Fundamentals.HeatTransport.VLE_HT;
partial model HeatTransfer_L2 " L2 || HT-BaseClass"

  extends ClaRa.Basics.Icons.Alpha;
  extends ClaRa.Basics.ControlVolumes.Fundamentals.HeatTransport.HeatTransferBaseVLE;
  import SM = ClaRa.Basics.Functions.Stepsmoother;
  import SZT = ClaRa.Basics.Functions.SmoothZeroTransition;

  outer ClaRa.Basics.Records.IComVLE_L2 iCom;
  outer parameter Boolean useHomotopy;

  parameter String temperatureDifference="Logarithmic mean" "Temperature Difference" annotation (Dialog(group="Heat Transfer"), choices(
      choice = "Arithmetic mean",
      choice = "Logarithmic mean",
      choice = "Logarithmic mean - smoothed",
      choice = "Inlet",
      choice = "Outlet"));

  Units.Temperature Delta_T_wi "Temperature difference between wall and fluid inlet temperature";
  Units.Temperature Delta_T_wo "Temperature difference between wall and fluid outlet temperature";
  Units.Temperature Delta_T_mean "Mean temperature difference used for heat transfer calculation";

  Units.Temperature Delta_T_U "Upper temperature difference";
  Units.Temperature Delta_T_L "Lower temperature difference";

  ClaRa.Basics.Interfaces.HeatPort_a heat annotation (Placement(transformation(extent={{90,-10},{110,10}}), iconTransformation(extent={{90,-10},{110,10}})));

equation
  Delta_T_wi = heat.T - iCom.T_in;
  Delta_T_wo = heat.T - iCom.T_out;
  Delta_T_U = ClaRa.Basics.Functions.maxAbs(Delta_T_wi, Delta_T_wo, 0.1);
  Delta_T_L = ClaRa.Basics.Functions.minAbs(Delta_T_wi, Delta_T_wo, 0.1);

  if temperatureDifference == "Logarithmic mean" then
    Delta_T_mean = noEvent(if floor(abs(Delta_T_wo)*1/eps) <= 1 or floor(abs(Delta_T_wi)*1/eps) <= 1 then 0 elseif (heat.T < iCom.T_out and heat.T > iCom.T_in) or (heat.T > iCom.T_out and heat.T < iCom.T_in) then 0 elseif floor(abs(Delta_T_wo - Delta_T_wi)*1/eps) < 1 then Delta_T_wi else (Delta_T_U - Delta_T_L)/log(Delta_T_U/Delta_T_L));
  elseif temperatureDifference == "Logarithmic mean - smoothed" then
    Delta_T_mean = if useHomotopy then homotopy(SM(0.1,eps, abs(Delta_T_L))*SM(0.01,eps, Delta_T_U*Delta_T_L) * SZT((Delta_T_U - Delta_T_L)/log(abs(Delta_T_U)/(abs(Delta_T_L)+1e-9)), Delta_T_wi, (abs(Delta_T_U)-abs(Delta_T_L))-0.01, 0.001), heat.T - iCom.T_out) else SM(0.1,eps, abs(Delta_T_L))*SM(0.01,eps, Delta_T_U*Delta_T_L) * SZT((Delta_T_U - Delta_T_L)/log(abs(Delta_T_U)/(abs(Delta_T_L)+1e-9)), Delta_T_wi, (abs(Delta_T_U)-abs(Delta_T_L))-0.01, 0.001);
  elseif temperatureDifference == "Arithmetic mean" then
    Delta_T_mean = heat.T - (iCom.T_in + iCom.T_out)/2;
  elseif temperatureDifference == "Inlet" then
    Delta_T_mean = heat.T - iCom.T_in;
  else
    Delta_T_mean = heat.T - iCom.T_out;
  end if;

end HeatTransfer_L2;