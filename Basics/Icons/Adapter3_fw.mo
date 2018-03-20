within ClaRa.Basics.Icons;
model Adapter3_fw

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics), Icon(graphics={Bitmap(
          extent={{-100,-100},{100,100}},
          imageSource=
              "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",
          fileName="modelica://ClaRa/Resources/Images/Components/Adapter3_forward.png")}));

end Adapter3_fw;
