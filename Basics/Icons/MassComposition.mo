within ClaRa.Basics.Icons;
model MassComposition

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics), Icon(graphics={Bitmap(
          extent={{-100,-100},{100,100}},
          imageSource=
              "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",
          fileName="modelica://ClaRa/Resources/Images/Components/MassCompostion.png")}));

end MassComposition;
