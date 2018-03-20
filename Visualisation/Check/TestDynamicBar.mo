within ClaRa.Visualisation.Check;
model TestDynamicBar
extends ClaRa.Basics.Icons.PackageIcons.ExecutableExampleb80;
  Modelica.Blocks.Sources.Sine sine(
    offset=0.5,
    freqHz=2,
    amplitude=0.6) annotation (Placement(transformation(extent={{-90,-50},{-70,-30}})));
  DynamicBar dynamicBar(
    decimalSpaces=3,
    u_set=0.4,
    u_low=0.3,
    u=sine.y*2,
    unit="m",
    provideOutputConnector=true,
    provideInputConnectors=true,
    u_min=-0.1,
    u_max=0.5,
    u_high=0.45)                 annotation (Placement(transformation(extent={{-2,-40},{18,0}})));
  Modelica.Blocks.Sources.Sine sine1(
    freqHz=2,
    amplitude=0.1,
    offset=0.8)    annotation (Placement(transformation(extent={{-84,2},{-64,22}})));
  Modelica.Blocks.Sources.Sine sine2(
    freqHz=2,
    amplitude=0.4,
    offset=0.5)    annotation (Placement(transformation(extent={{-88,-24},{-68,-4}})));
  Modelica.Blocks.Math.Gain gain(k=0.1) annotation (Placement(transformation(extent={{-46,-28},{-40,-22}})));
equation
  connect(sine.y, dynamicBar.u_in) annotation (Line(points={{-69,-40},{-4,-40}},                     color={0,0,127}));
  connect(sine1.y, dynamicBar.u_high_in) annotation (Line(points={{-63,12},{-34,12},{-34,-12},{-4,-12}}, color={0,0,127}));
  connect(sine2.y, dynamicBar.u_set_in) annotation (Line(points={{-67,-14},{-36,-14},{-36,-20},{-4,-20}}, color={0,0,127}));
  connect(sine2.y, gain.u) annotation (Line(points={{-67,-14},{-58,-14},{-58,-25},{-46.6,-25}}, color={0,0,127}));
  connect(gain.y, dynamicBar.u_low_in) annotation (Line(points={{-39.7,-25},{-22.85,-25},{-22.85,-28},{-4,-28}}, color={0,0,127}));
  annotation (Icon(graphics,
                   coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=2));
end TestDynamicBar;
