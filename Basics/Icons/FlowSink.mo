within ClaRa.Basics.Icons;
model FlowSink
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

  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),
                   graphics={
                            Bitmap(
          extent={{-100,-108},{100,108}},
          imageSource=
              "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",
          fileName="modelica://ClaRa/Resources/Images/Components/Sink.png")}));

end FlowSink;
