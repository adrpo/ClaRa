within ClaRa.Basics.Icons;
model Pipe_L4
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

  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-140,
            -50},{140,50}}),
                   graphics={Bitmap(
          extent={{-140,-50},{140,50}},
          imageSource=
              "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",
          fileName="modelica://ClaRa/figures/Components/Pipe_L4.png")}),
      Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-140,-50},{
            140,50}})));

end Pipe_L4;