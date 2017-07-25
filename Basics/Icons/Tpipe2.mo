within ClaRa.Basics.Icons;
model Tpipe2
//___________________________________________________________________________//
// Component of the ClaRa library, version: 1.2.2                            //
//                                                                           //
// Licensed by the DYNCAP/DYNSTART research team under Modelica License 2.   //
// Copyright  2013-2017, DYNCAP/DYNSTART research team.                     //
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
                   graphics={Bitmap(
          extent={{-100,-100},{100,32}},
          imageSource=
              "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",
          fileName="modelica://ClaRa/figures/Components/Junction2.png")}));

end Tpipe2;
