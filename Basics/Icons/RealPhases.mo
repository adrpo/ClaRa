within ClaRa.Basics.Icons;
model RealPhases

  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics={Bitmap(
          extent={{-101,-100},{101,100}},
          imageSource=
              "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",
          fileName="modelica://ClaRa/Resources/Images/Components/RealPhases.png")}));

end RealPhases;
